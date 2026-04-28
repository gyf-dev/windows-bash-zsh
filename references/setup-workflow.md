# Windows Bash Zsh 配置流程

当用户需要具体命令、逐步安装、更新、回退或排障时使用本流程。除特别说明外，命令都在 Git Bash 中执行。

## 目录

- 第一步：PowerShell 和 Windows Terminal 准备
- 第二步：Windows Terminal 集成 Git Bash
- 可选：VS Code 集成终端
- 第四步：预检查
- 第五步：Nerd Font 字体
- 第六步：Starship
- 第七步：下载 zsh 包
- 第八步：用 PeaZip 解压
- 第九步：合并到 Git for Windows 安装目录
- 第十步：Oh My Zsh 和插件
- 第十一步：现代 CLI 工具
- 第十二步：幂等更新 profile 文件
- 第十三步：验证
- 回退

## 第一步：PowerShell 和 Windows Terminal 准备

所有后续操作前，先确认用户有可用的 PowerShell 和 Windows Terminal。

在 Windows Terminal、开始菜单或运行窗口中检查 Windows PowerShell 5.1：

```powershell
powershell.exe -NoProfile -Command "$PSVersionTable.PSVersion"
```

说明：

- `powershell.exe` 是 Windows 自带的 Windows PowerShell，版本 5.1 已满足本技能需要。
- `powershell.exe` 不会显示 PowerShell 7 的版本，即使系统已经安装 PowerShell 7，它通常仍然返回 5.x。
- `pwsh.exe` 才是新版 PowerShell 7+ 的可执行文件，属于可选项；缺失时不要把它当成需要修复的问题。
- 只有 `powershell.exe` 和 `pwsh.exe` 都不可用时，才从 PowerShell 官方 GitHub Releases 安装
  PowerShell：<https://github.com/PowerShell/PowerShell/releases>。

如果用户明确说已经安装 PowerShell 7，但 `pwsh.exe` 在 Git Bash 中提示 `command not found`，不要判定为未安装；先检查常见完整路径：

```bash
pwsh.exe -NoProfile -Command '$PSVersionTable.PSVersion' 2>&1
"/c/Program Files/PowerShell/7/pwsh.exe" -NoProfile -Command '$PSVersionTable.PSVersion' 2>&1
```

若第二条成功，说明 PowerShell 7 已安装，只是 Git Bash 的 `PATH` 没包含 `C:\Program Files\PowerShell\7`。

检查 Windows Terminal：

```powershell
wt.exe --version
```

处理规则：

- Windows 11 默认自带 Windows Terminal。通常 `wt.exe` 应该可用，直接进入下一步。
- Windows 10 如果 `wt.exe` 不可用，需要先安装 Windows Terminal。
- Windows 10 推荐方式一：通过 Microsoft Store 搜索并安装 Windows Terminal。
- Windows 10 推荐方式二：从 Microsoft Terminal 官方 GitHub Releases 下载最新稳定版 `.msixbundle`
  安装包：<https://github.com/microsoft/terminal/releases/>。
- 安装完成后，桌面/文件夹空白处右键菜单通常会出现“在终端中打开”，开始菜单中也会出现“终端”。

## 第二步：Windows Terminal 集成 Git Bash

先把 Git Bash 添加到 Windows Terminal。修改 Windows Terminal `settings.json` 前必须备份。

常见 `settings.json` 路径：

```powershell
$settings = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Copy-Item $settings "$settings.bak.$(Get-Date -Format yyyyMMddHHmmss)"
```

如果用户使用的是 Windows Terminal Preview，路径通常是：

```powershell
$settings = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
```

在 `profiles.list` 中合并 Git Bash profile。可使用 `assets/windows-terminal-git-bash-profile.json`，核心字段如下：

```json
{
  "name": "Git Bash",
  "commandline": "C:\\Program Files\\Git\\bin\\bash.exe -l -i",
  "startingDirectory": "%USERPROFILE%",
  "icon": "C:\\Program Files\\Git\\git-bash.exe",
  "font": {
    "face": "FiraCode Nerd Font Mono",
    "size": 12
  }
}
```

