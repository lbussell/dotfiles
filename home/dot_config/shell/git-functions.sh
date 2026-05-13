s() {
  local choice
  choice=$(ls -1 ~/src/ | gum filter --height 10 --header "Pick a directory:" --no-show-help) || return 1
  pushd ~/src/"$choice"
}

w() {
  local worktrees
  local choice
  local action
  local actions
  local branch
  local git_status
  local status_summary
  local pr
  local pr_info
  local pr_url

  git rev-parse --git-common-dir >/dev/null 2>&1 || {
    echo "Not in a git repository."
    return 1
  }

  worktrees=$(git worktree list --porcelain | awk -v h="$HOME" '
    /^worktree / { path=substr($0,10); next }
    /^branch /   { br=substr($0,8); sub("^refs/heads/","",br) }
    /^detached/  { br="detached" }
    /^$/         { disp=path; sub("^"h,"~",disp); print disp " [" br "]:" path; br="" }
    END          { if (path && br!="") { disp=path; sub("^"h,"~",disp); print disp " [" br "]:" path } }
  ') || return 1

  if [ -z "$worktrees" ]; then
    echo "No git worktrees found."
    return 1
  fi

  choice=$(echo "$worktrees" | gum choose --height 10 --label-delimiter=":" --header "Pick a worktree:" --no-show-help) || return 1

  branch=$(git -C "$choice" symbolic-ref --quiet --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git -C "$choice" rev-parse --short HEAD) || return 1
    branch="detached ($branch)"
  fi

  git_status=$(git -C "$choice" status --porcelain) || return 1
  status_summary=$(printf '%s\n' "$git_status" | awk '
    length($0) == 0 { next }
    substr($0, 1, 2) == "??" { untracked++; next }
    substr($0, 1, 1) != " " { staged++ }
    substr($0, 2, 1) != " " { unstaged++ }
    END { printf "%d staged, %d unstaged, %d untracked", staged, unstaged, untracked }
  ')

  pr="none"
  pr_info=$(cd "$choice" && gh pr view --json number,url,state --template '#{{.number}} {{.state}}: {{.url}}{{"\n"}}{{.url}}' 2>/dev/null) || pr_info=""
  if [ -n "$pr_info" ]; then
    pr=$(printf '%s\n' "$pr_info" | sed -n '1p')
    pr_url=$(printf '%s\n' "$pr_info" | sed -n '2p')
  fi

  printf '# Worktree\n- **Path:** %s\n- **Branch:** %s\n- **PR:** %s\n- **Status:** %s\n' "$choice" "$branch" "$pr" "$status_summary" | gum format
  echo ""

  actions=()
  actions+=("Go there")
  if [ -n "$pr_url" ]; then
    actions+=("Open PR in browser")
  fi
  actions+=("Remove worktree")

  action=$(printf '%s\n' "${actions[@]}" | gum choose --height 10 --header "What next:" --no-show-help) || return 1

  case "$action" in
    "Go there")
      pushd "$choice"
      ;;
    "Open PR in browser")
      open "$pr_url"
      ;;
    "Remove worktree")
      git worktree remove "$choice"
      ;;
  esac
}
