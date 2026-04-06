# Copilot CLI helpers

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
