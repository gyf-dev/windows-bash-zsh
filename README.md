# windows-bash-zsh

<p align="center">
  <img src="logo.png" alt="windows-bash-zsh logo" width="180">
</p>

<p align="center">
  <a href="README-EN.md">English</a> | 简体中文
</p>

为 Windows 快速配置 Git Bash 终端环境，包括 Zsh、Oh My Zsh、Starship 主题和常用插件。

## 功能特性

- **Starship 主题** - Catppuccin Mocha 配色，美观的命令行提示符
- **Zsh + Oh My Zsh** - 强大的 Shell 框架和插件管理
- **常用插件** - 自动建议、语法高亮、fzf 模糊搜索等
- **现代 CLI 工具** - 集成 bat、ripgrep、lsd、yazi 以及 yazi 预览依赖
- **open 命令** - 在 Windows 上提供类似 macOS 的 `open` 命令
- **一键配置** - 按照 SKILL.md 步骤操作即可完成配置

## 快速开始

查看 [SKILL.md](SKILL.md) 了解技能的触发场景和执行流程。

详细安装、更新、回退和排障步骤在 [references/setup-workflow.md](references/setup-workflow.md)。
可复用配置模板在 [assets](assets/) 目录：

- `starship.toml`：Starship 主题配置
- `bashrc-block.sh`：可幂等写入 `.bashrc` 的托管配置块
- `zshrc-block.zsh`：可幂等写入 `.zshrc` 的托管配置块
- `cli-tools-aliases.zsh`：现代 CLI 工具别名和 7-Zip PATH 片段
- `bat-config`：bat 推荐配置

现代 CLI 工具安装脚本在 [scripts/cli-tools.sh](scripts/cli-tools.sh)，支持 `install`、`status` 和 `uninstall`。

## 流程示意图

```mermaid
flowchart TB
  A["准备环境<br/>Windows / Git Bash / Nerd Font"]
  B["安装组件<br/>Starship / zsh / Oh My Zsh / CLI tools"]
  C["写入配置<br/>starship.toml / .bashrc / .zshrc"]
  D["终端体验<br/>美观提示符 / 自动建议 / 快速搜索"]

  A --> B --> C --> D

  classDef step fill:#0f172a,stroke:#38bdf8,stroke-width:1.5px,color:#f8fafc
  classDef done fill:#052e16,stroke:#22c55e,stroke-width:1.5px,color:#f0fdf4

  class A,B,C step
  class D done
```

## 环境要求

- Windows 10/11
- Git for Windows（Git Bash）
- Windows Package Manager（winget，用于安装 Starship 和 CLI 工具）
- Python 3（用于解压 zsh 包）
- 管理员权限（用于复制 zsh 文件到 Git 目录）

## 效果图

![windows-bash-zsh 效果图](效果图.png)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=gyf-dev/windows-bash-zsh&type=date&legend=top-left)](https://www.star-history.com/#gyf-dev/windows-bash-zsh&type=date&legend=top-left)
