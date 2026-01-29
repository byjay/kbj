# ============================================================
# === Claude Code Unified Installer (GLM-4.7 + Global Shims) ===
# ============================================================
# Features:
# 1. Global 'kbj' & 'claude' shims (CMD/PowerShell/Bash)
# 2. Automated Identity Patching (Sonnet 4.5 -> GLM-4.7)
# 3. Centralized API Config (~/.claude/keys.json)
# 4. Sub-Agent Support (-p flag)
# ============================================================

param(
    [Parameter(Mandatory = $false)]
    [string]$ApiKey
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n====================================" -ForegroundColor Cyan
Write-Host " KBJ (Anti-Gravity) Pro Installer" -ForegroundColor Cyan
Write-Host " Global Shims + Identity Patch" -ForegroundColor Green
Write-Host "====================================`n" -ForegroundColor Cyan

# [1] Env setup
$npmDir = "$env:APPDATA\npm"
$claudeOrig = "$npmDir\claude-orig.ps1"
$claudeBin = "$npmDir\node_modules\@anthropic-ai\claude-code\cli.js"
$claudeConfigDir = Join-Path $HOME ".claude"

# [2] Pre-checks
if (!(Test-Path $npmDir)) {
    Write-Host "Error: npm global directory not found." -ForegroundColor Red
    exit 1
}

# [3] API Key Setup
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    $ApiKey = Read-Host "  Enter your Z.ai (GLM) API Key"
}
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    Write-Host "Error: API Key required." -ForegroundColor Red
    exit 1
}

# [4] Backup & Rename Claude
Write-Host "`n[1/5] Patching Claude Entry Points..." -ForegroundColor Yellow
if (Test-Path "$npmDir\claude.ps1") {
    if (Test-Path $claudeOrig) { Remove-Item $claudeOrig -Force }
    Rename-Item "$npmDir\claude.ps1" "claude-orig.ps1" -Force
    Write-Host "  + claude.ps1 -> claude-orig.ps1" -ForegroundColor Green
}
if (Test-Path "$npmDir\claude.cmd") {
    if (Test-Path "$npmDir\claude-orig.cmd") { Remove-Item "$npmDir\claude-orig.cmd" -Force }
    Rename-Item "$npmDir\claude.cmd" "claude-orig.cmd" -Force
    Write-Host "  + claude.cmd -> claude-orig.cmd" -ForegroundColor Green
}

# [5] Identity Patching (GLM-4.7)
Write-Host "[2/5] Patching Model Identity (GLM-4.7)..." -ForegroundColor Yellow
if (Test-Path $claudeBin) {
    node -e "const fs = require('fs'); const path = '$($claudeBin.Replace('\','/'))'; if (fs.existsSync(path)) { let c = fs.readFileSync(path, 'utf8'); c = c.replace(/Claude Sonnet 4\.5/g, 'GLM-4.7').replace(/Sonnet 4\.5/g, 'GLM-4.7').replace(/api\.anthropic\.com/g, 'api.z.ai'); fs.writeFileSync(path, c); }"
    Write-Host "  + Identity & API Redirection Applied." -ForegroundColor Green
}

# [6] Centralized Key Config
Write-Host "[3/5] Setting up Centralized Config..." -ForegroundColor Yellow
if (-not (Test-Path $claudeConfigDir)) { New-Item -ItemType Directory -Path $claudeConfigDir -Force | Out-Null }
$keysJson = @{
    key1    = $ApiKey
    key2    = "a9bd9bd3917c4229a49f91747c4cf07e.PQBgL1cU7TqcNaBy"
    baseUrl = "https://api.z.ai/api/anthropic"
}
$keysJson | ConvertTo-Json | Set-Content (Join-Path $claudeConfigDir "keys.json") -Force
Write-Host "  + Config saved to ~/.claude/keys.json" -ForegroundColor Green

# [7] Generate Global Shims
Write-Host "[4/5] Generating Global Shims..." -ForegroundColor Yellow

# kbj.ps1
$kbjPs1 = @"
# Unified KBJ Shim
`$config = Get-Content (Join-Path `$HOME ".claude\keys.json") | ConvertFrom-Json
`$ApiKey1 = `$config.key1; `$ApiKey2 = `$config.key2; `$BaseUrl = `$config.baseUrl
`$claudePath = "`$env:APPDATA\npm\claude-orig.ps1"
`$isPrompt = `$false
foreach (`$arg in `$args) { if (`$arg -eq "-p" -or `$arg -eq "-P") { `$isPrompt = `$true; break } }
`$toggleFile = Join-Path `$HOME ".claude\key_toggle"
if (-not (Test-Path (Split-Path `$toggleFile))) { New-Item -ItemType Directory -Path (Split-Path `$toggleFile) -Force | Out-Null }
`$startIndex = 0; if (Test-Path `$toggleFile) { `$startIndex = [int](Get-Content `$toggleFile -Raw) }
`$maxRetries = 3; `$attempt = 0; `$success = `$false
while (`$attempt -le `$maxRetries -and -not `$success) {
    `$currentIndex = (`$startIndex + `$attempt) % 2
    `$currentKey = if (`$currentIndex -eq 0) { `$ApiKey1 } else { `$ApiKey2 }
    if (`$attempt -gt 0) { Write-Host "🔄 [Failover] Switching Key..." -ForegroundColor Yellow; Start-Sleep -Seconds 1 }
    `$env:ANTHROPIC_API_KEY = `$currentKey; `$env:ANTHROPIC_BASE_URL = `$BaseUrl; `$env:API_TIMEOUT_MS = "3000000"
    & `$claudePath @args
    if (`$LASTEXITCODE -eq 0) { `$success = `$true; Set-Content -Path `$toggleFile -Value `$currentIndex } else { `$attempt++ }
}
"@
Set-Content -Path "$npmDir\kbj.ps1" -Value $kbjPs1 -Encoding UTF8

# kbj.cmd
$kbjCmd = "@ECHO OFF`nSETLOCAL`npowershell -ExecutionPolicy Bypass -File ""%APPDATA%\npm\kbj.ps1"" %*`nENDLOCAL"
Set-Content -Path "$npmDir\kbj.cmd" -Value $kbjCmd -Encoding ASCII

# claude.ps1
$claudeShimPs1 = @"
if (`$args.Count -gt 0 -and `$args[0] -eq "--glm") { & "`$env:APPDATA\npm\kbj.ps1" `@args[1..(`$args.Count-1)] }
else { & "`$env:APPDATA\npm\claude-orig.ps1" `@args }
"@
Set-Content -Path "$npmDir\claude.ps1" -Value $claudeShimPs1 -Encoding UTF8

# claude.cmd
$claudeShimCmd = "@ECHO OFF`nSETLOCAL`npowershell -ExecutionPolicy Bypass -File ""%APPDATA%\npm\claude.ps1"" %*`nENDLOCAL"
Set-Content -Path "$npmDir\claude.cmd" -Value $claudeShimCmd -Encoding ASCII

Write-Host "  + Shims installed: kbj, claude (Supports -p flag)" -ForegroundColor Green

# [8] Skills
Write-Host "[5/5] Re-mapping Expert Skills..." -ForegroundColor Yellow
$genScript = Join-Path $PSScriptRoot "generate_skills.py"
if (Test-Path $genScript) { python $genScript }
Write-Host "  + Skills Mobilized." -ForegroundColor Green

Write-Host "`nInstallation Complete. Use 'kbj' for GLM-4.7 mode." -ForegroundColor Green
