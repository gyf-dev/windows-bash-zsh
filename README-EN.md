# windows-bash-zsh

<p align="center">
  <img src="logo.png" alt="windows-bash-zsh logo" width="180">
</p>

<p align="center">
  English | <a href="README.md">简体中文</a>
</p>

Turn Git Bash on Windows into a zsh terminal environment close to the macOS/Linux experience: Windows Terminal, Oh My Zsh, Starship, fzf, common zsh plugins, and modern CLI tools such as bat, ripgrep, lsd, and yazi.

## Features

- **Windows Terminal integration**: Add a Git Bash profile, configure the default terminal, font, and common shortcuts.
- **Zsh + Oh My Zsh**: Install and enable zsh, Oh My Zsh, and common plugins inside Git Bash.
- **Starship prompt**: Use a Catppuccin Mocha style prompt configuration.
- **Modern CLI tools**: Integrate bat, ripgrep, lsd, yazi, plus yazi preview dependencies: 7-Zip, ImageMagick, and FFmpeg.
- **macOS-like open**: Provide a macOS-like `open` command on Windows.
- **Idempotent configuration**: Fill in missing configuration only; do not overwrite `.bashrc`, `.zshrc`, Windows Terminal, or VS Code settings.

## Requirements

- Windows 10/11
- Git for Windows, including Git Bash
- Windows Terminal: usually bundled with Windows 11; Windows 10 users can install it from [Microsoft Terminal Releases](https://github.com/microsoft/terminal/releases/)
- PowerShell: Windows PowerShell 5.1 is enough; PowerShell 7 is optional
- Windows Package Manager, winget, for installing Starship and CLI tools
- Python 3 for safely extracting the zsh package
- Administrator permission for copying zsh files into the Git installation directory

## Screenshot

![windows-bash-zsh screenshot](效果图.png)

## Quick Start

### Download or clone this project to your computer

```shell
git clone git@github.com:gyf-dev/windows-bash-zsh.git
```

### Install into skills

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\install-to-skills.ps1
```

You can also use the CMD entry:

```cmd
install-to-skills.cmd
```

Default targets:

- Codex: `~\.codex\skills\windows-bash-zsh`
- Claude: `~\.claude\skills\windows-bash-zsh`
- Agents: `~\.agents\skills\windows-bash-zsh`
- Copilot: `~\.copilot\skills\windows-bash-zsh`

Other optional commands:

```powershell
# Install only to Codex
powershell.exe -ExecutionPolicy Bypass -File .\install-to-skills.ps1 -Targets codex
install-to-skills.cmd -Targets codex

# Install only to Copilot
powershell.exe -ExecutionPolicy Bypass -File .\install-to-skills.ps1 -Targets copilot
install-to-skills.cmd -Targets copilot

# Preview target paths without writing files
powershell.exe -ExecutionPolicy Bypass -File .\install-to-skills.ps1 -DryRun
install-to-skills.cmd -DryRun

# Uninstall windows-bash-zsh from default targets
powershell.exe -ExecutionPolicy Bypass -File .\install-to-skills.ps1 -Uninstall
install-to-skills.cmd -Uninstall

# Uninstall only from Copilot
powershell.exe -ExecutionPolicy Bypass -File .\install-to-skills.ps1 -Targets copilot -Uninstall
install-to-skills.cmd -Targets copilot -Uninstall

# Also install to a custom skills directory
powershell.exe -ExecutionPolicy Bypass -File .\install-to-skills.ps1 -ExtraSkillRoots "D:\MyAgent\skills"
install-to-skills.cmd -ExtraSkillRoots "D:\MyAgent\skills"
```

`-ExtraSkillRoots` is an explicit target; during installation, the script creates it when it does not exist. During uninstall, only the `windows-bash-zsh` directory under the target root is removed; backup directories and the skills root are kept.

## Workflow Diagram

```mermaid
flowchart LR
  A["Prepare<br/>PowerShell / Windows Terminal / Git Bash"]
  B["Install<br/>Starship / zsh / Oh My Zsh"]
  C["Enhance<br/>fzf / zsh plugins / CLI tools"]
  D["Configure<br/>.bashrc / .zshrc / starship.toml"]
  E["Verify<br/>New terminal experience"]

  A --> B --> C --> D --> E

  classDef base fill:#0f172a,stroke:#38bdf8,stroke-width:1.5px,color:#f8fafc
  classDef final fill:#052e16,stroke:#22c55e,stroke-width:1.5px,color:#f0fdf4

  class A,B,C,D base
  class E final
```

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=gyf-dev/windows-bash-zsh&type=date&legend=top-left)](https://www.star-history.com/#gyf-dev/windows-bash-zsh&type=date&legend=top-left)
