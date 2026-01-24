# ============================================================
# === KBJ Uninstaller (Anti-Gravity Removal) ===
# ============================================================
# Removes kbj, kbj-check, set-kbj-key and restores original Claude
# ============================================================

$npmDir = "$env:APPDATA\npm"

Write-Host "`n[1/3] Removing KBJ Commands..." -ForegroundColor Cyan
Remove-Item "$npmDir\kbj.cmd" -ErrorAction SilentlyContinue
Remove-Item "$npmDir\kbj-check.cmd" -ErrorAction SilentlyContinue
Remove-Item "$npmDir\set-kbj-key.cmd" -ErrorAction SilentlyContinue
Write-Host "  - Removed: kbj commands" -ForegroundColor Yellow

Write-Host "`n[2/3] Restoring Original Claude..." -ForegroundColor Cyan
if (Test-Path "$npmDir\claude-orig.cmd") {
    Move-Item "$npmDir\claude-orig.cmd" "$npmDir\claude.cmd" -Force
    Write-Host "  + Restored: claude.cmd" -ForegroundColor Green
}
if (Test-Path "$npmDir\claude-orig.ps1") {
    Move-Item "$npmDir\claude-orig.ps1" "$npmDir\claude.ps1" -Force
    Write-Host "  + Restored: claude.ps1" -ForegroundColor Green
}

Write-Host "`n[3/3] Cleaning up Profile..." -ForegroundColor Cyan
$profileContent = Get-Content $PROFILE -Raw
if ($profileContent -match "Claude Code Unified") {
    # This is a simple check; for safety we just warn user to check profile
    Write-Host "  ! NOTE: Please manually check your PowerShell Profile ($PROFILE) to remove any leftover aliases if needed." -ForegroundColor Yellow
}

Write-Host "`n✅ Uninstallation Complete. You are back to standard gravity." -ForegroundColor Green