要点：

- `commandline` 必须包含 `-l -i`，否则容易出现中文乱码或交互环境不完整。
- `startingDirectory` 使用 `%USERPROFILE%`，并关闭“使用父进程目录”。
- `icon` 可以使用 `C:\Program Files\Git\git-bash.exe`。
- `font.face` 使用已安装的 Nerd Font，例如 `FiraCode Nerd Font Mono`。
- 完整配置时，必须把顶层 `defaultProfile` 设置为 Git Bash profile 的 `guid`；只有用户明确要求保留现有默认终端时才跳过。

合并规则：

1. 如果 `profiles.list` 中已有 `name` 为 `Git Bash`，或 `commandline` 指向 `C:\Program Files\Git\bin\bash.exe`，更新这个 profile。
2. 如果没有 Git Bash profile，新增一个 profile，并生成稳定 `guid`。
3. 把顶层 `defaultProfile` 设为 Git Bash profile 的 `guid`。
4. 不要删除用户已有 profile、主题、actions 或其他顶层配置。
5. 写回后重新读取 `settings.json`，确认 Git Bash profile 存在且 `defaultProfile` 等于它的 `guid`。

如果用户要接近 Linux/GNOME Terminal 的快捷键习惯，可把 `assets/windows-terminal-actions.json` 中的动作合并到 `actions`：

```json
{
  "copyOnSelect": true,
  "multiLinePasteWarning": false
}
```

同时合并这些快捷键：

- `ctrl+shift+c`：复制
- `ctrl+shift+v`：粘贴
- `alt+1` 到 `alt+9`：切换到第 1 到第 9 个标签页

不要删除用户原有的 `profiles`、`actions`、主题或其他配置。

## 可选：VS Code 集成终端

如果用户希望 VS Code 也默认使用同一套 Git Bash/zsh 环境，把 `assets/vscode-terminal-settings.json` 合并到 VS Code 用户
`settings.json`：

```json
{
  "terminal.integrated.fontFamily": "FiraCode Nerd Font Mono",
  "terminal.integrated.fontSize": 12,
  "terminal.integrated.shellIntegration.enabled": true,
  "terminal.integrated.defaultProfile.windows": "Git Bash"
}
```

不要覆盖用户现有 VS Code settings，只合并这些键。

## 第四步：预检查

```bash
git --version
bash --version
uname -a
command -v winget.exe >/dev/null 2>&1 && winget.exe --version
```

如果 Git Bash 不存在，先让用户安装 Git for Windows。

## 第五步：Nerd Font 字体

安装 Nerd Font，例如 FiraCode Nerd Font Mono，然后在 Git Bash 中设置：

`Options -> Text -> Font -> FiraCode Nerd Font Mono`

如果用户主要通过 Windows Terminal 打开 Git Bash，也要在 Windows Terminal 的 Git Bash profile 中设置 Nerd Font。

## 第六步：Starship

```bash
winget.exe install --id Starship.Starship
mkdir -p "$HOME/bin"
cp "/c/Program Files/starship/bin/starship.exe" "$HOME/bin/starship.exe"
"$HOME/bin/starship.exe" --version
```

把 `assets/starship.toml` 写入 `~/.config/starship.toml`。

## 第七步：下载 zsh 包

zsh 安装优先采用 `references/zsh-on-windows-without-wsl.md` 的 Git Bash 无 WSL 流程，并忽略其中的 Powerlevel10k
步骤。本技能后续使用 Starship，不安装 Powerlevel10k，也不设置 `ZSH_THEME="powerlevel10k/powerlevel10k"`。

打开 MSYS2 package repository，下载最新的 `zsh-*-x86_64.pkg.tar.zst`：

<https://packages.msys2.org/package/zsh>

如果页面不可用，可以从 MSYS2 镜像目录查找最新包：

<https://mirror.msys2.org/msys/x86_64/>

