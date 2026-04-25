# Windows Bash Zsh 配置流程

当用户需要具体命令、逐步安装、更新、回退或排障时使用本流程。除特别说明外，命令都在 Git Bash 中执行。

## 预检查

```bash
git --version
bash --version
uname -a
command -v winget.exe >/dev/null 2>&1 && winget.exe --version
```

如果 Git Bash 不存在，先让用户安装 Git for Windows。

## Nerd Font 字体

安装 Nerd Font，例如 FiraCode Nerd Font Mono，然后在 Git Bash 中设置：

`Options -> Text -> Font -> FiraCode Nerd Font Mono`

## Starship

```bash
winget.exe install --id Starship.Starship
mkdir -p "$HOME/bin"
cp "/c/Program Files/starship/bin/starship.exe" "$HOME/bin/starship.exe"
"$HOME/bin/starship.exe" --version
```

把 `assets/starship.toml` 写入 `~/.config/starship.toml`。

## 发现并下载 zsh 包

优先发现当前 MSYS2 镜像里的可用包，不要硬编码版本：

```bash
pkg_name="$(
  curl -fsSL "https://mirror.msys2.org/msys/x86_64/" |
    grep -oE 'zsh-[0-9][^"]+-x86_64\.pkg\.tar\.zst' |
    sort -V |
    tail -n 1
)"

test -n "$pkg_name" || { echo "Could not find zsh package"; exit 1; }
curl -fL "https://mirror.msys2.org/msys/x86_64/$pkg_name" -o /tmp/zsh.pkg.tar.zst
```

如果用户需要可复现安装，可以固定一个已验证的包地址，但要说明该地址未来可能失效。

## 安全解压

使用任意可用的 Python。只有在无法导入 `zstandard` 时才安装它。

```bash
python_cmd=""
for candidate in python3 python "py -3"; do
  if $candidate -c "import sys" >/dev/null 2>&1; then
    python_cmd="$candidate"
    break
  fi
done
test -n "$python_cmd" || { echo "Python is required"; exit 1; }

$python_cmd -m pip show zstandard >/dev/null 2>&1 || $python_cmd -m pip install --user zstandard

$python_cmd <<'PYEOF'
import io
import os
import tarfile
import tempfile
import zstandard as zstd

zst_path = os.path.join(tempfile.gettempdir(), "zsh.pkg.tar.zst")
out_dir = os.path.join(tempfile.gettempdir(), "zsh_extract")
os.makedirs(out_dir, exist_ok=True)

root = os.path.abspath(out_dir)

def ensure_safe(member):
    target = os.path.abspath(os.path.join(root, member.name))
    if target != root and not target.startswith(root + os.sep):
        raise RuntimeError(f"Unsafe tar member path: {member.name}")

with open(zst_path, "rb") as fh:
    decompressed = zstd.ZstdDecompressor().decompress(
        fh.read(),
        max_output_size=500 * 1024 * 1024,
    )

with tarfile.open(fileobj=io.BytesIO(decompressed)) as archive:
    for member in archive.getmembers():
        ensure_safe(member)
    archive.extractall(root)

print(root)
PYEOF
```

## 提权复制

从 Git Bash 执行下面命令。它会打开提权 PowerShell，并用 `robocopy` 把 zsh 文件复制到 Git for Windows 的 `usr` 目录。

```bash
powershell.exe -NoProfile -Command '$src = Join-Path ([System.IO.Path]::GetTempPath()) "zsh_extract\usr"; $dst = "C:\Program Files\Git\usr"; Start-Process -FilePath "robocopy" -ArgumentList @($src, $dst, "/E", "/XO", "/R:1", "/W:1") -Verb RunAs -Wait'
zsh --version
```

## Oh My Zsh 和插件

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

## 幂等更新 profile 文件

编辑前先备份：

```bash
for file in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -e "$file" ] && cp "$file" "$file.bak.$(date +%Y%m%d%H%M%S)"
done
```

编辑 profile 文件时，只替换下面两个标记之间的内容：

```text
# >>> windows-bash-zsh >>>
# <<< windows-bash-zsh <<<
```

写入 `~/.bashrc` 时使用 `assets/bashrc-block.sh`。写入 `~/.zshrc` 时使用 `assets/zshrc-block.zsh`。

## 验证

打开新的 Git Bash 窗口并运行：

```bash
zsh --version
starship --version
echo "$ZSH_VERSION"
echo "$PATH" | tr ':' '\n' | head
```

## 回退

如果只想回到 Bash，删除或注释托管 `.bashrc` 配置块中的这一行：

```bash
exec zsh
```

如果要完整移除该配置，删除 `~/.bashrc` 和 `~/.zshrc` 中的托管块，并按需恢复备份。
