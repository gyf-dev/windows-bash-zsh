# 在 Windows 上安装 ZSH + Oh My ZSH（无需 WSL）

## 核心思路

> 💡 **核心思路：** 本文介绍如何在不使用 WSL 的前提下，直接在 Git Bash for Windows 上安装 ZSH + Oh My ZSH，以获得比 WSL 更轻量、更快速的类 Unix 终端体验。
>
> 原文作者：Camilo Martinez（2022/10/11） | 翻译整理：中文版

---

## 概述

WSL（Windows Subsystem for Linux）虽然为 Windows 提供了类 Unix 环境，但其**性能和内存消耗较高**。本文将介绍一种替代方案——直接在 Git Bash for Windows 上安装 ZSH，无需启用 WSL。

> ⚠️ **注意：** Git Bash 本质上是一个模拟层，性能不如原生 Linux 环境，但通常比 WSL 更快且占用更少内存。

---

## 第一步：安装 Bash

下载并安装 **Git for Windows**，它自带 Bash 终端支持。安装完成后即可在 Windows 上使用 Bash shell。

---

## 第二步：安装 ZSH

### 下载 ZSH

从 MSYS2 软件包仓库下载最新的 MSYS2 ZSH 包。文件名格式为 `zsh-#.#-#-x86_64.pkg.tar.zst`。`.zst` 格式的压缩文件可以使用 **PeaZip** 解压。

### 安装

将解压后的 `etc` 和 `usr` 文件夹复制到 Git Bash 安装目录（通常为 `C:\Program Files\Git`），如果提示合并文件夹，选择**合并**即可。

### 配置

打开 Git Bash，输入 `zsh` 启动 ZSH，然后验证版本：

```bash
zsh --version
zsh 5.9 (x86_64-pc-msys)
```

为了让 Git Bash 启动时自动进入 ZSH，在 `~/.bashrc` 文件中添加以下内容：

```bash
if [ -t 1 ]; then
  exec zsh
fi
```

> ❗ **UTF-8 乱码修复：** 如果遇到中文字符显示乱码，请在 ZSH exec 代码**之前**添加以下行：
>
> ```bash
> /c/Windows/System32/chcp.com 65001 > /dev/null 2>&1
> ```

首次启动 ZSH 时，会询问是否创建配置文件，选择 **"Quit and do nothing"（退出并不做任何操作）**。

---

## 第三步：安装 Oh My Zsh!

### 安装

执行以下命令安装 Oh My Zsh!：

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 安装字体

手动安装 **Meslo Nerd Fonts**（为 Powerlevel10k 打过补丁的版本），以确保所有图标和符号能正确显示。如果字体未正确安装，终端中的图标会显示为 ▯。

### 配置主题

推荐使用 **Powerlevel10k** 主题，这是一个美观且高度可定制的 ZSH 主题：

```bash
git clone https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
```

在 `~/.zshrc` 中添加以下配置：

```bash
ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(history)
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1

export LS_COLORS="rs=0:no=00:mi=00:mh=00:ln=01;36:or=01;31:di=01;34:ow=04;01;34:st=34:tw=04;34:pi=01;33:so=01;33:do=01;33:bd=01;33:cd=01;33:su=01;35:sg=01;35:ca=01;35:ex=01;32:"
```

重启终端后运行 `p10k configure` 进行交互式配置。如果图标显示为 ▯，请先安装字体再重试。

### 安装插件

以下三个插件能显著提升终端使用体验：

| 插件 | 功能 |
|------|------|
| **zsh-autosuggestions** | 根据历史记录自动建议命令补全 |
| **zsh-syntax-highlighting** | 命令语法高亮，输入时实时检查 |
| **ohmyzsh-full-autoupdate** | 自动更新 Oh My Zsh 及所有插件 |

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/Pilaton/OhMyZsh-full-autoupdate.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ohmyzsh-full-autoupdate
```

在 `~/.zshrc` 中启用所有插件（**用空格分隔，不要用逗号**）：

```bash
plugins=(
    adb
    command-not-found
    extract
    deno
    docker
    git
    github
    gitignore
    history-substring-search
    node
    npm
    nvm
    yarn
    volta
    vscode
    sudo
    web-search
    z
    zsh-autosuggestions
    zsh-syntax-highlighting
    ohmyzsh-full-autoupdate
)

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor root line)
ZSH_HIGHLIGHT_PATTERNS=('rm -rf *' 'fg=white,bold,bg=red')
```

> ⚠️ **注意：** NVM 用户需正确配置以避免 ZSH 启动变慢。之前在 `~/.bashrc` 中的自定义配置应迁移到 `~/.zshrc` 中。

---

## 第四步：终端配置

### VS Code

在 VS Code 的用户设置 `settings.json` 中添加：

```json
{
  "terminal.integrated.fontFamily": "MesloLGS NF",
  "terminal.integrated.fontSize": 12,
  "terminal.integrated.shellIntegration.enabled": true,
  "terminal.integrated.defaultProfile.windows": "Git Bash"
}
```

### Microsoft Terminal

在 Microsoft Terminal 的 Git Bash 配置文件中添加字体和起始目录设置：

```json
{
  "font": {
    "face": "MesloLGS NF",
    "size": 12
  },
  "startingDirectory": "D:\\Developer"
}
```

---

## 不足之处

| 问题 | 说明 / 解决方案 |
|------|-----------------|
| **首次加载慢** | 首次启动需要加载时间，但仍比 WSL 快 |
| **Volta 权限问题** | Windows 上的 Volta 可能需要额外权限，可改用 NVM |
| **VS Code 终端异常** | 在 VS Code 内置终端中输入时可能会有奇怪的行为 |
| **路径格式** | 使用 `cygpath $LOCALAPPDATA` 转换 Windows 路径 |

> ⚠️ **性能限制：** Git Bash 是模拟层，不如原生 Linux 快，但通常优于 WSL。
>
> ⚠️ **路径兼容性：** Windows 风格 `%VARIABLE%` 路径不直接支持，需使用 `cygpath $LOCALAPPDATA` 转换。

---

## 参考来源

- "Installing Zsh (and oh-my-zsh) in Windows Git Bash" by Dominik Rys
- "Speeding Up My Shell (Oh My Zsh)" by Matt Clemente
- 原文链接：[ZSH on Windows without WSL - dev.to](https://dev.to/equiman/zsh-on-windows-without-wsl-4ah9)

---

> ✅ **总结：** 通过以上步骤，你即可在 Windows 上拥有一个美观、高效的 ZSH 终端环境，无需启用 WSL。整个过程为：**Git Bash → ZSH → Oh My Zsh! → Powerlevel10k 主题 → 插件 → 终端字体配置**，按顺序操作即可完成。
