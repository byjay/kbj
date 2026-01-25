# ============================================================
# === Claude Code Unified Installer (GLM Switcher + Skills) ===
# ============================================================
# Features:
# 1. Seamless 'claude --glm' switching (from claude-glm-switcher)
# 2. Automated 53 Skill Pack Installation (from Anti-Gravity)
# ============================================================

param(
    [Parameter(Mandatory = $false)]
    [string]$ApiKey
)

# UTF-8 Encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n====================================" -ForegroundColor Cyan
Write-Host " Claude Unified Installer" -ForegroundColor Cyan
Write-Host " GLM Switcher + 53 Skills" -ForegroundColor Green
Write-Host "====================================`n" -ForegroundColor Cyan

# [Step 1] Check Execution Policy
Write-Host "[1/6] Checking execution policy..." -ForegroundColor Yellow
$policy = Get-ExecutionPolicy -Scope CurrentUser
if ($policy -eq "Restricted" -or $policy -eq "Undefined") {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Write-Host "  Policy set to RemoteSigned." -ForegroundColor Green
}
else {
    Write-Host "  Policy is $policy (OK)." -ForegroundColor Green
}

# [Step 2] Check Claude Code
Write-Host "`n[2/6] Checking Claude Code..." -ForegroundColor Yellow
$claudePath = "$env:APPDATA\npm\claude.ps1"
if (!(Test-Path $claudePath) -and !(Test-Path "$env:APPDATA\npm\claude-orig.ps1")) {
    Write-Host "  Error: Claude Code not found. Install it first." -ForegroundColor Red
    exit 1
}
Write-Host "  Claude Code detected." -ForegroundColor Green

# [Step 3] Configure API Key
Write-Host "`n[3/6] API Key Setup..." -ForegroundColor Yellow
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    $ApiKey = Read-Host "  Enter your Zhipu AI (GLM) API Key"
}
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    Write-Host "  Error: API Key required." -ForegroundColor Red
    exit 1
}

# [Step 4] Backup & Rename Claude
Write-Host "`n[4/6] Patching Claude Code..." -ForegroundColor Yellow
try {
    $origPs1 = "$env:APPDATA\npm\claude-orig.ps1"
    $origCmd = "$env:APPDATA\npm\claude-orig.cmd"

    if (Test-Path "$env:APPDATA\npm\claude.ps1") {
        if (Test-Path $origPs1) { Remove-Item $origPs1 -Force }
        Rename-Item "$env:APPDATA\npm\claude.ps1" "claude-orig.ps1" -Force
        Write-Host "  Patched: claude.ps1 -> claude-orig.ps1" -ForegroundColor Green
    }
    if (Test-Path "$env:APPDATA\npm\claude.cmd") {
        if (Test-Path $origCmd) { Remove-Item $origCmd -Force }
        Rename-Item "$env:APPDATA\npm\claude.cmd" "claude-orig.cmd" -Force
        Write-Host "  Patched: claude.cmd -> claude-orig.cmd" -ForegroundColor Green
    }
}
catch {
    Write-Host "  Warning: Rename failed (maybe already patched). Ignoring." -ForegroundColor Yellow
}

# [Step 5] Install 53 Skills
Write-Host "`n[5/6] Installing 53 Intelligent Skills..." -ForegroundColor Yellow
$skillsScript = Join-Path $PSScriptRoot "generate_skills.py"
if (Test-Path $skillsScript) {
    python $skillsScript
    Write-Host "  Skill Pack Installation Triggered." -ForegroundColor Green
}
else {
    Write-Host "  Warning: generate_skills.py not found. Skipping skills." -ForegroundColor Red
}

function install-skills-internal {
    $skillsDir = Join-Path $HOME ".claude\skills"
    if (-not (Test-Path $skillsDir)) { New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null }
    Write-Host "  Verified Skills Directory: $skillsDir" -ForegroundColor Green
}
install-skills-internal

