# Kronos Project — Agent Rules

## Project Context
- **Engine:** Godot 4.7.1 (GDScript)
- **Art Style:** Pure procedural pixel art via `_draw()` — no external `.png` assets for environments
- **Architecture:** Rooms extend `BaseRoom`, pets use `PetRenderer.gd` + `PetBrain.gd`

## Godot Validation — Non-Negotiable

1. **After every GDScript edit**, run the syntax check before declaring success:
   ```powershell
   & "C:\Users\netne\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.1-stable_win64_console.exe" --headless --path "c:\Users\netne\Kronos\Kronos Project\kronos-godot" --check-only -s res://path/to/script.gd 2>&1
   ```
2. `EventBus` and `GameState` are **autoloads** — they will show "Identifier not found" in `--check-only` mode. That specific error is safe to ignore. Any other parse error is NOT.
3. **Never claim code works without verifying.** If the build tool fails, say so.

## Anti-Hallucination Guards

1. **Keep responses focused** — if the output starts drifting off-topic, stop and re-anchor to the task.
2. **One file at a time** — don't rewrite multiple large files in a single response without validating each.
3. **Show the error, then the fix** — when debugging, always quote the exact error before applying a patch.
4. **No phantom features** — don't describe visual results you haven't verified actually render.

## Code Standards (GDScript)

1. No `print()` in production — use signals or `EventBus` for communication.
2. Every `_process` / `_physics_process` must be intentional — don't add empty ones.
3. Use `queue_redraw()` not `update()` (Godot 4 API).
4. Use `set_deferred()` when modifying physics properties (`monitoring`, `monitorable`) during callbacks.
5. Procedural drawing must use `_draw()` with `draw_rect`, `draw_line`, `draw_circle`, `draw_colored_polygon` — no sprite loading for room environments.

## Release Workflow — "Push Release"

Whenever Kian asks to **"push release" / "release version" / "push released"**:
1. **Headless Export**: Export standalone binary via Godot 4 headless export:
   ```powershell
   & "C:\Users\netne\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.1-stable_win64_console.exe" --headless --path "c:\Users\netne\Kronos\Kronos Project\kronos-godot" --export-release "Windows Desktop" "../release/Kronos-v1.0-Windows/Kronos.exe"
   ```
2. **Package Zip**: Compress `release\Kronos-v1.0-Windows\*` into `release\Kronos-v1.0-Windows.zip`.
3. **Publish GitHub Release**: Create and publish the new release to GitHub Releases with the `.zip` attached:
   ```powershell
   gh release create "<tag>" "release\Kronos-v1.0-Windows.zip" --title "<title>" --notes "<changelog>"
   ```
4. Confirm URL on `github.com/Unlighted01/Kronos/releases`.
