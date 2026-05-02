# Windows 下配置 Claude Code Statusline

Claude Code 的状态栏（Statusline）是终端底部的一行信息条，显示当前工作目录、模型、上下文用量、Git 分支和估算费用。

## 效果预览

配置完成后，终端底部状态栏显示如下：

```
InvToolBox | DeepSeek-V4 | ctx:12% | dev | $0.0074
```

含义：`项目目录 | 模型名 | 上下文用量12% | 分支名 | 估算费用`

## 目录

- 第一步：安装 jq（JSON 解析器）
- 第二步：配置 Git Bash 的 PATH（关键）
- 第三步：编写 Statusline 命令
- 第四步：写入 Claude Code 配置
- 第五步：验证
- 常见故障排查
- 自定义命令详解
- 完整命令速查

## 第一步：安装 jq（JSON 解析器）

Statusline 命令需要 `jq` 来解析 Claude Code 传入的 JSON 状态数据。

```powershell
# 在 PowerShell 中执行
winget install jqlang.jq --accept-package-agreements
```

验证安装成功（关掉终端重新打开后）：

```bash
jq --version
# 输出: jq-1.8.1
```

> **注意**：如果提示 `command not found`，说明下一步的 PATH 配置还没生效，继续往下看。

## 第二步：配置 Git Bash 的 PATH（关键）

这是 Windows 用户最容易踩的坑。

### 问题根源

Winget 安装 `jq` 后，二进制文件在：

```
C:\Users\<用户名>\AppData\Local\Microsoft\WinGet\Packages\jqlang.jq_Microsoft.Winget.Source_8wekyb3d8bbwe\jq.exe
```

但 Git Bash（基于 MSYS2）的 `PATH` 环境变量**只认 Unix 风格路径**（`/c/Users/...`），不认 Windows 风格路径（`C:\Users\...`）。即使 Winget 把目录加到了系统 PATH，Git Bash 也无法直接使用。

另外 `LOCALAPPDATA` 环境变量在 Git Bash 中返回的是 `C:\Users\...` 格式，直接用会失败。

### 正确写法

在 `~/.zshrc` 末尾添加（路径转换用 `cygpath -u`）：

```bash
# jq (winget) - 必须转Unix路径，Git Bash的PATH不认Windows风格路径
jq_dir="$(cygpath -u "$LOCALAPPDATA")/Microsoft/WinGet/Packages/jqlang.jq_Microsoft.Winget.Source_8wekyb3d8bbwe"
[ -d "$jq_dir" ] && export PATH="$jq_dir:$PATH"
unset jq_dir
```

保存后关闭终端重新打开，执行 `jq --version` 验证输出正常。

### 为什么不用 winget 的 Links 目录

Winget 理论上会在 `%LOCALAPPDATA%\Microsoft\WinGet\Links\` 下创建 jq.exe 的硬链接，并把这个 Links 目录加入 PATH。但实际安装中 Links 目录经常为空（winget 的 bug）。直接用软件包目录更可靠。

## 第三步：编写 Statusline 命令

Claude Code 的 statusline 有两种模式：

| 类型 | 说明 |
|------|------|
| `"type": "text"` | 显示固定文本 |
| `"type": "command"` | 执行 shell 命令，将 JSON 状态通过 **stdin** 传入，读取命令的 **stdout** 作为显示文本 |

我们使用 `"type": "command"`，实现动态信息展示。

### Claude Code 传入的 JSON 结构

```json
{
  "workspace": {
    "current_dir": "D:/Codes/InvToolBox"
  },
  "model": {
    "display_name": "DeepSeek-V4"
  },
  "context_window": {
    "used_percentage": 12.5,
    "total_input_tokens": 15000,
    "total_output_tokens": 3000
  }
}
```

### 命令逻辑

一条 Bash 命令完成以下工作：

1. **stdin 读取 JSON** → `i=$(cat)`
2. **jq 提取字段** → 目录 `d`、模型名 `m`、用量百分比 `p`、输入 token 数 `it`、输出 token 数 `ot`
3. **git 取分支名** → `b=$(git -C "$d" symbolic-ref --short HEAD 2>/dev/null)`
4. **awk 算费用** → `c=$(awk "BEGIN{printf \"\$%.4f\",($it/1e6)*0.27+($ot/1e6)*1.10}")`
   - 公式：`(输入token/百万) × 0.27 + (输出token/百万) × 1.10`
   - 数字对应 DeepSeek 的 API 定价，换成其他模型需修改
5. **拼接显示** → `项目 | 模型 | ctx:用量% | 分支 | 费用`

## 第四步：写入 Claude Code 配置

编辑 `%USERPROFILE%\.claude\settings.json`（即 `~/.claude/settings.json`），在 JSON 对象中添加 `statusLine` 字段：

```json
{
  "statusLine": {
    "type": "command",
    "command": "i=$(cat);d=$(echo \"$i\"|jq -r '.workspace.current_dir//\"\"');m=$(echo \"$i\"|jq -r '.model.display_name//\"\"');p=$(echo \"$i\"|jq -r '.context_window.used_percentage//\"\"');it=$(echo \"$i\"|jq -r '.context_window.total_input_tokens//0');ot=$(echo \"$i\"|jq -r '.context_window.total_output_tokens//0');b=\"\";[ -n \"$d\" ]&&b=$(git -C \"$d\" symbolic-ref --short HEAD 2>/dev/null);c=$(awk \"BEGIN{printf \\\"\\$%.4f\\\",($it/1e6)*0.27+($ot/1e6)*1.10}\");o=\"\";[ -n \"$d\" ]&&o=\"$o$(basename \"$d\") | \";[ -n \"$m\" ]&&o=\"$o$m | \";[ -n \"$p\" ]&&o=\"${o}ctx:$(printf '%.0f' \"$p\")% | \";[ -n \"$b\" ]&&o=\"$o$b | \";echo \"$o$c\""
  }
}
```

### JSON 转义注意点

在上面那段命令里，最关键的转义是 awk 语句中的 `$` 符号：

```
\\\"\\$%.4f\\\"
```

在 JSON 文件中经过两层转义：
- **JSON 解析**：`\\` → `\`，`\"` → `"`
- **Shell 执行**：`\$` → 字面量 `$`

如果只写 `$` 不加 `\`，bash 会把 `$%` 当成空变量吃掉，awk 会收到错误的格式字符串而报错，导致状态栏完全不显示。这是 Windows Git Bash 用户碰到的**第二个高频坑**。

## 第五步：验证

1. 关掉所有终端窗口，重新打开
2. 确认 `jq --version` 正常输出
3. 启动 Claude Code（在 Git Bash 中运行 `claude`）
4. 观察终端底部是否出现状态栏

如果状态栏没显示，检查：

```bash
# 测试命令是否能正常执行（替换 JSON 中的值为实际路径）
echo '{"workspace":{"current_dir":"D:/Codes/InvToolBox"},"model":{"display_name":"DeepSeek-V4"},"context_window":{"used_percentage":12.5,"total_input_tokens":15000,"total_output_tokens":3000}}' | bash -c '粘贴你的statusline命令'
```

应该输出类似 `InvToolBox | DeepSeek-V4 | ctx:12% | dev | $0.0074` 的结果。

## 常见故障排查

| 症状 | 原因 | 解决 |
|------|------|------|
| 状态栏完全空白 | `jq` 未安装或不在 PATH | 完成第一步、第二步 |
| 出现 `command not found: jq` | PATH 用了 Windows 风格路径 | 检查 `.zshrc` 中是否用 `cygpath -u` 转换 |
| 费用显示异常（如 `.4f`） | awk 的 `$` 被 shell 吃掉 | 确认 JSON 中 awk 部分写成 `\\\"\\$%.4f\\\"` |
| 分支名不显示 | 当前不在 git 仓库或 git 不在 PATH | `git --version` 检查 |
| 新开终端 jq 仍然找不到 | `.zshrc` 修改未生效 | `source ~/.zshrc` 或重新打开终端 |

