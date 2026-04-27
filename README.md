# windows-bash-zsh

<p align="center">
  <img src="logo.png" alt="windows-bash-zsh logo" width="180">
</p>

<p align="center">
  <a href="README-EN.md">English</a> | 简体中文
</p>

把 Windows 上的 Git Bash 打造成接近 macOS/Linux 体验的 zsh 终端环境：集成 Windows Terminal、Oh My Zsh、Starship、fzf、常用 zsh 插件，以及 bat、ripgrep、lsd、yazi 等现代 CLI 工具。

## 功能特性

- **Windows Terminal 集成**：添加 Git Bash profile，配置默认终端、字体和常用快捷键。
- **Zsh + Oh My Zsh**：在 Git Bash 中安装并启用 zsh、Oh My Zsh 和常用插件。
- **Starship 主题**：使用 Catppuccin Mocha 风格的提示符配置。
- **现代 CLI 工具**：集成 bat、ripgrep、lsd、yazi，以及 yazi 预览所需的 7-Zip、ImageMagick、FFmpeg。
- **macOS-like open**：在 Windows 中提供类似 macOS 的 `open` 命令。
- **幂等配置**：只补齐缺失配置，不整文件覆盖 `.bashrc`、`.zshrc`、Windows Terminal 或 VS Code 配置。

## 环境要求

- Windows 10/11
- Git for Windows（Git Bash）
- Windows Terminal：Windows 11 通常自带；Windows 10 可从 [Microsoft Terminal Releases](https://github.com/microsoft/terminal/releases/) 安装
- PowerShell：Windows PowerShell 5.1 即可；PowerShell 7 可选
- Windows Package Manager（winget，用于安装 Starship 和 CLI 工具）
- Python 3（用于安全解压 zsh 包）
- 管理员权限（用于把 zsh 文件复制到 Git 安装目录）

## 效果图

![windows-bash-zsh 效果图](效果图.png)

## 快速开始

### 下载或者克隆本项目到电脑上
```shell
 git clone git@github.com:gyf-dev/windows-bash-zsh.git
```

### 安装到skills中

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\install-to-skills.ps1
```

也可以使用 CMD 入口：

```cmd
install-to-skills.cmd
```

默认目标：

- Codex：`~\.codex\skills\windows-bash-zsh`
- Claude：`~\.claude\skills\windows-bash-zsh`
- Agents：`~\.agents\skills\windows-bash-zsh`
- Copilot：`~\.copilot\skills\windows-bash-zsh`

其他可选命令：

```powershell
# 只安装到 Codex
powershell.exe -ExecutionPolicy Bypass -File .\install-to-skills.ps1 -Targets codex
install-to-skills.cmd -Targets codex

# 只安装到 Copilot
powershell.exe -ExecutionPolicy Bypass -File .\install-to-skills.ps1 -Targets copilot
install-to-skills.cmd -Targets copilot

# 预览将要安装到哪里，不实际写入
powershell.exe -ExecutionPolicy Bypass -File .\install-to-skills.ps1 -DryRun
install-to-skills.cmd -DryRun

# 卸载默认目标中已安装的 windows-bash-zsh
powershell.exe -ExecutionPolicy Bypass -File .\install-to-skills.ps1 -Uninstall
install-to-skills.cmd -Uninstall

# 只从 Copilot 卸载
powershell.exe -ExecutionPolicy Bypass -File .\install-to-skills.ps1 -Targets copilot -Uninstall
install-to-skills.cmd -Targets copilot -Uninstall

# 额外安装到自定义 skills 目录
powershell.exe -ExecutionPolicy Bypass -File .\install-to-skills.ps1 -ExtraSkillRoots "D:\MyAgent\skills"
install-to-skills.cmd -ExtraSkillRoots "D:\MyAgent\skills"
```

`-ExtraSkillRoots` 是用户显式指定的目标；安装时如果目录不存在，脚本会创建它。卸载时只删除目标目录下的 `windows-bash-zsh`，不会删除备份目录或 skills 根目录。

## 流程示意图

```mermaid
flowchart LR
  A["准备<br/>PowerShell / Windows Terminal / Git Bash"]
  B["安装<br/>Starship / zsh / Oh My Zsh"]
  C["增强<br/>fzf / zsh plugins / CLI tools"]
  D["配置<br/>.bashrc / .zshrc / starship.toml"]
  E["验证<br/>新终端体验"]

  A --> B --> C --> D --> E

  classDef base fill:#0f172a,stroke:#38bdf8,stroke-width:1.5px,color:#f8fafc
  classDef final fill:#052e16,stroke:#22c55e,stroke-width:1.5px,color:#f0fdf4

  class A,B,C,D base
  class E final
```

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=gyf-dev/windows-bash-zsh&type=date&legend=top-left)](https://www.star-history.com/#gyf-dev/windows-bash-zsh&type=date&legend=top-left)
