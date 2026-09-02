extends Node

## 🤖 AIService Autoload for Kronos.
## High-Yield AI Flashcard Generator & Socratic Study Companion.
## Supports:
## 1. Google Gemini (Default Free Tier: gemini-1.5-flash)
## 2. OpenAI (gpt-4o-mini)
## 3. Local Ollama (100% Free Offline: localhost:11434)

signal ai_response_received(action_type: String, success: bool, data: Variant, error_msg: String)

enum Provider {
	GEMINI = 0,
	OPENAI = 1,
	OLLAMA = 2
}

const PROVIDER_NAMES: Array[String] = [
	"Google Gemini (Free Tier)",
	"OpenAI (GPT-4o)",
	"Local Ollama (Offline)"
]

const KEY_HELP_URLS: Array[String] = [
	"https://aistudio.google.com/app/apikey",
	"https://platform.openai.com/api-keys",
	"https://ollama.com"
]

const CONFIG_PATH: String = "user://ai_config.json"

var provider: Provider = Provider.GEMINI
var api_key: String = ""
var custom_model: String = ""
var is_request_in_flight: bool = false

var _http_client: HTTPRequest = null
var _retry_count: int = 0
const MAX_RETRIES: int = 2

func _ready() -> void:
	_http_client = HTTPRequest.new()
	_http_client.name = "AIHTTPRequest"
	_http_client.timeout = 25.0
	add_child(_http_client)
	_http_client.request_completed.connect(_on_http_request_completed)
	load_ai_config()

# ==============================================================================
# 💾 PERSISTENCE & CONFIGURATION
# ==============================================================================
func load_ai_config() -> void:
	if not FileAccess.file_exists(CONFIG_PATH):
		return
	var f = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if not f:
		return
	var text = f.get_as_text()
	f.close()
	var json = JSON.new()
	if json.parse(text) == OK and typeof(json.data) == TYPE_DICTIONARY:
		var dict: Dictionary = json.data
		provider = dict.get("provider", Provider.GEMINI) as Provider
		api_key = dict.get("api_key", "")
		custom_model = dict.get("custom_model", "")

func save_ai_config(p_provider: Provider, p_key: String, p_model: String = "") -> void:
	var key_changed = (api_key != p_key.strip_edges())
	provider = p_provider
	api_key = p_key.strip_edges()
	custom_model = p_model.strip_edges()
	if key_changed:
		_cached_gemini_models.clear()
	
	var dict: Dictionary = {
		"provider": int(provider),
		"api_key": api_key,
		"custom_model": custom_model
	}
	var f = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(dict, "\t"))
		f.close()

func open_get_key_url(p_idx: int = -1) -> void:
	var idx: int = int(provider) if p_idx < 0 else p_idx
	if idx >= 0 and idx < KEY_HELP_URLS.size():
		OS.shell_open(KEY_HELP_URLS[idx])

# ==============================================================================
# 🌐 API DISPATCH
# ==============================================================================
var _current_action: String = ""
var _current_prompt: String = ""
var _active_callback: Callable = Callable()

func test_connection(callback: Callable = Callable()) -> void:
	if is_request_in_flight:
		if callback.is_valid():
			callback.call(false, "Another request is already in progress.")
		return
		
	var prompt = "Hello! Please reply with a short JSON containing {\"status\": \"ok\", \"message\": \"connected\"}."
	_retry_count = 0
	_send_ai_prompt("test_ping", prompt, callback)

func generate_flashcards(source_text: String, card_count: int, topic_hint: String = "", callback: Callable = Callable()) -> void:
	if is_request_in_flight:
		if callback.is_valid():
			callback.call(false, [], "Another request is already in progress.")
		return
		
	var target_count = clamp(card_count, 3, 30)
	var prompt = """
You are an expert Spaced Repetition (SuperMemo/Anki) pedagogical assistant in Kronos.
Your task is to analyze the source material and extract exactly %d high-yield, atomic flashcards adhering to the Minimum Information Principle.

RULES:
1. Each card MUST test a single, unambiguous fact, mechanism, definition, or relation.
2. Front: Clear question, prompt, or term to define.
3. Back: Punchy, authoritative answer (1-2 sentences maximum or bullet points).
4. Hint: A memorable mnemonic, analogy, or clue.
5. Subject: Specific subject category (e.g. 'Computer Science', 'Biology', 'History').
6. Only use facts present in or directly inferred from the Source Text. Do NOT hallucinate.

Focus Topic / Emphasis: %s

Source Text:
\"\"\"
%s
\"\"\"

Return ONLY a valid JSON array of objects with NO surrounding conversational text, markdown formatting, or backticks:
[
  {
    "front": "What is...",
    "back": "The answer is...",
    "hint": "Starts with...",
    "subject": "Topic Name"
  }
]
""" % [target_count, topic_hint if topic_hint != "" else "Core Principles & High-Yield Facts", source_text.substr(0, 12000)]
	
	_retry_count = 0
	_send_ai_prompt("generate_cards", prompt, callback)

