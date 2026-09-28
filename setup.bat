@echo off
setlocal
echo ============================================================
echo [Kronos] Unpacking assets.zip into kronos-godot...
echo ============================================================

REM Check if assets.zip exists in current directory
if not exist "assets.zip" (
    echo [ERROR] assets.zip not found in current directory!
    pause
    exit /b 1
)

REM Use tar (built-in on Windows 10/11)
where tar >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [Kronos] Extracting with tar...
    tar -xf assets.zip -C kronos-godot
    if %ERRORLEVEL% EQU 0 (
        echo [Kronos] Assets successfully unpacked into kronos-godot/assets!
        goto done
    )
)

REM Fallback to PowerShell Expand-Archive
echo [Kronos] Using PowerShell fallback...
powershell -NoProfile -Command "Expand-Archive -Path 'assets.zip' -DestinationPath 'kronos-godot' -Force"
if %ERRORLEVEL% EQU 0 (
    echo [Kronos] Assets successfully unpacked into kronos-godot/assets!
) else (
    echo [ERROR] Failed to extract assets.zip. Please unzip assets.zip manually into kronos-godot/assets.
    pause
    exit /b 1
)

:done
echo.
echo ============================================================
echo [Kronos] Setup complete! You can now open kronos-godot in Godot.
echo ============================================================
pause
