# navigation.sh — Directory and session navigation helpers

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