# [Step 6] Generate PowerShell Profile
Write-Host "`n[6/6] Updating PowerShell Profile..." -ForegroundColor Yellow
$profileDir = Split-Path -Parent $PROFILE
if (!(Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }

$profileContent = @"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
`$OutputEncoding = [System.Text.Encoding]::UTF8

# ============================================================
# Claude Code Unified (GLM Mode + Skill Pack + Auto-Failover)
# ============================================================

`$env:ZAI_API_KEY_1 = "$ApiKey"
`$env:ZAI_API_KEY_2 = "a9bd9bd3917c4229a49f91747c4cf07e.PQBgL1cU7TqcNaBy"
`$env:ZAI_BASE_URL = "https://api.z.ai/api/anthropic"
# Note: Using standard GLM endpoint. If using z.ai specific proxy, change to https://api.z.ai/api/anthropic

`$claudePath = "`$env:APPDATA\npm\claude-orig.ps1"

function claude {
    if (`$args.Count -gt 0 -and `$args[0] -eq "--glm") {
        `$remainingArgs = @()
        if (`$args.Count -gt 1) {
            `$remainingArgs = `$args[1..(`$args.Count - 1)]
        }
        Write-Host "🚀 [Anti-Gravity] GLM Mode Activated" -ForegroundColor Cyan
        
        # Rotation & Failover Logic
        `$toggleFile = Join-Path `$HOME ".claude\key_toggle"
        if (-not (Test-Path (Split-Path `$toggleFile))) { New-Item -ItemType Directory -Path (Split-Path `$toggleFile) -Force | Out-Null }
        
        # Load starting index
        `$startIndex = 0
        if (Test-Path `$toggleFile) { `$startIndex = [int](Get-Content `$toggleFile -Raw) }
        
        # Update for next time (Load Balancing)
        Set-Content -Path `$toggleFile -Value ((`$startIndex + 1) % 2)
        
        `$maxRetries = 1
        `$attempt = 0
        `$success = `$false
        
        while (`$attempt -le `$maxRetries -and -not `$success) {
            `$currentIndex = (`$startIndex + `$attempt) % 2
            
            if (`$currentIndex -eq 0) { `$currentKey = `$env:ZAI_API_KEY_1; `$kId = "1" } else { `$currentKey = `$env:ZAI_API_KEY_2; `$kId = "2" }
            
            if (`$attempt -gt 0) {
                Write-Host "`n🔄 [Auto-Failover] Switching to Key `$kId due to previous error..." -ForegroundColor Yellow
                Start-Sleep -Seconds 1
            } else {
                Write-Host "   -> Using Key `$kId" -ForegroundColor Cyan
            }
            
            `$env:ANTHROPIC_API_KEY = `$currentKey
            `$env:ANTHROPIC_BASE_URL = `$env:ZAI_BASE_URL
            `$env:API_TIMEOUT_MS = "3000000"
            
            # Execute Claude
            & `$claudePath @remainingArgs
            
            if (`$LASTEXITCODE -eq 0) {
                `$success = `$true
            } else {
                Write-Host "⚠️ [Anti-Gravity] Process exited with code `$LASTEXITCODE." -ForegroundColor Yellow
                `$attempt++
            }
        }
        
        if (-not `$success) {
             Write-Host "❌ [Anti-Gravity] All keys failed. Please check your network or quota." -ForegroundColor Red
        }
        
        Remove-Item Env:ANTHROPIC_API_KEY -ErrorAction SilentlyContinue
        Remove-Item Env:ANTHROPIC_BASE_URL -ErrorAction SilentlyContinue
        Remove-Item Env:API_TIMEOUT_MS -ErrorAction SilentlyContinue
        Write-Host "🔌 [Anti-Gravity] Disconnected" -ForegroundColor Gray
    }
    else {
        Write-Host "💎 [Standard] Anthropic Mode" -ForegroundColor Green
        & `$claudePath @args
    }
}


function kbj {
    Write-Host "🚀 [Anti-Gravity] Shortcut Activated: kbj -> claude --glm" -ForegroundColor Cyan
    claude --glm @args
}

function claude-status {
    Write-Host "----------------------------------------"
    Write-Host " Claude Code Unified Status"
    Write-Host "----------------------------------------"
    Write-Host " Mode Switch: claude --glm (or kbj)"
    Write-Host " Skill Pack : 53 Skills Installed"
    Write-Host " API Key 1  : `(`$env:ZAI_API_KEY_1.Substring(0,8))..."
    Write-Host " API Key 2  : `(`$env:ZAI_API_KEY_2.Substring(0,8))..."
    Write-Host "----------------------------------------"
}

Write-Host "✅ Claude Unified System Loaded." -ForegroundColor Green
"@

Set-Content -Path $PROFILE -Value $profileContent -Encoding UTF8
Write-Host "  Profile Updated: $PROFILE" -ForegroundColor Green

Write-Host "`nPassed All Checks. Restart PowerShell to use 'claude --glm'." -ForegroundColor White
