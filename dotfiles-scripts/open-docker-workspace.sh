# open-docker-workspace.sh — Ghostty window with docker repo tabs

open-docker-workspace() {
  osascript "$HOME/dotfiles-scripts/open-docker-workspace.applescript" "$@"
}

register_command "Ghostty" "open-docker-workspace" "Open docker workspace [--triage | --run-triage]"
