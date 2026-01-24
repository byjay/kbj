# KBJ (Anti-Gravity) Installer

An optimized wrapper for Claude Code using Zhipu AI (GLM) for cost-effective coding.

## 🚀 Quick Install (One-Line)
Run this command in PowerShell (Admin not required):

```powershell
iex (irm https://raw.githubusercontent.com/byjay/kbj/main/install.ps1)
```

## ✨ Features
1. **Command**: `kbj` (Runs Claude Code in GLM Mode)
2. **Cost Saving**: Reduces API costs by ~85% (vs Claude Official)
3. **Skills**: Pre-installs 53+ expert coding skills
4. **Safety**: Does not interfere with existing global Claude installations


## 🛠 Detailed Setup Guide (상세 설정법)

### 1. Prerequisites (준비물)
- **Node.js**: [Download Here](https://nodejs.org/) (LTS Version recommended)
- **Z.ai API Key**: Get it from [Z.ai Platform](https://z.ai/)

### 2. Installation (설치)
1. Open PowerShell.
2. Run the one-line installer above.
3. If asked for an API key, enter your Z.ai key starting with `sk-...`

### 3. Usage (사용법)
- **Basic Run**: `kbj`
- **Use Thinking Model**: `kbj --model claude-3-5-sonnet-20241022` (Or user preferred model)
  > **Note**: To use "Thinking" capabilities, you can prompt the model: "Think step-by-step before answering."
- **Check Status**: `kbj-check`

### 4. Troubleshooting (문제 해결)
- If you see "Auth error", run: `set-kbj-key YOUR_NEW_KEY`
- If you see "Command not found", restart your terminal.

## 🧠 Advanced: Switching Models
To use a specific model (e.g., if you have access to a Thinking model or higher tier):
```powershell
kbj --model <MODEL_NAME>
```
Example: `kbj --model claude-3-5-sonnet-20241022`
