# motd.sh — Message of the day

dotfiles_motd() {
  local dim=$'\e[2m' reset=$'\e[0m'
  print "${dim}Run dothelp for available commands${reset}"
}