不要硬编码包版本。下载文件名通常类似 `zsh-5.9-*-x86_64.pkg.tar.zst`，但版本号和修订号会变化。

## 第八步：用 PeaZip 解压

推荐使用 PeaZip 解压 `.pkg.tar.zst`：

<https://peazip.github.io/>

解压后检查结果，顶层应该包含 `etc` 和 `usr` 两个目录。若只得到 `.tar` 文件，继续用 PeaZip 再解压一次，直到看到 `etc` 和
`usr`。

不要把 `etc` 或 `usr` 下面的单个文件挑出来复制；必须保留目录结构。

## 第九步：合并到 Git for Windows 安装目录

关闭所有 Git Bash、Windows Terminal 和 VS Code 集成终端窗口。

以管理员权限把解压得到的 `etc` 和 `usr` 目录复制/合并到 Git for Windows 安装目录：

```text
C:\Program Files\Git
```

合并后的目标结构应类似：

```text
C:\Program Files\Git\etc\...
C:\Program Files\Git\usr\bin\zsh.exe
C:\Program Files\Git\usr\share\zsh\...
```

如果 Windows 提示合并文件夹，选择合并。不要删除 `C:\Program Files\Git\etc` 或 `C:\Program Files\Git\usr` 原目录，也不要整目录替换
Git 安装目录。

重新打开 Git Bash，验证：

```bash
zsh --version
```

如果第一次运行 `zsh` 出现初始化文件创建提示，选择 `Quit and do nothing`，后续由 Oh My Zsh 和本技能维护 `.zshrc`。

全命令行自动化只作为备选方案。若用户明确要求自动解压 `.tar.zst`，可以使用 Python，但必须先校验 tar 成员路径以避免路径穿越，并且仍要把解压出的
`etc` 和 `usr` 合并到 `C:\Program Files\Git`，不是只复制 `usr`。

## 第十步：Oh My Zsh 和插件

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
"$HOME/.fzf/install" --bin

git clone https://github.com/MichaelAquilina/zsh-you-should-use.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/you-should-use"
```

## 第十一步：现代 CLI 工具

这是推荐但可选的增强层。用户只想配置 zsh/Starship 时不要强制安装；用户要求完整配置或现代 CLI 工具时，必须完成工具安装、bat
配置和 alias 受管块合并。

| 工具        | 用途               | 常见命令或别名                               |
|-----------|------------------|---------------------------------------|
| `bat`     | 带语法高亮的 `cat` 替代品 | `bat` / 完整配置时 `cat`                   |
| `ripgrep` | 高速全文搜索           | `rg`                                  |
| `lsd`     | 现代化 `ls`         | 完整配置时 `ls` / `ll` / `la` / `lt` / `l` |
| `yazi`    | 终端文件管理器          | `yazi` / 完整配置时 `ya`                   |

yazi 的预览能力还依赖这些工具：

| 依赖                | 用途       |
|-------------------|----------|
| `7-Zip` / `p7zip` | 预览或处理压缩包 |
| `ImageMagick`     | 图片预览     |
| `FFmpeg`          | 音视频预览    |

优先使用随附脚本检查状态：

```bash
bash "<skill目录>/scripts/cli-tools.sh" status
```

需要安装时运行：

```bash
bash "<skill目录>/scripts/cli-tools.sh" install
```

Windows 下也可以手动安装：

```bash
winget.exe install --id sharkdp.bat --exact --accept-package-agreements --accept-source-agreements
winget.exe install --id BurntSushi.ripgrep.MSVC --exact --accept-package-agreements --accept-source-agreements
winget.exe install --id lsd-rs.lsd --exact --accept-package-agreements --accept-source-agreements
winget.exe install --id sxyazi.yazi --exact --accept-package-agreements --accept-source-agreements
winget.exe install --id 7zip.7zip --exact --accept-package-agreements --accept-source-agreements
winget.exe install --id ImageMagick.Q16 --exact --accept-package-agreements --accept-source-agreements
winget.exe install --id Gyan.FFmpeg --exact --accept-package-agreements --accept-source-agreements
```

配置 bat：

```bash
bat --generate-config-file
```

然后把 `assets/bat-config` 中的推荐配置合并到 bat 配置文件。Windows 路径通常是 `%APPDATA%\bat\config`；Git Bash
中可通过下面命令查看：

```bash
bat --config-file
```

完整配置现代 CLI 工具时，必须把 `assets/cli-tools-aliases.zsh` 合并到 `~/.zshrc` 末尾。该受管块会让 `cat` 使用 bat，让
`ls`、`ll`、`la`、`lt`、`l` 使用 lsd，让 `ya` 使用 yazi。放在文件末尾是有意的：它需要覆盖 Oh My Zsh 的默认 `ls` 相关 alias。

合并规则：

1. 先备份并读取 `~/.zshrc`。
2. 如果已存在 `# >>> windows-bash-zsh cli aliases >>>` 到 `# <<< windows-bash-zsh cli aliases <<<` 受管块，只替换这个块。
3. 如果不存在受管块，把 `assets/cli-tools-aliases.zsh` 追加到 `.zshrc` 末尾。
4. 不要改动 `.zshrc` 里受管块以外的注释、用户 PATH、Oh My Zsh 模板、插件配置或用户手写 alias。
5. 只有用户明确要求保留已有 alias 时，才不要覆盖 `cat`、`ls` 等 alias；此时仍需在最终回复中说明哪些 alias 没有改成 bat/lsd。

