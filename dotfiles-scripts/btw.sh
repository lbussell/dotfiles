# btw.sh — Quick question to Copilot (read-only, search only)

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

register_command "Copilot" "btw" "Ask Copilot a quick read-only question"
