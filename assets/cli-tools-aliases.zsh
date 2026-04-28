# Managed modern CLI aliases. Put this block near the end of ~/.zshrc so it wins
# over Oh My Zsh's default aliases. Back up ~/.zshrc before updating this block.

if command -v bat >/dev/null 2>&1; then
  alias cat="bat --paging=never"
elif command -v batcat >/dev/null 2>&1; then
  alias cat="batcat --paging=never"
fi

if command -v lsd >/dev/null 2>&1; then
  alias ls="lsd --color=auto --group-directories-first"
  alias ll="lsd -l --color=auto --group-directories-first"
  alias la="lsd -la --color=auto --group-directories-first"
  alias lt="lsd --tree --color=auto --group-directories-first"
  alias l="lsd -lF --color=auto"
fi

if command -v yazi >/dev/null 2>&1; then
  alias ya="yazi"
fi

case ":$PATH:" in
  *":/c/Program Files/7-Zip:"*) ;;
  *) [ -d "/c/Program Files/7-Zip" ] && export PATH="/c/Program Files/7-Zip:$PATH" ;;
esac
