# copilot.sh — Copilot CLI helpers

ce() {
  pushd /Users/loganbussell/src/scratchpad/;
  copilot && popd;
}

register_command "Copilot" "ce" "Open Copilot CLI in scratchpad (ephemeral)"

dotcopilot() {
  pushd ~ > /dev/null || return
  copilot "$@"
  local status=$?
  popd > /dev/null || return "$status"
  return "$status"
}

register_command "Copilot" "dotcopilot" "Open Copilot CLI in dotfiles home"

alias c='copilot'
alias cy='copilot --yolo'

register_command "Copilot" "c" "Alias for copilot"
register_command "Copilot" "cy" "Alias for copilot --yolo"
