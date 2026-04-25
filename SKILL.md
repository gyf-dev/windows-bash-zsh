---
name: windows-bash-zsh
description: 在 Windows 中配置、修复或说明 Git Bash、Windows Terminal、PowerShell、zsh、Oh My Zsh、Starship、Nerd Font、VS Code 终端、fzf 和常用 zsh 插件。适用于用户要求安装或排查 Windows Bash/zsh/Starship 终端环境，包括 Windows Terminal 添加 Git Bash profile、设置默认终端、快捷键、中文乱码、VS Code 默认终端、.bashrc/.zshrc 配置、MSYS2 zsh 包安装、PATH 或字体问题、插件报错、UTF-8 编码问题、管理员复制步骤，以及从 zsh 回退到 Bash。
---

# Windows Bash Zsh

使用本技能帮助用户把 Windows 上的 Git Bash 配置成基于 zsh 的终端环境，并集成 Starship、Oh My Zsh、fzf 和常用插件。

## 操作规则

- 把所有 shell 配置文件都视为用户自有文件。编辑 `~/.bashrc` 和 `~/.zshrc` 前必须先备份，并保留无关的既有内容。
- 禁止整文件覆盖 `~/.bashrc`、`~/.zshrc` 或其他用户 profile 文件。必须保留已有内容，包括注释、空行、alias、PATH、历史配置和用户手写片段。
- 必须使用定点幂等修改。已有目标配置时只更新对应配置项；缺失时只追加缺失片段；不得为了写入本技能配置而删除或重排用户原有内容。
- `.zshrc` 是 Oh My Zsh 模板文件时，不要把整个模板搬进新增片段，也不要删除模板注释。必须做定点幂等编辑：保留原文件结构，只更新 `plugins=(...)` 中缺失的插件，并只补充缺失的 Starship、fzf、autosuggest 样式和 `open()` 辅助函数。
- 普通命令在 Git Bash 中执行。只有把 zsh 文件复制到 `C:\Program Files\Git\usr` 时才使用提权 PowerShell。
- 所有配置前先检查 PowerShell 和 Windows Terminal。Windows PowerShell 5.1 已满足本技能需要；`pwsh.exe`/PowerShell 7 是可选项。只有 `powershell.exe` 和 `pwsh.exe` 都不可用时，才从 `https://github.com/PowerShell/PowerShell/releases` 安装 PowerShell。Windows 11 默认自带 Windows Terminal；Windows 10 若没有 Windows Terminal，需要从 Microsoft Store 或 `https://github.com/microsoft/terminal/releases/` 安装。
- 检查 PowerShell 版本时，`powershell.exe` 只代表 Windows PowerShell 5.1；PowerShell 7 要查 `pwsh.exe`。如果 Git Bash 找不到 `pwsh.exe`，先试完整路径 `/c/Program Files/PowerShell/7/pwsh.exe`，不要直接判定未安装。
- 修改 Windows Terminal `settings.json` 前必须备份，不要整文件覆盖；只合并 Git Bash profile、默认 profile、快捷键和粘贴/复制相关字段。
- 不要假设 MSYS2 的 zsh 包版本固定不变。下载前使用用户提供的固定包地址，或从 MSYS2 镜像中发现最新的 `zsh-*-x86_64.pkg.tar.zst`。
- shell 初始化阶段避免使用带空格的路径。把 `starship.exe` 复制到 `~/bin/starship.exe`，并把 `~/bin` 放在 `PATH` 前面。
- 验证时发现 `~/.bashrc` 缺少本技能需要的启动配置时，只能补齐缺失片段；不要整文件覆盖，也不要只提示“可能没问题”。尤其 `~/.bashrc` 必须包含 `chcp 65001` UTF-8 设置。验证 `.zshrc` 时优先修复具体缺失项，不要用 `assets/zshrc-block.zsh` 覆盖用户原有 Oh My Zsh 模板内容。
- 编写 `.tar.zst` 解压代码时，解压前必须校验 tar 成员路径，避免路径穿越。
- 排障时按层验证：Git Bash 存在、Starship 能从 `~/bin` 运行、zsh 能运行、Oh My Zsh 存在、外部插件存在，最后再检查 profile 文件是否正确加载。

