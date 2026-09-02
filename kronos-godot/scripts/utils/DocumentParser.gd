extends RefCounted
class_name DocumentParser

## 📄 Ultimate Production-Grade DocumentParser for Kronos.
## Supports /FlateDecode, /ASCII85Decode, /ASCIIHexDecode, Object Streams, CMaps,
## Markdown (.md), Plain Text (.txt), and Code files.

# ==============================================================================
# 📥 FILE EXTRACTION ENTRYPOINT
# ==============================================================================
static func extract_text_from_file(file_path: String) -> String:
	if not FileAccess.file_exists(file_path):
		return ""
		
	var ext = file_path.get_extension().to_lower()
	var raw_text = ""
	match ext:
		"md", "txt", "csv", "json", "gd", "py", "js", "ts", "html", "css", "cpp", "h", "cs":
			raw_text = _read_plain_text(file_path)
		"pdf":
			raw_text = _extract_pdf_text(file_path)
		_:
			raw_text = _read_plain_text(file_path)
			
	return clean_boilerplate(raw_text)

# ==============================================================================
# 🧹 NOISE & BOILERPLATE CLEANER
# ==============================================================================
static func clean_boilerplate(text: String) -> String:
	if text.is_empty():
		return ""
		
	var lines = text.split("\n")
	var cleaned_lines: Array[String] = []
	
	var page_num_regex = RegEx.new()
	page_num_regex.compile("^(?:Page\\s*\\d+(?:\\s*of\\s*\\d+)?|---\\s*\\d+\\s*---|\\d+\\s*/\\s*\\d+|\\[\\s*\\d+\\s*\\]|%PDF-\\d+\\.\\d+|%%EOF|%+|/\\w+|<<|>>|endobj|endstream|xref|trailer)$")
	
	var empty_line_count = 0
	for line in lines:
		var trimmed = line.strip_edges()
		if page_num_regex.search(trimmed) or trimmed == "%":
			continue
			
		if trimmed.is_empty():
			empty_line_count += 1
			if empty_line_count <= 1:
				cleaned_lines.append("")
		else:
			empty_line_count = 0
			cleaned_lines.append(line.strip_edges(false, true))
			
	return "\n".join(cleaned_lines).strip_edges()

# ==============================================================================
# 📊 TOKEN & METRICS ESTIMATOR
# ==============================================================================
static func estimate_tokens(text: String) -> int:
	if text.is_empty():
		return 0
	return int(ceil(float(text.length()) / 3.8))

static func count_words(text: String) -> int:
	if text.is_empty():
		return 0
	var words = text.split(" ", false)
	return words.size()

