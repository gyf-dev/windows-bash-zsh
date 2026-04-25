# Windows Bash/Zsh additions. Do not put Oh My Zsh template content or plugins=(...) here.
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.fzf/bin:$PATH"

export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_CTRL_T_OPTS="--preview 'cat {} 2>/dev/null | head -50'"
export FZF_ALT_C_OPTS="--preview 'ls {} 2>/dev/null'"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=cyan"

if command -v starship >/dev/null 2>&1; then
  # Starship prompt (overrides Oh My Zsh theme)
  eval "$(starship init zsh)"
fi

# macOS-like open command for Windows
open() {
  if [ $# -eq 0 ]; then
    explorer .
  else
    for arg in "$@"; do
      if [[ "$arg" == *.* ]]; then
        start "" "$arg"
      else
        notepad "$arg"
      fi
    done
  fi
}
