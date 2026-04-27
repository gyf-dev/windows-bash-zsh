#!/usr/bin/env bash
# Install, remove, or check modern CLI tools used by windows-bash-zsh.
# Usage: bash scripts/cli-tools.sh [install|uninstall|status]

set -euo pipefail

TOOLS=(
  "bat|bat|sharkdp.bat|bat|bat"
  "ripgrep|ripgrep|BurntSushi.ripgrep.MSVC|ripgrep|rg"
  "lsd|lsd|lsd-rs.lsd|lsd|lsd"
  "yazi|yazi|sxyazi.yazi|yazi|yazi"
)

PREVIEW_DEPS=(
  "7-Zip|p7zip|7zip.7zip|p7zip-full|7z"
  "ImageMagick|imagemagick|ImageMagick.Q16|imagemagick|magick"
  "FFmpeg|ffmpeg|Gyan.FFmpeg|ffmpeg|ffmpeg"
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

detect_pm() {
  case "$(uname -s)" in
    Darwin)
      echo "brew"
      ;;
    Linux)
      if command -v brew >/dev/null 2>&1; then
        echo "brew"
      elif command -v apt-get >/dev/null 2>&1; then
        echo "apt"
      else
        echo "unknown"
      fi
      ;;
    *_NT*|MINGW*|MSYS*|CYGWIN*)
      if command -v winget.exe >/dev/null 2>&1; then
        echo "winget"
      else
        echo "unknown"
      fi
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

pm_name() {
  case "$PM" in
    brew) echo "Homebrew" ;;
    apt) echo "apt" ;;
    winget) echo "winget" ;;
    *) echo "unknown" ;;
  esac
}

logo() {
  echo "Modern CLI Tools ($(pm_name))"
  echo "-----------------------------"
}

pkg_index() {
  case "$PM" in
    brew) echo 1 ;;
    winget) echo 2 ;;
    apt) echo 3 ;;
    *) return 1 ;;
  esac
}

brew_installed() { brew ls --versions "$1" >/dev/null 2>&1; }
brew_install() { brew install "$1"; }
brew_remove() { brew uninstall "$1"; }

apt_installed() { dpkg -s "$1" >/dev/null 2>&1; }
apt_install() { sudo apt-get update && sudo apt-get install -y "$1"; }
apt_remove() { sudo apt-get remove -y "$1"; }

winget_installed() {
  local output
  output="$(winget.exe list --id "$1" --exact 2>/dev/null || true)"
  printf '%s\n' "$output" | grep -Fqi "$1"
}
winget_install() {
  winget.exe install --id "$1" --exact --accept-package-agreements --accept-source-agreements
}
winget_remove() { winget.exe uninstall --id "$1" --exact; }

is_command_available() {
  local command_name="$1"
  command -v "$command_name" >/dev/null 2>&1
}

install_one() {
  local name="$1" pkg="$2" command_name="$3"

  if "${PM}_installed" "$pkg" || is_command_available "$command_name"; then
    printf "  ${GREEN}OK${NC} %s already available\n" "$name"
    return 0
  fi

  printf "  Installing %-16s ... " "$name"
  if "${PM}_install" "$pkg"; then
    printf "${GREEN}OK${NC}\n"
  else
    printf "${RED}FAILED${NC}\n"
    return 1
  fi
}

remove_one() {
  local name="$1" pkg="$2"

  if "${PM}_installed" "$pkg"; then
    printf "  Removing %-18s ... " "$name"
    if "${PM}_remove" "$pkg"; then
      printf "${GREEN}OK${NC}\n"
    else
      printf "${RED}FAILED${NC}\n"
      return 1
    fi
  fi
}

status_one() {
  local name="$1" pkg="$2" command_name="$3"

  if "${PM}_installed" "$pkg" || is_command_available "$command_name"; then
    printf "  ${GREEN}OK${NC} %s\n" "$name"
  else
    printf "  ${RED}MISSING${NC} %s\n" "$name"
  fi
}

with_entries() {
  local action="$1" idx
  idx="$(pkg_index)" || {
    echo "Unsupported package manager. Install the tools manually."
    return 1
  }

  echo
  echo "[Tools]"
  for entry in "${TOOLS[@]}"; do
    IFS='|' read -r name brew_pkg winget_pkg apt_pkg command_name <<<"$entry"
    local packages=("$brew_pkg" "$winget_pkg" "$apt_pkg")
    "$action" "$name" "${packages[$((idx - 1))]}" "$command_name"
  done

  echo
  echo "[Yazi preview dependencies]"
  for entry in "${PREVIEW_DEPS[@]}"; do
    IFS='|' read -r name brew_pkg winget_pkg apt_pkg command_name <<<"$entry"
    local packages=("$brew_pkg" "$winget_pkg" "$apt_pkg")
    "$action" "$name" "${packages[$((idx - 1))]}" "$command_name"
  done
}

do_install() {
  logo
  with_entries install_one
  echo
  printf "${YELLOW}Restart Git Bash or run exec zsh after installation so PATH changes take effect.${NC}\n"
}

do_uninstall() {
  logo
  local idx
  idx="$(pkg_index)" || {
    echo "Unsupported package manager."
    return 1
  }

  echo
  for entry in "${PREVIEW_DEPS[@]}" "${TOOLS[@]}"; do
    IFS='|' read -r name brew_pkg winget_pkg apt_pkg _command_name <<<"$entry"
    local packages=("$brew_pkg" "$winget_pkg" "$apt_pkg")
    remove_one "$name" "${packages[$((idx - 1))]}"
  done
}

do_status() {
  logo
  with_entries status_one
}

PM="$(detect_pm)"

case "${1:-install}" in
  install) do_install ;;
  uninstall) do_uninstall ;;
  status) do_status ;;
  *)
    echo "Usage: $0 [install|uninstall|status]"
    exit 2
    ;;
esac
