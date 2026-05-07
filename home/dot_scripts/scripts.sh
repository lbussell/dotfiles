# scripts.sh — Shell helper functions

s() {
  local choice
  choice=$(ls -1 ~/src/ | gum filter --height 10 --header "Pick a directory:") || return 1
  pushd ~/src/"$choice"
}
