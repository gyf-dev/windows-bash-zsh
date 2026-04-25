# windows-bash-zsh

[English](README-EN.md) | 简体中文

为 Windows 快速配置 Git Bash 终端环境，包括 Zsh、Oh My Zsh、Starship 主题和常用插件。

## 功能特性

- **Starship 主题** - Catppuccin Mocha 配色，美观的命令行提示符
- **Zsh + Oh My Zsh** - 强大的 Shell 框架和插件管理
- **常用插件** - 自动建议、语法高亮、fzf 模糊搜索等
- **open 命令** - 在 Windows 上提供类似 macOS 的 `open` 命令
- **一键配置** - 按照 SKILL.md 步骤操作即可完成配置

## 快速开始

查看 [SKILL.md](SKILL.md) 了解技能的触发场景和执行流程。

详细安装、更新、回退和排障步骤在 [references/setup-workflow.md](references/setup-workflow.md)。
可复用配置模板在 [assets](assets/) 目录：

- `starship.toml`：Starship 主题配置
- `bashrc-block.sh`：可幂等写入 `.bashrc` 的托管配置块
- `zshrc-block.zsh`：可幂等写入 `.zshrc` 的托管配置块

## 流程示意图

```mermaid
flowchart LR
  subgraph P["准备环境"]
    A["Windows 10/11"]
    B["Git Bash"]
    C["Nerd Font"]
  end

  subgraph I["安装核心组件"]
    D["Starship"]
    E["zsh"]
    F["Oh My Zsh"]
    G["fzf 与常用插件"]
  end

  subgraph Cfg["写入托管配置"]
    H["starship.toml"]
    I1[".bashrc 托管块"]
    J[".zshrc 托管块"]
  end

  subgraph R["最终体验"]
    K["美观提示符"]
    L["自动建议与语法高亮"]
    M["macOS-like open 命令"]
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

## 环境要求

- Windows 10/11
- Git for Windows（Git Bash）
- Python 3（用于解压 zsh 包）
- 管理员权限（用于复制 zsh 文件到 Git 目录）

## 效果图

![windows-bash-zsh 效果图](效果图.png)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=gyf-dev/windows-bash-zsh&type=date&legend=top-left)](https://www.star-history.com/#gyf-dev/windows-bash-zsh&type=date&legend=top-left)
