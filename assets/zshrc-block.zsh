# >>> windows-bash-zsh >>>
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.fzf/bin:$PATH"

export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_CTRL_T_OPTS="--preview 'cat {} 2>/dev/null | head -50'"
export FZF_ALT_C_OPTS="--preview 'ls {} 2>/dev/null'"

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

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

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=cyan"

if [ -s "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
# <<< windows-bash-zsh <<<
