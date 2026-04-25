# windows-bash-zsh

<p align="center">
  <img src="logo.png" alt="windows-bash-zsh logo" width="180">
</p>

<p align="center">
  English | <a href="README.md">简体中文</a>
</p>

Quickly configure a Git Bash terminal environment on Windows, including Zsh, Oh My Zsh, the Starship prompt, and common plugins.

## Features

- **Starship prompt**: Catppuccin Mocha color palette and a polished shell prompt.
- **Zsh + Oh My Zsh**: A powerful shell framework and plugin ecosystem.
- **Common plugins**: Autosuggestions, syntax highlighting, fzf fuzzy search, and more.
- **open command**: Adds a macOS-like `open` helper for Windows.
- **Guided setup**: Follow `SKILL.md` and the referenced workflow to complete the configuration.

## Quick Start

Read [SKILL.md](SKILL.md) to understand when the skill should trigger and how it works.

Detailed setup, update, rollback, and troubleshooting steps are in [references/setup-workflow.md](references/setup-workflow.md).
Reusable configuration templates are in [assets](assets/):

- `starship.toml`: Starship theme configuration.
- `bashrc-block.sh`: Managed `.bashrc` block for idempotent updates.
- `zshrc-block.zsh`: Managed `.zshrc` block for idempotent updates.

## Workflow Diagram

```mermaid
flowchart TB
  A["Prepare<br/>Windows / Git Bash / Nerd Font"]
  B["Install<br/>Starship / zsh / Oh My Zsh / fzf"]
  C["Configure<br/>starship.toml / .bashrc / .zshrc"]
  D["Experience<br/>Polished prompt / Suggestions / open command"]

  A --> B --> C --> D

  classDef step fill:#0f172a,stroke:#38bdf8,stroke-width:1.5px,color:#f8fafc
  classDef done fill:#052e16,stroke:#22c55e,stroke-width:1.5px,color:#f0fdf4

  class A,B,C step
  class D done
```

## Requirements

- Windows 10/11
- Git for Windows, including Git Bash
- Python 3 for extracting the zsh package
- Administrator permission for copying zsh files into the Git installation directory

## Screenshot

![windows-bash-zsh screenshot](效果图.png)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=gyf-dev/windows-bash-zsh&type=date&legend=top-left)](https://www.star-history.com/#gyf-dev/windows-bash-zsh&type=date&legend=top-left)