## 随附文件

- `assets/starship.toml`：Catppuccin Mocha 风格的 Starship 配置。
- `assets/windows-terminal-git-bash-profile.json`：Windows Terminal 的 Git Bash profile 示例，命令行包含 `-l -i`。
- `assets/windows-terminal-actions.json`：Windows Terminal 快捷键示例，包含复制、粘贴和 `Alt+1` 到 `Alt+9` 标签页切换。
- `assets/vscode-terminal-settings.json`：VS Code 集成终端设置示例，把默认 Windows 终端设为 Git Bash。
- `assets/bashrc-block.sh`：托管的 `.bashrc` 配置块，负责设置 UTF-8、暴露 `~/bin`，并在 zsh 可用时自动进入 zsh。
- `assets/zsh-plugins.txt`：期望启用的 Oh My Zsh 插件列表。用于幂等更新现有 `plugins=(...)`，不要整段重写 `.zshrc`。
- `assets/zshrc-block.zsh`：`.zshrc` 的最小托管补充块，只包含 PATH、fzf、Starship 初始化、autosuggest 样式和 Windows 上的 `open` 辅助命令；不包含 Oh My Zsh 模板、`plugins=(...)` 或 `source $ZSH/oh-my-zsh.sh`。
- `references/setup-workflow.md`：详细安装、更新、回退和排障流程。

当用户需要逐步安装、排障或可执行命令时，读取 `references/setup-workflow.md`。当需要创建或更新配置文件时，直接使用 `assets/` 中的模板。

## 快速流程

1. 检查环境：
   - Windows 10/11。
   - PowerShell 可用；Windows PowerShell 5.1 即可，PowerShell 7 可选。
   - Windows Terminal 可用；Windows 11 默认自带，Windows 10 如不可用则从 Microsoft Store 或 `https://github.com/microsoft/terminal/releases/` 安装。
   - 已安装 Git for Windows。
   - Git Bash 能运行 `bash --version`。
   - 如果使用 Python 解压路径，确认 `python3`、`python` 或 `py -3` 至少有一个可用。
2. 把 Git Bash 添加到 Windows Terminal，使用 `C:\Program Files\Git\bin\bash.exe -l -i`，启动目录设为 `%USERPROFILE%`，并按需设为默认 profile。
3. 安装或确认 Nerd Font，例如 FiraCode Nerd Font Mono，然后提醒用户在 Git Bash 或 Windows Terminal 选项中选择该字体。
4. 使用 `winget install --id Starship.Starship` 安装 Starship，然后复制到 `~/bin/starship.exe`。
5. 下载 MSYS2 zsh 包，安全解压，并通过提权复制把解压后的 `usr` 目录合并到 `C:\Program Files\Git\usr`。
6. 安装 Oh My Zsh 和外部插件：
   - `zsh-autosuggestions`
   - `zsh-syntax-highlighting`
   - `fzf`
   - `you-should-use`
7. 使用随附模板更新 `~/.config/starship.toml`、`~/.bashrc` 和 `~/.zshrc`。
8. 打开新的 Windows Terminal / Git Bash 窗口并验证：
   - `zsh --version`
   - `~/bin/starship.exe --version`
   - `echo $SHELL`
   - `echo $ZSH_VERSION`

## 排障索引

- `zsh: no such file or directory: /c/Program`：Starship 正在从带空格的路径加载。确认 `~/bin/starship.exe` 存在，并且 profile 文件通过 `PATH` 调用 `starship`。
- `compinit: function definition file not found`：zsh 文件没有完整复制到 Git 的 `usr` 目录。重新执行提权复制步骤。
- `plugin not found`：确认插件目录存在于 `${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/` 下，并且目录名与 `.zshrc` 中的插件名一致。
- 图标显示为方框：安装 Nerd Font，并在 Git Bash 选项中选中该字体。
- 需要回到 Bash：只禁用 `.bashrc` 中由本技能添加的 `exec zsh` 行，或删除本技能添加的相关配置片段。