手工执行时，可以直接打开 `assets/cli-tools-aliases.zsh`，把整个受管块追加到 `.zshrc` 末尾。自动执行时必须按 marker
幂等替换，避免重复追加。

常见检查命令：

```bash
bat --version
rg --version
lsd --version
yazi --version
alias cat
alias ls
alias ll
7z --help >/dev/null 2>&1 || "/c/Program Files/7-Zip/7z.exe" --help >/dev/null 2>&1
magick -version
ffmpeg -version
```

如果安装后命令不可用，先重启 Git Bash 或运行 `exec zsh`。Windows 下 `winget` 安装的软件可能需要新终端才能刷新 PATH。

## 第十二步：幂等更新 profile 文件

编辑前先备份：

```bash
for file in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -e "$file" ] && cp "$file" "$file.bak.$(date +%Y%m%d%H%M%S)"
done
```

编辑 profile 文件时，禁止整文件覆盖。必须保留所有已有内容，包括注释、空行、alias、PATH、历史配置和用户手写片段。

写入 `~/.bashrc` 时使用 `assets/bashrc-block.sh`。更新 `~/.zshrc` 时不要把 `assets/zshrc-block.zsh` 当成完整 `.zshrc`
，它只是最小补充块。`.zshrc` 中 Oh My Zsh 原始模板注释、用户 alias、PATH、主题说明等必须保留。

定点幂等修改算法：

1. 读取目标文件全文；如果文件不存在，视为空文件。
2. 对每类配置先查找是否已存在，例如 PATH、fzf 环境变量、`plugins=(...)`、`starship init zsh`、`open()`。
3. 已存在时只更新该配置项的缺失部分，例如只给 `plugins=(...)` 追加缺失插件。
4. 不存在时只把缺失片段追加到合适位置；追加前保留原文件最后换行。
5. 如果无法可靠判断插入位置，先备份文件并在最终回复中说明需要用户确认；不要猜测重写文件。
6. 写回文件后重新读取确认：未命中的原有内容必须和写入前一致。

不要使用下面这种方式：

```bash
cp assets/bashrc-block.sh "$HOME/.bashrc"
cp assets/zshrc-block.zsh "$HOME/.zshrc"
```

这种做法会删除用户原有注释和配置，禁止使用。

`.zshrc` 的插件更新必须定点处理 `plugins=(...)`：