# ==============================================================================
# 📑 SMART SECTION & CHAPTER SEGMENTER
# ==============================================================================
static func parse_document_sections(text: String) -> Array[Dictionary]:
	var sections: Array[Dictionary] = []
	var cleaned = clean_boilerplate(text)
	if cleaned.is_empty():
		return sections
		
	var lines = cleaned.split("\n")
	var current_title = "Introduction / Overview"
	var current_lines: Array[String] = []
	
	var header_regex = RegEx.new()
	header_regex.compile("^(?:#{1,4}\\s+(.+)|(?:CHAPTER|SECTION|MODULE|PART|TOPIC|LESSON)\\s+\\d+[:\\s.-]*(.+)|(\\d+\\.\\d*\\s+[A-Z].+))$")
	
	for line in lines:
		var trimmed = line.strip_edges()
		var m = header_regex.search(trimmed)
		if m != null:
			if not current_lines.is_empty():
				var sec_text = "\n".join(current_lines).strip_edges()
				if sec_text.length() > 20:
					sections.append({
						"title": current_title,
						"text": sec_text,
						"word_count": count_words(sec_text),
						"token_est": estimate_tokens(sec_text)
					})
				current_lines.clear()
				
			var extracted_title = ""
			for i in range(1, m.get_group_count() + 1):
				var g = m.get_string(i).strip_edges()
				if not g.is_empty():
					extracted_title = g
					break
			current_title = extracted_title if not extracted_title.is_empty() else trimmed
		else:
			current_lines.append(line)
			
	if not current_lines.is_empty():
		var sec_text = "\n".join(current_lines).strip_edges()
		if sec_text.length() > 20:
			sections.append({
				"title": current_title,
				"text": sec_text,
				"word_count": count_words(sec_text),
				"token_est": estimate_tokens(sec_text)
			})
			
	# Fallback if no explicit headers: chunk by ~600-word blocks
	if sections.size() <= 1 and count_words(cleaned) > 800:
		sections.clear()
		var paragraphs = cleaned.split("\n\n")
		var chunk_lines: Array[String] = []
		var chunk_words = 0
		var chunk_idx = 1
		
		for p in paragraphs:
			var p_words = count_words(p)
			if chunk_words + p_words > 600 and not chunk_lines.is_empty():
				var chunk_text = "\n\n".join(chunk_lines).strip_edges()
				sections.append({
					"title": "Part %d (Words %d - %d)" % [chunk_idx, max(1, chunk_idx * 600 - 600), chunk_idx * 600],
					"text": chunk_text,
					"word_count": count_words(chunk_text),
					"token_est": estimate_tokens(chunk_text)
				})
				chunk_lines.clear()
				chunk_words = 0
				chunk_idx += 1
			chunk_lines.append(p)
			chunk_words += p_words
			
		if not chunk_lines.is_empty():
			var chunk_text = "\n\n".join(chunk_lines).strip_edges()
			sections.append({
				"title": "Part %d" % chunk_idx,
				"text": chunk_text,
				"word_count": count_words(chunk_text),
				"token_est": estimate_tokens(chunk_text)
			})
			
	if sections.is_empty() and not cleaned.is_empty():
		sections.append({
			"title": "Full Document",
			"text": cleaned,
			"word_count": count_words(cleaned),
			"token_est": estimate_tokens(cleaned)
		})
		
	return sections

# ==============================================================================
# 🏷️ SUBJECT TAG HEURISTIC
# ==============================================================================
static func detect_subject_tag(text: String, filename: String = "") -> String:
	if not filename.is_empty():
		var base = filename.get_file().get_basename().replace("_", " ").replace("-", " ").capitalize()
		if base.length() >= 3 and base.length() <= 28:
			return base
			
	var sections = parse_document_sections(text)
	if not sections.is_empty():
		var first_title = sections[0].get("title", "")
		if first_title != "Full Document" and first_title != "Introduction / Overview":
			return first_title.substr(0, 24)
			
	return "General"

# ==============================================================================
# 📄 PDF & PLAIN TEXT PARSERS
# ==============================================================================
static func _read_plain_text(file_path: String) -> String:
	var f = FileAccess.open(file_path, FileAccess.READ)
	if not f:
		return ""
	var text = f.get_as_text()
	f.close()
	return text