## 自定义命令详解

如果想自己修改状态栏内容，以下是命令的拆解注释版（**不能直接用于 JSON**，仅供参考理解）：

```bash
# 1. 读取 stdin 的 JSON
i=$(cat)

# 2. 提取各字段（jq 的 //"" 表示字段为 null 时用空字符串兜底）
d=$(echo "$i" | jq -r '.workspace.current_dir//""')     # 工作目录
m=$(echo "$i" | jq -r '.model.display_name//""')         # 模型名
p=$(echo "$i" | jq -r '.context_window.used_percentage//""')  # 用量%
it=$(echo "$i" | jq -r '.context_window.total_input_tokens//0')
ot=$(echo "$i" | jq -r '.context_window.total_output_tokens//0')

# 3. Git 分支
b=""
[ -n "$d" ] && b=$(git -C "$d" symbolic-ref --short HEAD 2>/dev/null)

# 4. 费用计算（DeepSeek 定价，换成其他模型需改系数）
c=$(awk "BEGIN{printf \"\$%.4f\",($it/1e6)*0.27+($ot/1e6)*1.10}")

# 5. 拼接输出
o=""
[ -n "$d" ] && o="$o$(basename "$d") | "
[ -n "$m" ] && o="$o$m | "
[ -n "$p" ] && o="${o}ctx:$(printf '%.0f' "$p")% | "
[ -n "$b" ] && o="$o$b | "
echo "$o$c"
```

### 常见自定义需求

**去掉费用显示**：删除第 5 步里的 `$c`，即把最后的 `echo "$o$c"` 改为 `echo "${o% | }"`

**去掉分支名**：删除第 3 步整段和第 5 步中 `[ -n "$b" ]` 那一行

**改为"文本"模式（显示固定文字）**：
```json
{
  "statusLine": {
    "type": "text",
    "text": "Claude Code 工作中..."
  }
}
```

**改用其他模型定价**：修改 awk 中的系数。例如 Claude Sonnet 定价：输入 `$3/Mtokens`，输出 `$15/Mtokens`，则系数改为 `3.00` 和 `15.00`。

## 完整命令速查

拿到一个工作目录，打开 Claude Code（`claude` 命令），状态栏就会显示。以下是一套完整的配置命令速查：

```bash
# === 一次性操作 ===

# 1. 安装 jq（PowerShell 中执行）
winget install jqlang.jq --accept-package-agreements

# 2. 在 ~/.zshrc 末尾添加（Git Bash 中执行）
cat >> ~/.zshrc << 'ZEOF'

# jq (winget) - 必须转Unix路径，Git Bash的PATH不认Windows风格路径
jq_dir="$(cygpath -u "$LOCALAPPDATA")/Microsoft/WinGet/Packages/jqlang.jq_Microsoft.Winget.Source_8wekyb3d8bbwe"
[ -d "$jq_dir" ] && export PATH="$jq_dir:$PATH"
unset jq_dir
ZEOF

# 3. 应用 .zshrc 修改
source ~/.zshrc

# 4. 验证 jq 可用
jq --version

# 5. 编辑 ~/.claude/settings.json，添加 statusLine 字段（见上文）
```

## 相关链接

- [Claude Code 官方文档](https://docs.anthropic.com/en/docs/claude-code)
- [windows-bash-zsh 项目](https://github.com/gyf-dev/windows-bash-zsh)
- [jq 官方下载](https://jqlang.github.io/jq/download/)
