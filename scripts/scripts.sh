# scripts.sh — Shell helper functions

# ── Help ─────────────────────────────────────────────────────────────────────

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

# ── MOTD ──────────────────────────────────────────────────────────────────────

dotfiles_motd() {
  local dim=$'\e[2m' reset=$'\e[0m'
  print "${dim}Run dothelp for available commands${reset}"
}

# ── Brew ──────────────────────────────────────────────────────────────────────

brew() {
  command brew "$@"
  local exit_code=$?
  case "$1" in
    install|uninstall|remove|reinstall|upgrade)
      command brew bundle dump --force --no-vscode --file=~/.brewfile
      yadm add ~/.brewfile
      yadm diff --quiet --cached -- ~/.brewfile || yadm commit -m "brew $*"
      ;;
  esac
  return $exit_code
}

brew-sync() {
  command brew bundle --file=~/.brewfile
}

register_command "Brew" "brew" "Brew wrapper: auto-updates .brewfile and commits via YADM"
register_command "Brew" "brew-sync" "Install everything from the brewfile"

# ── Git ───────────────────────────────────────────────────────────────────────

checkout() { gh pr checkout "$@"; }

register_command "Git" "checkout" "Shortcut for gh pr checkout"

wt() {
  local dir
  dir=$(tv git-worktrees) && pushd "$dir"
}

w() {
  tv git-repos --height 20
}

register_command "Git" "wt" "Pick a git worktree and pushd into it"

# ── Navigation ────────────────────────────────────────────────────────────────

s() {
  local choice
  choice=$(ls -1 ~/src/ | gum filter --height 10 --header "Pick a directory:") || return 1
  pushd ~/src/"$choice"
}

t() {
  local session
  session=$(tmux list-sessions -F \#S | gum filter --height 10 --placeholder "Pick tmux session:") || return 1
  tmux switch-client -t "$session" || tmux attach -t "$session"
}

register_command "Navigation" "s" "Fuzzy-pick a directory under ~/src and pushd into it"
register_command "Navigation" "t" "Fuzzy-pick a tmux session and attach"

alias back=popd
register_command "Navigation" "back" "Return to previous directory (popd)"

# ── Copilot ───────────────────────────────────────────────────────────────────

ce() {
  mkdir -p /Users/loganbussell/src/_ephemeral/
  pushd /Users/loganbussell/src/_ephemeral/
  copilot && popd
}

dotcopilot() {
  pushd ~ >/dev/null || return
  copilot "$@"
  local status=$?
  popd >/dev/null || return "$status"
  return "$status"
}

btw() {
  local prompt
  if [[ $# -gt 0 ]]; then
    prompt="$*"
  else
    prompt=$(cat)
  fi
  copilot --silent --stream on --no-custom-instructions \
    --model gpt-5.4-mini \
    --available-tools rg glob view web_search web_fetch \
    --allow-all-tools \
    --prompt "$prompt"
}

please() {
  local prompt
  if [[ $# -gt 0 ]]; then
    prompt="$*"
  else
    prompt=$(cat)
  fi
  copilot --silent --stream on --no-custom-instructions \
    --model gpt-5.4 \
    --available-tools rg glob view web_search web_fetch bash read_bash write_bash stop_bash list_bash \
    --allow-all-tools \
    --prompt "You are a helpful terminal assistant. Do what the user asks — take action, don't just explain. Be concise. User request: $prompt"
}

alias copilot='copilot --yolo'
alias c='copilot'
alias cr='copilot --resume'
alias cont='copilot --resume'

register_command "Copilot" "c" "Alias for copilot"
register_command "copilot" "ce" "Open ephemeral copilot session"
register_command "copilot" "btw" "Ask Copilot a quick read-only question"
register_command "copilot" "please" "Ask Copilot to do something (has shell access)"
register_command "copilot" "dotcopilot" "Open Copilot CLI in dotfiles home"

# ── Docker workspace ──────────────────────────────────────────────────────────

open-docker-workspace-ghostty() {
  osascript "$HOME/scripts/open-docker-workspace-ghostty.applescript" "$@"
}

register_command "Ghostty" "open-docker-workspace-ghostty" "Open docker workspace [--triage | --run-triage]"

open-docker-workspace-wezterm() {
  local do_triage=false
  local auto_run=false

  for arg in "$@"; do
    case "$arg" in
      --run-triage) do_triage=true; auto_run=true ;;
      --triage)     do_triage=true ;;
    esac
  done

  local home="$HOME"
  local cmd='copilot --yolo -i "/triage-pull-requests"'
  local cmd2='copilot --yolo -i "/triage-pipelines"'

  local pane1
  pane1=$(wezterm cli spawn --new-window --cwd "$home/src/dotnet-docker")

  local window_id
  window_id=$(wezterm cli list --format json | python3 -c "
import json, sys
panes = json.load(sys.stdin)
target = int(sys.argv[1])
for p in panes:
    if p['pane_id'] == target:
        print(p['window_id'])
        break
" "$pane1")

  local pane2
  pane2=$(wezterm cli spawn --window-id "$window_id" --cwd "$home/src/docker-tools")

  local pane3
  pane3=$(wezterm cli spawn --window-id "$window_id" --cwd "$home/src/dotnet-framework-docker")

  if $do_triage; then
    local newline=""
    if $auto_run; then
      newline=$'\n'
    fi

    wezterm cli send-text --pane-id "$pane1" --no-paste "${cmd}${newline}"
    local split1
    split1=$(wezterm cli split-pane --pane-id "$pane1" --right --cwd "$home/src/dotnet-docker")
    wezterm cli send-text --pane-id "$split1" --no-paste "${cmd2}${newline}"

    wezterm cli send-text --pane-id "$pane2" --no-paste "${cmd}${newline}"
    local split2
    split2=$(wezterm cli split-pane --pane-id "$pane2" --right --cwd "$home/src/docker-tools")
    wezterm cli send-text --pane-id "$split2" --no-paste "${cmd2}${newline}"

    wezterm cli send-text --pane-id "$pane3" --no-paste "${cmd}${newline}"
    local split3
    split3=$(wezterm cli split-pane --pane-id "$pane3" --right --cwd "$home/src/dotnet-framework-docker")
    wezterm cli send-text --pane-id "$split3" --no-paste "${cmd2}${newline}"
  fi

  wezterm cli activate-pane --pane-id "$pane1"
}

register_command "WezTerm" "open-docker-workspace-wezterm" "Open docker workspace [--triage | --run-triage]"
