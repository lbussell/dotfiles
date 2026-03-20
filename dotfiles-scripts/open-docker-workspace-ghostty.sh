# open-docker-workspace-ghostty.sh — Ghostty window with docker repo tabs

open-docker-workspace-ghostty() {
  osascript "$HOME/dotfiles-scripts/open-docker-workspace-ghostty.applescript" "$@"
}

register_command "Ghostty" "open-docker-workspace-ghostty" "Open docker workspace [--triage | --run-triage]"
