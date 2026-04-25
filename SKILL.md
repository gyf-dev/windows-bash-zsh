---
name: windows-bash-zsh
description: 在 Windows 的 Git Bash 中配置、修复或说明 zsh、Oh My Zsh、Starship、Nerd Font、fzf 和常用 zsh 插件。适用于用户要求安装或排查 Git Bash/zsh/Starship 终端环境，包括 .bashrc/.zshrc 配置、MSYS2 zsh 包安装、PATH 或字体问题、插件报错、UTF-8 编码问题、管理员复制步骤，以及从 zsh 回退到 Bash。
---

# Windows Bash Zsh

使用本技能帮助用户把 Windows 上的 Git Bash 配置成基于 zsh 的终端环境，并集成 Starship、Oh My Zsh、fzf 和常用插件。

## 操作规则

- 把所有 shell 配置文件都视为用户自有文件。编辑 `~/.bashrc` 和 `~/.zshrc` 前先备份，并保留无关的既有内容。
- 优先使用可重复执行的标记块，不要整文件覆盖。新增托管配置时使用标记名 `windows-bash-zsh`。
- 普通命令在 Git Bash 中执行。只有把 zsh 文件复制到 `C:\Program Files\Git\usr` 时才使用提权 PowerShell。
- 不要假设 MSYS2 的 zsh 包版本固定不变。下载前使用用户提供的固定包地址，或从 MSYS2 镜像中发现最新的 `zsh-*-x86_64.pkg.tar.zst`。
- shell 初始化阶段避免使用带空格的路径。把 `starship.exe` 复制到 `~/bin/starship.exe`，并把 `~/bin` 放在 `PATH` 前面。
- 编写 `.tar.zst` 解压代码时，解压前必须校验 tar 成员路径，避免路径穿越。
- 排障时按层验证：Git Bash 存在、Starship 能从 `~/bin` 运行、zsh 能运行、Oh My Zsh 存在、外部插件存在，最后再检查 profile 文件是否正确加载。

## 随附文件

- `assets/starship.toml`：Catppuccin Mocha 风格的 Starship 配置。
- `assets/bashrc-block.sh`：托管的 `.bashrc` 配置块，负责设置 UTF-8、暴露 `~/bin`，并在 zsh 可用时自动进入 zsh。
- `assets/zshrc-block.zsh`：托管的 `.zshrc` 配置块，包含 PATH、fzf、Oh My Zsh 插件、Starship 初始化，以及 Windows 上的 `open` 辅助命令。
- `references/setup-workflow.md`：详细安装、更新、回退和排障流程。

当用户需要逐步安装、排障或可执行命令时，读取 `references/setup-workflow.md`。当需要创建或更新配置文件时，直接使用 `assets/` 中的模板。

## 快速流程

1. 检查环境：
   - Windows 10/11。
   - 已安装 Git for Windows。
   - Git Bash 能运行 `bash --version`。
   - 如果使用 Python 解压路径，确认 `python3`、`python` 或 `py -3` 至少有一个可用。
2. 安装或确认 Nerd Font，例如 FiraCode Nerd Font Mono，然后提醒用户在 Git Bash 选项中选择该字体。
3. 使用 `winget install --id Starship.Starship` 安装 Starship，然后复制到 `~/bin/starship.exe`。
4. 下载 MSYS2 zsh 包，安全解压，并通过提权复制把解压后的 `usr` 目录合并到 `C:\Program Files\Git\usr`。
5. 安装 Oh My Zsh 和外部插件：
   - `zsh-autosuggestions`
   - `zsh-syntax-highlighting`
   - `fzf`
   - `you-should-use`
6. 使用随附模板更新 `~/.config/starship.toml`、`~/.bashrc` 和 `~/.zshrc`。
7. 打开新的 Git Bash 窗口并验证：
   - `zsh --version`
   - `~/bin/starship.exe --version`
   - `echo $SHELL`
   - `echo $ZSH_VERSION`

## 排障索引

- `zsh: no such file or directory: /c/Program`：Starship 正在从带空格的路径加载。确认 `~/bin/starship.exe` 存在，并且 profile 文件通过 `PATH` 调用 `starship`。
- `compinit: function definition file not found`：zsh 文件没有完整复制到 Git 的 `usr` 目录。重新执行提权复制步骤。
- `plugin not found`：确认插件目录存在于 `${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/` 下，并且目录名与 `.zshrc` 中的插件名一致。
- 图标显示为方框：安装 Nerd Font，并在 Git Bash 选项中选中该字体。
- 需要回到 Bash：只禁用 `.bashrc` 托管块里的 `exec zsh` 行，或删除整个 `windows-bash-zsh` 托管块。
