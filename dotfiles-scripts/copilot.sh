# copilot.sh — Copilot CLI helpers

ce() {
  pushd /Users/loganbussell/src/scratchpad/;
  copilot && popd;
}

register_command "Copilot" "ce" "Open Copilot CLI in scratchpad (ephemeral)"

dotcopilot() {
  pushd ~ > /dev/null
  COPILOT_CUSTOM_INSTRUCTIONS_DIRS="$HOME/dotfiles-scripts/agents" copilot "$@"
  popd > /dev/null
}

register_command "Copilot" "dotcopilot" "Open Copilot CLI with dotfiles agent instructions"

alias c='copilot'
alias cy='copilot --yolo'

register_command "Copilot" "c" "Alias for copilot"
register_command "Copilot" "cy" "Alias for copilot --yolo"