func explain_concept(question: String, answer: String, callback: Callable = Callable()) -> void:
	if is_request_in_flight:
		if callback.is_valid():
			callback.call(false, "", "Another request is already in progress.")
		return
		
	var prompt = """
You are a warm, supportive study pet companion in Kronos.
A student is struggling to recall this flashcard. Explain the underlying concept using an intuitive real-world analogy (Explain Like I'm 5 / ELI5) in 2 short, memorable sentences.

Question: %s
Answer: %s

Return ONLY the 2-sentence analogy text with NO conversational filler or markdown.
""" % [question, answer]

	_retry_count = 0
	_send_ai_prompt("explain_concept", prompt, callback)

func polish_card(draft_q: String, draft_a: String, callback: Callable = Callable()) -> void:
	if is_request_in_flight:
		if callback.is_valid():
			callback.call(false, {}, "Another request is already in progress.")
		return
		
	var prompt = """
Polish this flashcard into a clean, atomic active-recall question and answer adhering to SuperMemo principles.

Draft Question: %s
Draft Answer: %s

Return ONLY a valid JSON object with NO markdown formatting or backticks:
{
  "front": "Crisp Polished Question",
  "back": "Clear, concise Answer",
  "hint": "Brief memory clue",
  "subject": "Inferred Subject"
}
""" % [draft_q, draft_a]

	_retry_count = 0
	_send_ai_prompt("polish_card", prompt, callback)

# ==============================================================================
# 🛰️ REQUEST FORMATTING & RETRY
# ==============================================================================
const GEMINI_FALLBACK_MODELS: Array[String] = [
	"gemini-2.5-flash",
	"gemini-3.5-flash",
	"gemini-2.5-pro",
	"gemini-flash-latest",
	"gemini-2.0-flash",
	"gemini-1.5-flash"
]
var _gemini_model_index: int = 0
var _active_gemini_model: String = "gemini-2.5-flash"
var _cached_gemini_models: Array[String] = []
var _is_discovering_models: bool = false

func _send_ai_prompt(action_type: String, prompt: String, callback: Callable) -> void:
	if provider != Provider.OLLAMA and api_key.is_empty():
		var err = "API Key is required for %s. Please enter your API key!" % PROVIDER_NAMES[provider]
		_invoke_callback_failure(action_type, callback, err)
		return
		
	is_request_in_flight = true
	_current_action = action_type
	_current_prompt = prompt
	_active_callback = callback
	
	match provider:
		Provider.GEMINI:
			if custom_model.is_empty() and _cached_gemini_models.is_empty():
				_discover_gemini_models()
			else:
				_request_gemini(prompt)
		Provider.OPENAI:
			_request_openai(prompt)
		Provider.OLLAMA:
			_request_ollama(prompt)

func _discover_gemini_models() -> void:
	_is_discovering_models = true
	var url = "https://generativelanguage.googleapis.com/v1beta/models?key=%s" % api_key
	var headers = ["Content-Type: application/json"]
	var err = _http_client.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		_is_discovering_models = false
		_request_gemini(_current_prompt)

func _request_gemini(prompt: String) -> void:
	var model_name = custom_model if not custom_model.is_empty() else _active_gemini_model
	if model_name.begins_with("models/"):
		model_name = model_name.trim_prefix("models/")
	var url = "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s" % [model_name, api_key]
	var headers = ["Content-Type: application/json"]
	
	var gen_config: Dictionary = {
		"temperature": 0.2,
		"maxOutputTokens": 4096
	}
	if _current_action == "generate_cards" or _current_action == "polish_card" or _current_action == "test_ping":
		gen_config["responseMimeType"] = "application/json"
		
	var payload = {
		"contents": [
			{
				"parts": [
					{"text": prompt}
				]
			}
		],
		"generationConfig": gen_config
	}
	var json_body = JSON.stringify(payload)
	var err = _http_client.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if err != OK:
		print("[AIService] Gemini request dispatch failed with code: ", err)
		_handle_failure("Failed to dispatch Gemini HTTP request (Error Code: %d)" % err)

