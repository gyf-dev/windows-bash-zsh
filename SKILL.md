---
name: windows-bash-zsh
description: 在 Windows 中配置、修复或说明 Git Bash zsh 终端环境，涵盖 Windows Terminal、Oh My Zsh、Starship、Nerd Font、VS Code 终端、fzf、常用 zsh 插件，以及 bat、ripgrep、lsd、yazi 等现代 CLI 工具。适用于 Windows Bash/zsh/Starship 安装、MSYS2 zsh 包安装、.bashrc/.zshrc 修改、UTF-8 或 PATH 问题、Windows Terminal Git Bash profile、CLI alias、插件报错，以及回退到 Bash。
---

# Windows Bash Zsh

帮助用户把 Windows 上的 Git Bash 配置成接近 macOS/Linux 体验的 zsh 终端，并集成 Oh My Zsh、Starship、fzf、常用插件、Windows
Terminal 和可选现代 CLI 工具。

## 核心规则

- 把 `~/.bashrc`、`~/.zshrc`、Windows Terminal `settings.json`、VS Code `settings.json` 都视为用户自有文件。编辑前先备份，保留无关内容，只做定点幂等修改。
- 禁止整文件覆盖 profile 或 settings。只能更新目标配置块、目标键，或 `plugins=(...)` 中缺失的插件。
- 完整配置时必须把 Windows Terminal 的 `defaultProfile` 设置为 Git Bash profile 的 `guid`；只有用户明确要求保留现有默认终端时才跳过。
- 保留 Oh My Zsh 模板注释和结构。`.zshrc` 只补插件、Starship、fzf、autosuggest 样式、`open()` 和 CLI alias 受管块。
- zsh 安装优先采用 `references/zsh-on-windows-without-wsl.md` 的 Git Bash 无 WSL 流程：下载最新 MSYS2
  `zsh-*-x86_64.pkg.tar.zst`，用 PeaZip 解压到能看到 `etc` 和 `usr`，再把两个目录合并到 `C:\Program Files\Git`。忽略文章中的
  Powerlevel10k 步骤，本技能使用 Starship。
- 不要硬编码 MSYS2 zsh 版本；使用 MSYS2 package repository 最新包，或用户提供的固定包地址。
- Windows PowerShell 5.1 已够用，PowerShell 7 可选。只有 `powershell.exe` 和 `pwsh.exe` 都不可用时，才引导安装 PowerShell。
- 把 `starship.exe` 复制到 `~/bin/starship.exe`，并让 `~/bin` 靠前进入 `PATH`，避免 shell 初始化阶段加载带空格的 Windows
  路径。
- 安装或完整配置现代 CLI 工具时，运行 `scripts/cli-tools.sh`，并把 `assets/cli-tools-aliases.zsh` 合并到 `~/.zshrc` 末尾，使
  `cat` 使用 bat、`ls/ll/la/lt/l` 使用 lsd、`ya` 使用 yazi。只有用户明确要求保留既有 alias 时，才不覆盖。
- 只有用户明确要求全命令行自动化时才用 Python 解压 `.tar.zst`；若使用，必须先校验 tar 成员路径，并仍然合并 `etc` 和 `usr` 到
  `C:\Program Files\Git`。
- 排障按层验证：Git Bash、`~/bin` 中的 Starship、zsh、Oh My Zsh、外部插件、CLI 工具、profile 加载。

## 资源

- `references/setup-workflow.md`：详细安装、更新、回退和排障流程。需要给出可执行步骤时先读取它。
- `references/zsh-on-windows-without-wsl.md`：zsh 在 Windows Git Bash 无 WSL 环境下安装的来源流程；使用其中 zsh 安装方式，忽略
  Powerlevel10k。
- `assets/bashrc-block.sh`：`.bashrc` 托管块，处理 UTF-8、`~/bin`、Starship bash init 和进入 zsh。
- `assets/zshrc-block.zsh`：`.zshrc` 最小补充块，处理 PATH、fzf、Starship zsh init、autosuggest 样式和 Windows `open()`。
- `assets/zsh-plugins.txt`：期望启用的 Oh My Zsh 插件列表，用于合并到现有 `plugins=(...)`。
- `assets/cli-tools-aliases.zsh`：bat、lsd、yazi 和 7-Zip PATH 的 marker 受管块，用于 `.zshrc` 末尾。
- `assets/starship.toml`、`assets/bat-config`、`assets/windows-terminal-*.json`、`assets/vscode-terminal-settings.json`
  ：按需复制或合并。
- `scripts/cli-tools.sh`：bat、ripgrep、lsd、yazi 及 yazi 预览依赖的状态检查、安装和卸载脚本。

## 默认流程

1. 检查 Windows 10/11、Git for Windows、Git Bash、Windows Terminal、PowerShell、`winget.exe`、Nerd Font。
2. 添加或更新 Windows Terminal Git Bash profile：`C:\Program Files\Git\bin\bash.exe -l -i`、启动目录 `%USERPROFILE%`、Nerd
   Font，并在完整配置时设为默认 profile。
3. 用 winget 安装 Starship，复制到 `~/bin`，写入 `~/.config/starship.toml`。
4. 安装 zsh：下载 MSYS2 zsh 包，用 PeaZip 解压，把 `etc` 和 `usr` 合并到 `C:\Program Files\Git`。
5. 安装 Oh My Zsh 和外部插件：`zsh-autosuggestions`、`zsh-syntax-highlighting`、`fzf`、`you-should-use`。
6. 用随附 assets 幂等更新 `~/.bashrc`、`~/.zshrc` 和插件列表。
7. 若用户要完整配置或现代 CLI 工具，安装 bat、ripgrep、lsd、yazi、7-Zip、ImageMagick、FFmpeg，并合并 CLI alias 受管块。
8. 打开新终端验证：
    - `zsh --version`
    - `~/bin/starship.exe --version`
    - `echo $ZSH_VERSION`
    - `bat --version`、`rg --version`、`lsd --version`、`yazi --version`
    - `alias cat`、`alias ls`、`alias ll`
    - Windows Terminal `defaultProfile` 指向 Git Bash profile 的 `guid`
    - `~/.bashrc` 和 `~/.zshrc` 中关键 marker 或片段存在

## 常见修复

- `zsh: no such file or directory: /c/Program`：Starship 从带空格路径加载了。改为通过 `PATH` 使用 `~/bin/starship.exe`。
- `compinit: function definition file not found`：zsh 文件没完整合并。重新解压 MSYS2 zsh 包，把 `etc` 和 `usr` 都合并到
  `C:\Program Files\Git`。
- `plugin not found`：检查 `${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/` 下插件目录名是否与 `.zshrc` 一致。
- 图标是方框：安装 Nerd Font，并在 Git Bash 或 Windows Terminal 里选中该字体。
- bat、rg、lsd、yazi 安装后不可用：重启 Git Bash 或运行 `exec zsh`，再检查 `PATH` 和 `winget.exe list --id <包 ID> --exact`。
- yazi 预览失败：检查 `7z`、`magick`、`ffmpeg`、`ffprobe`；只有 `/c/Program Files/7-Zip` 存在时才追加到 `PATH`。
- 回退 Bash：只禁用 `.bashrc` 中受管 `exec zsh` 行，或删除本技能受管块；保留用户内容。
