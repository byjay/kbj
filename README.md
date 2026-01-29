# KBJ (Anti-Gravity) Installer

An optimized wrapper for Claude Code using **GLM-4.7 (Z.ai Pro)** for cost-effective, high-performance coding.

## 🚀 Quick Install (One-Line)
Run this command in PowerShell (Admin not required):

```powershell
iex (irm https://raw.githubusercontent.com/byjay/kbj/main/install_unified.ps1)
```

## ✨ Features
1. **Engine**: **GLM-4.7** (Automatically patched identity)
2. **Commands**: 
   - `kbj`: Interactive coding mode
   - `kbj -p "prompt"`: Sub-agent/Prompt mode (Immediate response)
   - `claude --glm`: Native switcher support
3. **Failover**: Proactive Active-Passive API key rotation
4. **Skills**: 53+ Supreme Expert Skills pre-loaded
5. **Universal**: Works in CMD, PowerShell, Git Bash, and VS Code

## 🛠 Advanced Usage
- **Update Primary Key**: `kbj -p "set key sk-..."` or edit `~/.claude/keys.json`
- **Check Status**: `kbj -p "check status"`

## 🧠 Centralized Control
All project-agnostic assets are stored in `~/.claude/`:
- `keys.json`: API credentials
- `CLAUDE.md`: Global persona & instructions
- `skills/`: Expert skill packs

---
*Maintained by Supreme Commander.*