func _request_openai(prompt: String) -> void:
	var model_name = custom_model if custom_model != "" else "gpt-4o-mini"
	var url = "https://api.openai.com/v1/chat/completions"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer %s" % api_key
	]
	var payload = {
		"model": model_name,
		"messages": [
			{"role": "system", "content": "You are an expert educational study assistant. Return concise, accurate structured JSON."},
			{"role": "user", "content": prompt}
		],
		"temperature": 0.25
	}
	var json_body = JSON.stringify(payload)
	var err = _http_client.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if err != OK:
		_handle_failure("Failed to dispatch OpenAI HTTP request (Error Code: %d)" % err)

func _request_ollama(prompt: String) -> void:
	var model_name = custom_model if custom_model != "" else "llama3.2"
	var url = "http://localhost:11434/api/generate"
	var headers = ["Content-Type: application/json"]
	var payload = {
		"model": model_name,
		"prompt": prompt,
		"stream": false
	}
	var json_body = JSON.stringify(payload)
	var err = _http_client.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if err != OK:
		_handle_failure("Failed to connect to local Ollama at localhost:11434 (Error Code: %d)" % err)

# ==============================================================================
# 📥 RESPONSE PARSER & RETRY BACKOFF
# ==============================================================================
func _on_http_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	# 1. Handle Gemini Model Discovery Response
	if _is_discovering_models:
		_is_discovering_models = false
		var disc_body_text = body.get_string_from_utf8()
		if response_code >= 200 and response_code < 300:
			var disc_json = JSON.new()
			if disc_json.parse(disc_body_text) == OK and typeof(disc_json.data) == TYPE_DICTIONARY:
				var raw_models: Array = disc_json.data.get("models", [])
				_cached_gemini_models.clear()
				for m in raw_models:
					var methods = m.get("supportedGenerationMethods", [])
					if "generateContent" in methods:
						var m_name = str(m.get("name", "")).replace("models/", "")
						if not m_name.is_empty():
							_cached_gemini_models.append(m_name)
							
				# Choose best model from discovered models
				var best = ""
				for preferred in ["gemini-2.5-flash", "gemini-3.5-flash", "gemini-2.5-pro", "gemini-flash-latest", "gemini-2.0-flash", "gemini-1.5-flash"]:
					for avail in _cached_gemini_models:
						if avail == preferred or avail.begins_with(preferred):
							best = avail
							break
					if not best.is_empty():
						break
						
				if best.is_empty() and not _cached_gemini_models.is_empty():
					best = _cached_gemini_models[0]
					
				if not best.is_empty():
					_active_gemini_model = best
					
			# Now dispatch the prompt with the discovered model
			var t = get_tree().create_timer(0.05)
			t.timeout.connect(func():
				_request_gemini(_current_prompt)
			)
			return
		else:
			# Discovery failed (e.g. Invalid API Key) — report clear error
			is_request_in_flight = false
			var action = _current_action
			var callback = _active_callback
			_current_action = ""
			_current_prompt = ""
			_active_callback = Callable()
			var err_msg = "API Error (%d): %s" % [response_code, _extract_error_message(disc_body_text)]
			_invoke_callback_failure(action, callback, err_msg)
			return

	# 2. Check for Rate Limit (429) or Service Unavailable (503) and attempt exponential retry
	if (response_code == 429 or response_code == 503) and _retry_count < MAX_RETRIES:
		_retry_count += 1
		var backoff_sec = 1.5 * float(_retry_count)
		var t = get_tree().create_timer(backoff_sec)
		t.timeout.connect(func():
			_send_ai_prompt(_current_action, _current_prompt, _active_callback)
		)
		return
		
	# 3. Check for 404 on Gemini and automatically fallback to next model
	if response_code == 404 and provider == Provider.GEMINI and custom_model.is_empty() and _gemini_model_index < GEMINI_FALLBACK_MODELS.size() - 1:
		_gemini_model_index += 1
		_active_gemini_model = GEMINI_FALLBACK_MODELS[_gemini_model_index]
		var act = _current_action
		var prm = _current_prompt
		var cb = _active_callback
		var t = get_tree().create_timer(0.05)
		t.timeout.connect(func():
			_send_ai_prompt(act, prm, cb)
		)
		return

	is_request_in_flight = false
	var action = _current_action
	var callback = _active_callback
	_current_action = ""
	_current_prompt = ""
	_active_callback = Callable()
	
	if result != HTTPRequest.RESULT_SUCCESS:
		var err_msg = "Network request failed (HTTP Client Result: %d)" % result
		_invoke_callback_failure(action, callback, err_msg)
		return
		
	var body_text = body.get_string_from_utf8()
	if response_code < 200 or response_code >= 300:
		var err_msg = "API Error (%d): %s" % [response_code, _extract_error_message(body_text)]
		_invoke_callback_failure(action, callback, err_msg)
		return
		
	var json = JSON.new()
	if json.parse(body_text) != OK:
		var err_msg = "Failed to parse API response JSON"
		_invoke_callback_failure(action, callback, err_msg)
		return
		
	var raw_text: String = ""
	var dict: Dictionary = json.data
	
	match provider:
		Provider.GEMINI:
			var candidates = dict.get("candidates", [])
			if not candidates.is_empty():
				var parts = candidates[0].get("content", {}).get("parts", [])
				if not parts.is_empty():
					raw_text = parts[0].get("text", "")
		Provider.OPENAI:
			var choices = dict.get("choices", [])
			if not choices.is_empty():
				raw_text = choices[0].get("message", {}).get("content", "")
		Provider.OLLAMA:
			raw_text = dict.get("response", "")
			
	raw_text = _clean_markdown_fences(raw_text)
	_dispatch_parsed_result(action, raw_text, callback)