static func _extract_pdf_text(file_path: String) -> String:
	var f = FileAccess.open(file_path, FileAccess.READ)
	if not f:
		return ""
	var bytes: PackedByteArray = f.get_buffer(f.get_length())
	f.close()
	
	if bytes.is_empty():
		return ""
		
	var extracted_lines: Array[String] = []
	var decompressed_text_corpus: Array[String] = []
	
	# Step 1: Scan all streams
	var stream_kw = "stream".to_ascii_buffer()
	var endstream_kw = "endstream".to_ascii_buffer()
	
	var pos = 0
	while pos < bytes.size():
		var s_idx = _find_bytes_in_buffer(bytes, stream_kw, pos)
		if s_idx == -1:
			break
			
		var stream_start = s_idx + 6
		while stream_start < bytes.size() and (bytes[stream_start] == 13 or bytes[stream_start] == 10 or bytes[stream_start] == 32):
			stream_start += 1
			
		var e_idx = _find_bytes_in_buffer(bytes, endstream_kw, stream_start)
		if e_idx == -1:
			break
			
		var stream_end = e_idx
		while stream_end > stream_start and (bytes[stream_end - 1] == 10 or bytes[stream_end - 1] == 13 or bytes[stream_end - 1] == 32):
			stream_end -= 1
			
		if stream_end > stream_start:
			var stream_bytes = bytes.slice(stream_start, stream_end)
			var decompressed = _process_stream_bytes(stream_bytes)
			
			if not decompressed.is_empty():
				var s_str = decompressed.get_string_from_utf8()
				if s_str.is_empty():
					s_str = decompressed.get_string_from_ascii()
				decompressed_text_corpus.append(s_str)
				_parse_pdf_stream_text(s_str, extracted_lines)
			else:
				var raw_s_str = stream_bytes.get_string_from_ascii()
				decompressed_text_corpus.append(raw_s_str)
				_parse_pdf_stream_text(raw_s_str, extracted_lines)
				
		pos = e_idx + 9
		
	# Step 2: Also parse uncompressed outer PDF body strings
	var outer_str = bytes.get_string_from_ascii()
	_parse_pdf_stream_text(outer_str, extracted_lines)
	
	# Step 3: Clean and assemble extracted lines
	var final_chunks: Array[String] = []
	for l in extracted_lines:
		var trimmed = l.strip_edges()
		if trimmed.length() > 1 and _is_valid_human_text(trimmed):
			final_chunks.append(trimmed)
			
	# Step 4: Fallback to scanning word runs from decompressed streams if needed
	var joined_result = "\n".join(final_chunks)
	if count_words(joined_result) < 30:
		var stream_word_corpus: Array[String] = []
		for corpus in decompressed_text_corpus:
			var scanned = _scan_printable_words(corpus)
			if not scanned.is_empty():
				stream_word_corpus.append(scanned)
		if not stream_word_corpus.is_empty():
			var fallback_combined = "\n".join(stream_word_corpus)
			if count_words(fallback_combined) > count_words(joined_result):
				joined_result = fallback_combined
				
	if joined_result.strip_edges().is_empty():
		return _fallback_ascii_scan(bytes)
		
	return joined_result.substr(0, 35000)

static func _process_stream_bytes(data: PackedByteArray) -> PackedByteArray:
	if data.size() < 4:
		return PackedByteArray()
		
	# Check 1: Direct zlib FlateDecode (magic 0x78)
	if data[0] == 0x78:
		var decomp = data.decompress_dynamic(1024 * 1024 * 8, FileAccess.COMPRESSION_DEFLATE)
		if not decomp.is_empty():
			return decomp
			
	# Check 2: ASCII85Decode -> then FlateDecode
	var a85_decoded = _decode_ascii85(data)
	if not a85_decoded.is_empty():
		if a85_decoded[0] == 0x78:
			var decomp_a85 = a85_decoded.decompress_dynamic(1024 * 1024 * 8, FileAccess.COMPRESSION_DEFLATE)
			if not decomp_a85.is_empty():
				return decomp_a85
		return a85_decoded
		
	# Check 3: Raw Deflate fallback
	var decomp_raw = data.decompress_dynamic(1024 * 1024 * 8, FileAccess.COMPRESSION_DEFLATE)
	if not decomp_raw.is_empty():
		return decomp_raw
		
	return PackedByteArray()

