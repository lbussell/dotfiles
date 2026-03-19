# please.sh — Ask Copilot to do something (read/write shell access)

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

register_command "Copilot" "please" "Ask Copilot to do something (has shell access)"
