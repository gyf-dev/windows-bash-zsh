#!/usr/bin/env bash
set -euo pipefail

targets=("all")
extra_roots=()
dry_run=0
yes=0
uninstall=0

usage() {
  cat <<'EOF'
Usage: bash install-to-skills.sh [options]

Options:
  --targets <list>           Target list: all,codex,claude,agents,copilot
  --extra-skill-roots <list> Extra skills root directories, comma separated
  --dry-run                  Preview actions without writing files
  --yes                      Replace existing skill without prompting
  --uninstall                Remove windows-bash-zsh from target skills roots
  -h, --help                 Show this help

Examples:
  bash install-to-skills.sh
  bash install-to-skills.sh --dry-run
  bash install-to-skills.sh --targets codex
  bash install-to-skills.sh --targets copilot --uninstall
  bash install-to-skills.sh --extra-skill-roots "D:/MyAgent/skills"
EOF
}

split_csv() {
  local input="$1"
  local output_name="$2"
  local -n output_ref="$output_name"
  local index
  IFS=',' read -r -a output_ref <<<"$input"
  for index in "${!output_ref[@]}"; do
    output_ref[$index]="$(printf '%s' "${output_ref[$index]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  done
}

while [ $# -gt 0 ]; do
  case "$1" in
    --targets|-Targets)
      [ $# -ge 2 ] || { echo "--targets requires a value" >&2; exit 2; }
      split_csv "$2" targets
      shift 2
      ;;
    --extra-skill-roots|-ExtraSkillRoots)
      [ $# -ge 2 ] || { echo "--extra-skill-roots requires a value" >&2; exit 2; }
      split_csv "$2" extra_roots
      shift 2
      ;;
    --dry-run|-DryRun)
      dry_run=1
      shift
      ;;
    --yes|-Yes)
      yes=1
      shift
      ;;
    --uninstall|-Uninstall)
      uninstall=1
      shift
      ;;
    -h|--help|/?)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
skill_name="$(basename "$source_dir")"

if [ ! -f "$source_dir/SKILL.md" ]; then
  echo "SKILL.md was not found. Run this script from inside a skill repository." >&2
  exit 1
fi

skill_root_for() {
  case "$1" in
    codex)
      if [ -n "${CODEX_HOME:-}" ]; then printf '%s/skills\n' "$CODEX_HOME"; else printf '%s/.codex/skills\n' "$HOME"; fi
      ;;
    claude)
      if [ -n "${CLAUDE_HOME:-}" ]; then printf '%s/skills\n' "$CLAUDE_HOME"; else printf '%s/.claude/skills\n' "$HOME"; fi
      ;;
    agents)
      if [ -n "${AGENTS_HOME:-}" ]; then printf '%s/skills\n' "$AGENTS_HOME"; else printf '%s/.agents/skills\n' "$HOME"; fi
      ;;
    copilot)
      if [ -n "${COPILOT_HOME:-}" ]; then printf '%s/skills\n' "$COPILOT_HOME"; else printf '%s/.copilot/skills\n' "$HOME"; fi
      ;;
    *)
      echo "Unknown target: $1" >&2
      exit 2
      ;;
  esac
}

expanded_targets=()
for target in "${targets[@]}"; do
  if [ "$target" = "all" ]; then
    expanded_targets=(codex claude agents copilot)
    break
  fi
  expanded_targets+=("$target")
done

copy_skill() {
  local destination="$1"
  local dir

  mkdir -p "$destination"
  cp "$source_dir/SKILL.md" "$destination/SKILL.md"

  for dir in agents assets references scripts; do
    rm -rf "$destination/$dir"
    if [ -d "$source_dir/$dir" ]; then
      cp -R "$source_dir/$dir" "$destination/$dir"
    fi
  done
}

install_one() {
  local name="$1"
  local root="$2"
  local create_root="${3:-0}"
  local destination="$root/$skill_name"
  if [ ! -d "$root" ]; then
    if [ "$create_root" = "1" ]; then
      if [ "$dry_run" = "1" ]; then
        echo "[dry-run] $name root would be created: $root"
      else
        mkdir -p "$root"
      fi
    else
      echo "Skipped $name: skill root not found: $root"
      return
    fi
  fi

  if [ "$dry_run" = "1" ]; then
    echo "[dry-run] $name -> $destination"
    if [ -d "$destination" ]; then
      echo "[dry-run] existing skill would prompt for replacement: $destination"
    fi
    return
  fi

  if [ -d "$destination" ]; then
    if [ "$yes" = "1" ]; then
      rm -rf "$destination"
      echo "Replaced existing $name skill: $destination"
    else
      local answer
      if ! read -r -p "Existing $name skill found at $destination. Replace? [y/N] " answer; then
        answer=""
      fi

      case "$answer" in
        y|Y)
          rm -rf "$destination"
          echo "Replaced existing $name skill: $destination"
          ;;
        *)
          echo "Skipped $name: existing skill was kept."
          return
          ;;
      esac
    fi
  fi

  copy_skill "$destination"
  echo "Installed $name skill: $destination"
}

uninstall_one() {
  local name="$1"
  local root="$2"
  local destination="$root/$skill_name"

  if [ ! -d "$root" ]; then
    echo "Skipped $name: skill root not found: $root"
    return
  fi

  if [ ! -d "$destination" ]; then
    echo "Skipped $name: skill not installed: $destination"
    return
  fi

  if [ "$dry_run" = "1" ]; then
    echo "[dry-run] $name would be removed: $destination"
    return
  fi

  rm -rf "$destination"
  echo "Uninstalled $name skill: $destination"
}

echo "Source skill: $source_dir"
echo "Skill name:   $skill_name"
if [ "$uninstall" = "1" ]; then
  echo "Mode:         uninstall"
else
  echo "Mode:         install"
fi

for target in "${expanded_targets[@]}"; do
  root="$(skill_root_for "$target")"
  if [ "$uninstall" = "1" ]; then
    uninstall_one "$target" "$root"
  else
    install_one "$target" "$root" 0
  fi
done

for root in "${extra_roots[@]}"; do
  [ -n "$root" ] || continue
  if [ "$uninstall" = "1" ]; then
    uninstall_one "custom" "$root"
  else
    install_one "custom" "$root" 1
  fi
done

echo "Done."