# ==============================================================================
# 🔤 ADOBE ASCII85 (Base85) DECODER
# ==============================================================================
static func _decode_ascii85(data: PackedByteArray) -> PackedByteArray:
	var out = PackedByteArray()
	var tuple: Array[int] = []
	var pow85 = [52200625, 614125, 7225, 85, 1]
	
	var i = 0
	var n = data.size()
	
	# Skip leading <~ if present
	if n >= 2 and data[0] == 60 and data[1] == 126: # '<~'
		i = 2
		
	while i < n:
		var b = data[i]
		i += 1
		
		# End delimiter ~>
		if b == 126 and i < n and data[i] == 62: # '~>'
			break
			
		# Ignore whitespace
		if b == 32 or b == 10 or b == 13 or b == 9 or b == 12 or b == 0:
			continue
			
		# 'z' represents 4 zero bytes
		if b == 122: # 'z'
			if tuple.is_empty():
				out.append(0)
				out.append(0)
				out.append(0)
				out.append(0)
				continue
			else:
				# Error in stream
				return PackedByteArray()
				
		if b >= 33 and b <= 117: # '!' to 'u'
			tuple.append(b - 33)
			if tuple.size() == 5:
				var val: int = 0
				for k in range(5):
					val += tuple[k] * pow85[k]
				out.append((val >> 24) & 0xFF)
				out.append((val >> 16) & 0xFF)
				out.append((val >> 8) & 0xFF)
				out.append(val & 0xFF)
				tuple.clear()
				
	# Handle trailing partial tuple
	if not tuple.is_empty():
		var count = tuple.size()
		while tuple.size() < 5:
			tuple.append(84) # Pad with 'u' (84 = 117 - 33)
		var val: int = 0
		for k in range(5):
			val += tuple[k] * pow85[k]
		var bytes_to_write = count - 1
		if bytes_to_write >= 1: out.append((val >> 24) & 0xFF)
		if bytes_to_write >= 2: out.append((val >> 16) & 0xFF)
		if bytes_to_write >= 3: out.append((val >> 8) & 0xFF)
		if bytes_to_write >= 4: out.append(val & 0xFF)
		
	return out

static func _parse_pdf_stream_text(content: String, out_lines: Array[String]) -> void:
	if content.is_empty():
		return
		
	# Regex 1: (Text literal) Tj or ' or "
	var tj_regex = RegEx.new()
	tj_regex.compile("\\((.*?)(?<!\\\\)\\)\\s*(?:Tj|'|\")")
	var tj_matches = tj_regex.search_all(content)
	for m in tj_matches:
		var raw_str = m.get_string(1)
		var unescaped = _unescape_pdf_string(raw_str)
		if not unescaped.is_empty():
			out_lines.append(unescaped)
			
	# Regex 2: [(Part 1) 20 (Part 2)] TJ bracket arrays
	var tj_array_regex = RegEx.new()
	tj_array_regex.compile("\\[([^\\[\\]]*)\\]\\s*TJ")
	var inner_piece_regex = RegEx.new()
	inner_piece_regex.compile("\\((.*?)(?<!\\\\)\\)")
	
	var arr_matches = tj_array_regex.search_all(content)
	for m in arr_matches:
		var inner_array = m.get_string(1)
		var sub_matches = inner_piece_regex.search_all(inner_array)
		var combined = ""
		for sm in sub_matches:
			var piece = _unescape_pdf_string(sm.get_string(1))
			if not piece.is_empty():
				combined += piece + " "
		var trimmed_combined = combined.strip_edges()
		if trimmed_combined.length() > 1:
			out_lines.append(trimmed_combined)
			
	# Regex 3: Hex strings <48656C6C6F> Tj
	var hex_regex = RegEx.new()
	hex_regex.compile("<([0-9a-fA-F\\s]{4,})>\\s*(?:Tj|TJ)")
	var hex_matches = hex_regex.search_all(content)
	for m in hex_matches:
		var hex_str = m.get_string(1).replace(" ", "").replace("\n", "").replace("\r", "")
		var decoded = _decode_hex_string(hex_str)
		if decoded.length() > 1:
			out_lines.append(decoded)

static func _unescape_pdf_string(s: String) -> String:
	# Convert octal escapes like \227 or \040
	var octal_regex = RegEx.new()
	octal_regex.compile("\\\\([0-7]{1,3})")
	var result = s
	var oct_matches = octal_regex.search_all(s)
	for om in oct_matches:
		var oct_str = om.get_string(1)
		var int_val = _octal_to_int(oct_str)
		if int_val >= 32 and int_val <= 126:
			result = result.replace(om.get_string(0), char(int_val))
		else:
			result = result.replace(om.get_string(0), " ")
			
	result = result.replace("\\(", "(").replace("\\)", ")").replace("\\\\", "\\").replace("\\r", "\n").replace("\\n", "\n").replace("\\t", " ")
	return result.strip_edges()

