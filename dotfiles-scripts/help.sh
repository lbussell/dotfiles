# help.sh — dotfiles help registration system

DOTFILES_COMMANDS=()

register_command() {
  local category="$1"
  local name="$2"
  local description="$3"
  # Capture the caller's file from the call stack, resolve to path relative to $HOME
  local source_file="${funcfiletrace[1]%:*}"
  source_file="${source_file/#$HOME/~}"
  DOTFILES_COMMANDS+=("$category|$name|$description|$source_file")
}

dothelp() {
  local current=""
  local dim=$'\e[2m' reset=$'\e[0m'
  local IFS=$'\n'
  local sorted=($(printf '%s\n' "${DOTFILES_COMMANDS[@]}" | sort))

  printf "Available commands:\n\n"
  for entry in "${sorted[@]}"; do
    local category="${entry%%|*}"
    local rest="${entry#*|}"
    local name="${rest%%|*}"
    rest="${rest#*|}"
    local desc="${rest%%|*}"
    local file="${rest#*|}"

    if [[ "$category" != "$current" ]]; then
      current="$category"
      printf "%s\n" "$category"
    fi
    printf "  %-18s %-40s ${dim}%s${reset}\n" "$name" "$desc" "$file"
  done
}

register_command "Help" "dothelp" "Show this help message"