func _clean_markdown_fences(raw: String) -> String:
	var cleaned = raw.strip_edges()
	if cleaned.begins_with("```json"):
		cleaned = cleaned.trim_prefix("```json").strip_edges()
	elif cleaned.begins_with("```"):
		cleaned = cleaned.trim_prefix("```").strip_edges()
	if cleaned.ends_with("```"):
		cleaned = cleaned.trim_suffix("```").strip_edges()
		
	# If model returned text before/after JSON array, extract the array via regex
	if not cleaned.begins_with("[") and cleaned.contains("[") and cleaned.contains("]"):
		var start_idx = cleaned.find("[")
		var end_idx = cleaned.rfind("]")
		if start_idx != -1 and end_idx != -1 and end_idx > start_idx:
			cleaned = cleaned.substr(start_idx, end_idx - start_idx + 1)
			
	# If model returned text before/after JSON object, extract the object
	elif not cleaned.begins_with("{") and cleaned.contains("{") and cleaned.contains("}"):
		var start_idx = cleaned.find("{")
		var end_idx = cleaned.rfind("}")
		if start_idx != -1 and end_idx != -1 and end_idx > start_idx:
			cleaned = cleaned.substr(start_idx, end_idx - start_idx + 1)
			
	return cleaned

func _extract_error_message(body_text: String) -> String:
	var json = JSON.new()
	if json.parse(body_text) == OK and typeof(json.data) == TYPE_DICTIONARY:
		var d: Dictionary = json.data
		if d.has("error"):
			var err = d["error"]
			if typeof(err) == TYPE_DICTIONARY and err.has("message"):
				return err["message"]
			elif typeof(err) == TYPE_STRING:
				return err
	return body_text.substr(0, 180)