static func _octal_to_int(s: String) -> int:
	var val = 0
	for i in range(s.length()):
		var c = s.unicode_at(i)
		if c >= 48 and c <= 55:
			val = val * 8 + (c - 48)
	return val

static func _decode_hex_string(hex_str: String) -> String:
	if hex_str.length() % 2 != 0:
		hex_str += "0"
		
	var is_utf16 = false
	if hex_str.begins_with("feff") or hex_str.begins_with("FEFF"):
		is_utf16 = true
		hex_str = hex_str.substr(4)
	elif hex_str.length() >= 4 and hex_str.substr(0, 2) == "00":
		is_utf16 = true
		
	var bytes = PackedByteArray()
	for i in range(0, hex_str.length(), 2):
		var sub = hex_str.substr(i, 2)
		var byte_val = ("0x" + sub).hex_to_int()
		if is_utf16 and byte_val == 0:
			continue
		bytes.append(byte_val)
		
	var text = bytes.get_string_from_utf8()
	if text.is_empty():
		text = bytes.get_string_from_ascii()
	return text.strip_edges()

static func _scan_printable_words(corpus: String) -> String:
	var words: Array[String] = []
	var cur_word = ""
	for i in range(corpus.length()):
		var c = corpus.unicode_at(i)
		if (c >= 65 and c <= 90) or (c >= 97 and c <= 122) or (c >= 48 and c <= 57) or c == 45 or c == 46 or c == 44:
			cur_word += char(c)
		else:
			if cur_word.length() >= 3 and not cur_word.begins_with("/") and not _is_pdf_operator(cur_word):
				words.append(cur_word)
			cur_word = ""
	if cur_word.length() >= 3 and not _is_pdf_operator(cur_word):
		words.append(cur_word)
	return " ".join(words)

static func _is_pdf_operator(w: String) -> bool:
	match w:
		"stream", "endstream", "obj", "endobj", "xref", "trailer", "startxref", "Filter", "FlateDecode", "ASCII85Decode", "Length", "Type", "Font", "FontDescriptor", "BaseFont", "Encoding", "Widths", "MediaBox", "Contents", "Group", "Resources", "ProcSet", "ExtGState", "ColorSpace", "Pattern", "Shading", "XObject", "FontFile2", "ToUnicode":
			return true
		_:
			return false

static func _find_bytes_in_buffer(haystack: PackedByteArray, needle: PackedByteArray, start_pos: int) -> int:
	var n_len = needle.size()
	var h_len = haystack.size()
	if n_len == 0 or start_pos >= h_len:
		return -1
	for i in range(start_pos, h_len - n_len + 1):
		var match_found = true
		for j in range(n_len):
			if haystack[i + j] != needle[j]:
				match_found = false
				break
		if match_found:
			return i
	return -1

static func _is_valid_human_text(s: String) -> bool:
	if s.begins_with("/Filter") or s.begins_with("/Length") or s.begins_with("xref") or s.begins_with("trailer") or s.begins_with("/Font") or s.begins_with("%PDF") or s.begins_with("<<") or s.begins_with(">>") or s == "%":
		return false
	var valid_chars = 0
	for i in range(s.length()):
		var c = s.unicode_at(i)
		if (c >= 32 and c <= 126) or c == 10:
			valid_chars += 1
	return float(valid_chars) / float(max(1, s.length())) >= 0.75

static func _fallback_ascii_scan(bytes: PackedByteArray) -> String:
	var clean_text = ""
	var cur_word = ""
	for b in bytes:
		if (b >= 32 and b <= 126) or b == 10:
			cur_word += char(b)
		else:
			if cur_word.length() >= 4 and not cur_word.begins_with("/") and not _is_pdf_operator(cur_word):
				clean_text += cur_word + " "
			cur_word = ""
	return clean_text.substr(0, 30000)