1. 读取现有 `~/.zshrc`。
2. 找到现有 `plugins=(...)` 块。
3. 从 `assets/zsh-plugins.txt` 读取期望插件列表。
4. 保留现有插件和顺序，只把缺失插件追加进去；不要删除用户已有插件。
5. 只替换 `plugins=(...)` 这一块，不改动其余注释和内容。

例如现有内容是：

```zsh
plugins=(
  git
  extract
  z
)
```

只能改成：

```zsh
plugins=(
  git
  extract
  z
  sudo
  web-search
  copypath
  copyfile
  dirhistory
  jsontools
  command-not-found
  npm
  node
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
  history-substring-search
  you-should-use
)
```

不能把 Oh My Zsh 自动生成的注释模板删除，也不能在文件末尾再追加第二个 `plugins=(...)`。

如果 `~/.zshrc` 没有 `plugins=(...)`，先确认是否已经安装 Oh My Zsh。若已安装但缺失该块，只在 `source $ZSH/oh-my-zsh.sh`
之前插入插件块；若无法确定插入点，在最终回复中说明并请用户确认，不要猜测重写文件。

`assets/zshrc-block.zsh` 只用于补充缺失的托管小块，例如 fzf 选项、Starship 初始化、autosuggest 样式和 `open()`。如果这些内容已经在用户
`.zshrc` 里存在，优先保留现有写法，不要重复添加。

现代 CLI 工具别名使用 `assets/cli-tools-aliases.zsh` 的 marker 受管块。完整配置或安装 CLI 工具后必须合并该块，并放在
`.zshrc` 末尾，使 bat/lsd/yazi alias 生效。不要因为合并该块删除用户其他 alias；如果用户明确要求保留已有 `cat`/`ls`/`ll`/
`la`/`lt`/`l`/`ya` alias，则不要覆盖，并在最终回复里说明。

验证时如果发现 `~/.bashrc` 缺少 `/c/Windows/System32/chcp.com 65001 >/dev/null 2>&1 || true`，直接按
`assets/bashrc-block.sh` 补齐缺失配置片段，不要仅提示用户。该行用于稳定 Git Bash 启动时的 UTF-8 编码。

如果用户之前在 `~/.bashrc` 里写过 alias、PATH、语言环境、Node/NVM/Volta 等配置，提醒用户迁移到 `~/.zshrc` 或拆成可被 zsh
source 的独立文件；不要自动删除用户原有 `.bashrc` 内容。

## 第十三步：验证

打开新的 Windows Terminal / Git Bash 窗口并运行：

```bash
zsh --version
starship --version
echo "$ZSH_VERSION"
echo "$PATH" | tr ':' '\n' | head
```

检查关键配置完整性：

```bash
grep -F "chcp.com 65001" "$HOME/.bashrc"
grep -F "exec zsh" "$HOME/.bashrc"
grep -F "starship init zsh" "$HOME/.zshrc"
grep -F "zsh-autosuggestions" "$HOME/.zshrc"
grep -F "windows-bash-zsh cli aliases" "$HOME/.zshrc"
bat --version
rg --version
lsd --version
yazi --version
alias cat
alias ls
alias ll
```

检查 Windows Terminal 默认 profile：

```powershell
$settings = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$json = Get-Content $settings -Raw | ConvertFrom-Json
$gitBash = $json.profiles.list | Where-Object { $_.name -eq "Git Bash" -or $_.commandline -like "*Git\\bin\\bash.exe*" } | Select-Object -First 1
if (-not $gitBash) { throw "Git Bash profile not found" }
if ($json.defaultProfile -ne $gitBash.guid) { throw "Windows Terminal defaultProfile is not Git Bash" }
```

如果 `.bashrc` 检查失败，按上面的定点算法补齐缺失项。若 `.zshrc` 检查失败，也按定点算法修复缺失项；不能整文件覆盖，也不能删除注释。

## 回退

如果只想回到 Bash，删除或注释托管 `.bashrc` 配置块中的这一行：

```bash
exec zsh
```

如果要完整移除该配置，删除本技能添加的启动、插件、fzf、Starship 和 `open()` 相关片段，并按需恢复备份。
