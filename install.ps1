# ============================================================
# === KBJ Global Installer (Anti-Gravity Core) ===
# ============================================================
# 1. Installs 'kbj', 'kbj-check', 'set-kbj-key' globally (CMD/PS/GitBash)
# 2. Injects Multi-Domain Expert Persona
# 3. Installs 53+ Coding Skills
# ============================================================

param(
    [Parameter(Mandatory = $false)]
    [string]$ApiKey
)

# Admin Check (Optional but recommended for robust writes)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) { Write-Host "Checking permissions... (Admin optional but recommended)" -ForegroundColor Yellow }

# [1] API Key Setup
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    $ApiKey = Read-Host "Enter your Zhipu AI (GLM) API Key (sk-...)"
}
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    Write-Host "Error: API Key is required." -ForegroundColor Red
    exit 1
}

# [2] Install Global Commands (in npm folder for PATH access)
$npmDir = "$env:APPDATA\npm"
if (-not (Test-Path $npmDir)) { New-Item -ItemType Directory -Path $npmDir -Force }

Write-Host "`n[1/3] Installing Global Commands..." -ForegroundColor Cyan

# --- kbj.cmd ---
$kbjContent = @"
@echo off
set ANTHROPIC_API_KEY=$ApiKey
set ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic
set API_TIMEOUT_MS=3000000
echo 🚀 Anti-Gravity Mode (KBJ)
echo 🧠 Global Skills Linked: 53 Packs (Ready to use)
if exist "%~dp0claude-orig.cmd" (
    "%~dp0claude-orig.cmd" %*
) else (
    claude %*
)
"@
Set-Content -Path "$npmDir\kbj.cmd" -Value $kbjContent -Encoding ASCII
Write-Host "  + Installed: kbj" -ForegroundColor Green

# --- kbj-check.cmd ---
$checkContent = @"
@echo off
echo ========================================
echo  Current Anti-Gravity Status (KBJ)
echo ========================================
echo  Command    : kbj
echo  API Config : GLM (Zhipu AI)
echo  Target URL : https://api.z.ai/api/anthropic
echo ========================================
"@
Set-Content -Path "$npmDir\kbj-check.cmd" -Value $checkContent -Encoding ASCII
Write-Host "  + Installed: kbj-check" -ForegroundColor Green

# --- set-kbj-key.cmd ---
$setKeyContent = @"
@echo off
if "%1"=="" (
echo Usage: set-kbj-key YOUR_SK_KEY
exit /b 1
)

set KEY=%1
set TARGET=%APPDATA%\npm\kbj.cmd

echo Updating Key for KBJ...
echo @echo off > "%TARGET%"
echo set ANTHROPIC_API_KEY=%KEY% >> "%TARGET%"
echo set ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic >> "%TARGET%"
echo set API_TIMEOUT_MS=3000000 >> "%TARGET%"
echo echo 🚀 Anti-Gravity Mode (KBJ) >> "%TARGET%"
echo echo 🧠 Global Skills Linked: 53 Packs (Ready to use) >> "%TARGET%"
echo if exist "%%~dp0claude-orig.cmd" ( >> "%TARGET%"
echo     "%%~dp0claude-orig.cmd" %%* >> "%TARGET%"
echo ) else ( >> "%TARGET%"
echo     claude %%* >> "%TARGET%"
echo ) >> "%TARGET%"   
echo ✅ Key Updated Successfully! Now run 'kbj'
"@
Set-Content -Path "$npmDir\set-kbj-key.cmd" -Value $setKeyContent -Encoding ASCII
Write-Host "  + Installed: set-kbj-key" -ForegroundColor Green

# [3] Inject Global Persona
Write-Host "`n[2/3] Injecting Multi-Domain Persona..." -ForegroundColor Cyan
$claudeDir = "$HOME\.claude"
if (-not (Test-Path $claudeDir)) { New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null }

$personaContent = @"
# KBJ Global Persona (Anti-Gravity Core)

## 🎭 Identity (페르소나)
당신은 **글로벌 Top-tier 시니어 엔지니어링 아키텍트**이자 **미래 기술 전략가**입니다.
단순한 코딩을 넘어, 다음 3가지 핵심 도메인에 정통한 **'마스터(Master)'** 레벨입니다.

1.  **AI & LLM 기술**: 최신 AI 트렌드, RAG, 에이전트 아키텍처, 모델 튜닝
2.  **조선/해양 플랜트 기술 (K-Shipbuilding)**: 선박 설계, 스마트 야드, 생산 공정 최적화
3.  **첨단 소프트웨어 공학**: 클린 아키텍처, MSA, 고성능 분산 시스템

## ⚡ Speed & Efficiency (속도와 효율)
- **Extreme Speed**: 답변은 군더더기 없이 **즉답(Direct Answer)** 형태로 시작하십시오.
- **No Fluff**: 불필요한 서론/본론/결론 형식을 피하고, **핵심 코드와 솔루션** 위주로 제시하십시오.

## 🇰🇷 Language (언어 정책)
- **Must Use KOREAN**: 모든 기술적 설명, 주석, 답변은 **반드시 '한국어'**로 작성하십시오.

## 🛠 Coding Standards (코딩 원칙)
- **Solid & Safe**: 프로덕션 레벨의 안전성(Security)과 견고성(Robustness)을 기본으로 합니다.
- **Modern Stack**: 항상 최신 안정화(Stable) 버전을 기준으로 작성하십시오.

## 🧰 Skill Usage (스킬 사용 원칙)
- **Primary Source**: 답변 작성 시 반드시 `C:\Users\FREE\.claude\skills` 경로의 53개 전문 스킬을 최우선으로 참조하십시오.
- **Automated Activation**: 질문의 문맥에 맞는 스킬이 있다면 즉시 인용하고 적용하십시오.

## 🧠 Memory & Context
- 이 설정은 `C:\Users\FREE\.claude\CLAUDE.md`에 위치한 전역 설정입니다.
"@
Set-Content -Path "$claudeDir\CLAUDE.md" -Value $personaContent -Encoding UTF8
Write-Host "  + Persona Updated: $claudeDir\CLAUDE.md" -ForegroundColor Green

# [4] Install Skills
Write-Host "`n[3/3] Installing 53 Skills..." -ForegroundColor Cyan
$genScript = Join-Path $PSScriptRoot "generate_skills.py"
if (Test-Path $genScript) {
    python $genScript
    Write-Host "  + Skills Generated." -ForegroundColor Green
} else {
    Write-Host "  ! Warning: generate_skills.py not found in current folder." -ForegroundColor Yellow
    # Fallback: Check if we are running from web (this part assumes local for now)
}

Write-Host "`n✅ KBJ Installation Complete!" -ForegroundColor Green
Write-Host "Type 'kbj' to start coding."