func _dispatch_parsed_result(action: String, content_text: String, callback: Callable) -> void:
	match action:
		"test_ping":
			_invoke_callback_success(action, callback, "Connected successfully!")
		"explain_concept":
			_invoke_callback_success(action, callback, content_text)
		"generate_cards":
			var raw_array: Array = []
			var json = JSON.new()
			var parse_err = json.parse(content_text)
			if parse_err == OK:
				if typeof(json.data) == TYPE_ARRAY:
					raw_array = json.data
				elif typeof(json.data) == TYPE_DICTIONARY:
					var dict: Dictionary = json.data
					for key in ["cards", "flashcards", "items", "deck", "data", "result", "questions"]:
						if dict.has(key) and typeof(dict[key]) == TYPE_ARRAY:
							raw_array = dict[key]
							break
					if raw_array.is_empty() and dict.has("front") and dict.has("back"):
						raw_array.append(dict)
			
			# Fallback 1: Extract all objects via balanced-brace stream parser
			if raw_array.is_empty():
				var extracted_objs = _extract_json_objects_from_text(content_text)
				for obj in extracted_objs:
					if typeof(obj) == TYPE_DICTIONARY:
						var dict: Dictionary = obj
						var found_inner = false
						for key in ["cards", "flashcards", "items", "deck", "data", "result", "questions"]:
							if dict.has(key) and typeof(dict[key]) == TYPE_ARRAY:
								raw_array.append_array(dict[key])
								found_inner = true
								break
						if not found_inner and (dict.has("front") or dict.has("question") or dict.has("q")):
							raw_array.append(dict)
			
			# Fallback 2: slice search for [...] array
			if raw_array.is_empty():
				var s_idx = content_text.find("[")
				var e_idx = content_text.rfind("]")
				if s_idx != -1 and e_idx != -1 and e_idx > s_idx:
					var sub = content_text.substr(s_idx, e_idx - s_idx + 1)
					if json.parse(sub) == OK and typeof(json.data) == TYPE_ARRAY:
						raw_array = json.data
			
			var validated_cards: Array = []
			for item in raw_array:
				if typeof(item) == TYPE_DICTIONARY:
					var q = str(item.get("front", item.get("question", item.get("prompt", item.get("q", ""))))).strip_edges()
					var a = str(item.get("back", item.get("answer", item.get("response", item.get("a", ""))))).strip_edges()
					var h = str(item.get("hint", item.get("mnemonic", item.get("clue", "")))).strip_edges()
					var s = str(item.get("subject", item.get("topic", item.get("category", "General")))).strip_edges()
					if not q.is_empty() and not a.is_empty():
						validated_cards.append({
							"front": q,
							"back": a,
							"hint": h,
							"subject": s
						})
						
			if not validated_cards.is_empty():
				_invoke_callback_success(action, callback, validated_cards)
				return
				
			var err_msg = "Failed to parse structured flashcards array from AI output"
			_invoke_callback_failure(action, callback, err_msg)
		"polish_card":
			var json = JSON.new()
			if json.parse(content_text) == OK and typeof(json.data) == TYPE_DICTIONARY:
				_invoke_callback_success(action, callback, json.data)
			else:
				var objs = _extract_json_objects_from_text(content_text)
				if not objs.is_empty() and typeof(objs[0]) == TYPE_DICTIONARY:
					_invoke_callback_success(action, callback, objs[0])
				else:
					var err_msg = "Failed to parse structured card JSON from AI output"
					_invoke_callback_failure(action, callback, err_msg)

func _extract_json_objects_from_text(text: String) -> Array:
	var objects: Array = []
	var depth = 0
	var start_idx = -1
	var in_string = false
	var escape = false
	
	for i in range(text.length()):
		var c = text[i]
		if escape:
			escape = false
			continue
		if c == "\\":
			escape = true
			continue
		if c == "\"":
			in_string = !in_string
			continue
		if in_string:
			continue
			
		if c == "{":
			if depth == 0:
				start_idx = i
			depth += 1
		elif c == "}":
			depth -= 1
			if depth == 0 and start_idx != -1:
				var obj_str = text.substr(start_idx, i - start_idx + 1)
				var json = JSON.new()
				if json.parse(obj_str) == OK and typeof(json.data) == TYPE_DICTIONARY:
					objects.append(json.data)
				start_idx = -1
				
	return objects

func _handle_failure(err_msg: String) -> void:
	is_request_in_flight = false
	var action = _current_action
	var callback = _active_callback
	_current_action = ""
	_current_prompt = ""
	_active_callback = Callable()
	_invoke_callback_failure(action, callback, err_msg)

func _invoke_callback_failure(action: String, callback: Callable, err_msg: String) -> void:
	if callback.is_valid():
		match action:
			"test_ping", "explain_concept":
				callback.call(false, err_msg)
			"generate_cards":
				callback.call(false, [], err_msg)
			"polish_card":
				callback.call(false, {}, err_msg)
			_:
				callback.call(false, err_msg)
	ai_response_received.emit(action, false, null, err_msg)

func _invoke_callback_success(action: String, callback: Callable, data: Variant) -> void:
	if callback.is_valid():
		match action:
			"test_ping":
				callback.call(true, "Connected successfully!")
			"explain_concept":
				callback.call(true, str(data))
			"generate_cards":
				var arr: Array = data as Array if typeof(data) == TYPE_ARRAY else []
				callback.call(true, arr, "")
			"polish_card":
				var dict: Dictionary = data as Dictionary if typeof(data) == TYPE_DICTIONARY else {}
				callback.call(true, dict, "")
			_:
				callback.call(true, data)
	ai_response_received.emit(action, true, data, "")
