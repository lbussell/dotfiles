# motd.sh — Message of the day: yadm dotfiles status

dotfiles_motd() {
  local ahead behind added deleted
  local counts=$(yadm rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
  [[ -z "$counts" ]] && return
  read ahead behind <<< "$counts"
  local stats=$(yadm diff --numstat HEAD 2>/dev/null | awk '{a+=$1; d+=$2} END {print a" "d}')
  added=${stats%% *}
  deleted=${stats##* }
  local yellow=$'\e[33m' green=$'\e[32m' red=$'\e[31m' reset=$'\e[0m'
  local sync_status
  if (( ahead > 0 && behind > 0 )); then
    sync_status="${yellow}↑${ahead}↓${behind}${reset}"
  elif (( ahead > 0 )); then
    sync_status="${yellow}↑${ahead}${reset}"
  elif (( behind > 0 )); then
    sync_status="${yellow}↓${behind}${reset}"
  else
    sync_status="${green}✓${reset}"
  fi
  local diff_status
  if [[ -n "$added" || -n "$deleted" ]]; then
    diff_status="${green}+${added}${reset}/${red}-${deleted}${reset}"
  else
    diff_status="-/-"
  fi
  local dim=$'\e[2m'
  print "Dotfiles: ${sync_status} ${diff_status} ${dim}(status: run \`lgy\`)${reset}"
  print "${dim}Worktree: wsc -c <name> --base upstream/main | upstream/nightly | wsc pr:123 | wti${reset}"
  print "${dim}Help: run \`dothelp\` for all available commands${reset}"
}
