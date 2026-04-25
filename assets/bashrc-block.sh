# >>> windows-bash-zsh >>>
export PATH="$HOME/bin:$PATH"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

if [ -x /c/Windows/System32/chcp.com ]; then
  /c/Windows/System32/chcp.com 65001 >/dev/null 2>&1 || true
fi

if [ -t 1 ] && command -v zsh >/dev/null 2>&1 && [ -z "$ZSH_VERSION" ]; then
  exec zsh
fi
# <<< windows-bash-zsh <<<
