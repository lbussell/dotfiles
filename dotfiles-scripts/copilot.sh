# copilot.sh — Copilot CLI helpers

ce() {
  pushd /Users/loganbussell/src/scratchpad/;
  copilot && popd;
}

register_command "Copilot" "ce" "Open Copilot CLI in scratchpad (ephemeral)"
