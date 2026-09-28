# Kronos Asset Setup Script for PowerShell
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "[Kronos] Unpacking assets.zip into kronos-godot..." -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

if (-not (Test-Path "assets.zip")) {
    Write-Error "[ERROR] assets.zip not found in current directory!"
    exit 1
}

if (Get-Command tar -ErrorAction SilentlyContinue) {
    Write-Host "[Kronos] Extracting with tar..." -ForegroundColor Gray
    tar -xf assets.zip -C kronos-godot
} else {
    Write-Host "[Kronos] Extracting with PowerShell Expand-Archive..." -ForegroundColor Gray
    Expand-Archive -Path "assets.zip" -DestinationPath "kronos-godot" -Force
}

if (Test-Path "kronos-godot/assets") {
    Write-Host "[Kronos] Assets successfully unpacked into kronos-godot/assets!" -ForegroundColor Green
    Write-Host "Done! You can now open kronos-godot in Godot Engine." -ForegroundColor Green
} else {
    Write-Error "[ERROR] Failed to extract assets into kronos-godot/assets."
    exit 1
}
