# windows-bash-zsh

<p align="center">
  <img src="logo.png" alt="windows-bash-zsh logo" width="180">
</p>

<p align="center">
  <a href="README.md">English</a> | 简体中文
</p>

把 Windows 上的 Git Bash 打造成接近 macOS/Linux 体验的 zsh 终端环境：集成 Windows Terminal、Oh My Zsh、Starship、fzf、常用 zsh 插件，以及 bat、ripgrep、lsd、yazi 等现代 CLI 工具。

## 效果图

![windows-bash-zsh 效果图](screenshot.png)

## 演示视频

<p align="center">
  <video src="video.mp4" poster="screenshot.png" controls width="100%"></video>
</p>

[打开演示视频](video.mp4)

## 快速开始

### 下载或者克隆本项目到电脑上
```shell
 git clone https://github.com/gyf-dev/windows-bash-zsh.git
```

### 安装

PowerShell：

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\install.ps1
```

CMD：

```cmd
install.cmd
```

`install.cmd` 会优先调用同目录下的 `install.ps1`。如果当前电脑没有 `powershell.exe` 和 `pwsh.exe`，会自动切换到纯 CMD 兜底安装/卸载逻辑。

Bash：

```shell
bash install.sh
```

默认目标：

- Codex：`~\.codex\skills\windows-bash-zsh`
- Claude：`~\.claude\skills\windows-bash-zsh`
- Agents：`~\.agents\skills\windows-bash-zsh`
- Copilot：`~\.copilot\skills\windows-bash-zsh`

>**然后在对应的 Agent 平台上执行 `windows-bash-zsh` Skill，执行完成后，重新打开终端，就可以带来焕然一新的体验了。**

>**第一次打开终端有可能稍慢，后续再打开就正常了，原因是加载了一些 zsh 插件。如果不需要某些插件，请到 `.zshrc` 文件中删除 `plugins=(...)` 下的一些插件。**

### 卸载

PowerShell：

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\install.ps1 -Uninstall
```

CMD：

```cmd
install.cmd -Uninstall
```

Bash：

```shell
bash install.sh --uninstall
```

### 其他

PowerShell：

```powershell
# 只安装到指定目标，例如 Codex
powershell.exe -ExecutionPolicy Bypass -File .\install.ps1 -Targets codex

# 只从 Copilot 卸载
powershell.exe -ExecutionPolicy Bypass -File .\install.ps1 -Targets copilot -Uninstall

# 额外安装到自定义 skills 目录
powershell.exe -ExecutionPolicy Bypass -File .\install.ps1 -ExtraSkillRoots "D:\MyAgent\skills"
```

CMD：

```cmd
# 只安装到指定目标，例如 Codex
install.cmd -Targets codex

# 只从 Copilot 卸载
install.cmd -Targets copilot -Uninstall

# 额外安装到自定义 skills 目录
install.cmd -ExtraSkillRoots "D:\MyAgent\skills"
```

Bash：

```shell
# 只安装到指定目标，例如 Codex
bash install.sh --targets codex

# 只从 Copilot 卸载
bash install.sh --targets copilot --uninstall

# 额外安装到自定义 skills 目录
bash install.sh --extra-skill-roots "D:/MyAgent/skills"
```

`-ExtraSkillRoots` 是用户显式指定的目标；安装时如果目录不存在，脚本会创建它。安装遇到同名 Skill 时会询问是否替换，直接回车或输入 `y` 会覆盖，输入 `n` 会跳过。卸载时只删除目标目录下的 `windows-bash-zsh`，不会删除 skills 根目录。

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
