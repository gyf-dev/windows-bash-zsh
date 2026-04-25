# windows-bash-zsh

English | [简体中文](README.md)

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
flowchart LR
  subgraph P["Prepare"]
    A["Windows 10/11"]
    B["Git Bash"]
    C["Nerd Font"]
  end

  subgraph I["Install Core"]
    D["Starship"]
    E["zsh"]
    F["Oh My Zsh"]
    G["fzf and plugins"]
  end

  subgraph Cfg["Managed Config"]
    H["starship.toml"]
    I1[".bashrc block"]
    J[".zshrc block"]
  end

  subgraph R["Result"]
    K["Polished prompt"]
    L["Autosuggestions and highlighting"]
    M["macOS-like open command"]
  end

  A --> B --> C --> D --> E --> F --> G --> H
  H --> I1
  I1 --> J
  J --> K
  J --> L
  J --> M

  classDef prep fill:#e0f2fe,stroke:#0284c7,color:#0f172a
  classDef install fill:#fef3c7,stroke:#d97706,color:#0f172a
  classDef config fill:#ede9fe,stroke:#7c3aed,color:#0f172a
  classDef result fill:#dcfce7,stroke:#16a34a,color:#0f172a

  class A,B,C prep
  class D,E,F,G install
  class H,I1,J config
  class K,L,M result
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
