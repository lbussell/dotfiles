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

wn() {
  local base_choice
  local branch
  local remote
  local remote_branch
  local remote_branches
  local remotes
  local repo_name
  local repo_root
  local start_point
  local origin_url
  local worktree_path
  local worktrees_dir

  git rev-parse --git-common-dir >/dev/null 2>&1 || {
    echo "Not in a git repository."
    return 1
  }

  repo_root=$(git rev-parse --show-toplevel) || return 1
  origin_url=$(git config --get remote.origin.url 2>/dev/null)
  if [ -n "$origin_url" ]; then
    repo_name=$(printf '%s\n' "$origin_url" | sed 's#/*$##; s#\.git$##; s#^.*/##; s#^.*:##')
  fi
  if [ -z "$repo_name" ]; then
    repo_name=$(basename "$repo_root") || return 1
  fi

  if [ -n "$WORKTREES_DIR" ]; then
    worktrees_dir=$WORKTREES_DIR
  else
    worktrees_dir="$HOME/w"
  fi
  case "$worktrees_dir" in
    "~") worktrees_dir=$HOME ;;
    "~/"*) worktrees_dir="$HOME/${worktrees_dir#"~/"}" ;;
  esac

  remotes=$(git remote) || return 1
  base_choice=$(
    {
      echo "HEAD"
      printf '%s\n' "$remotes" | sed '/^$/d; s/^/remote: /'
    } | gum choose --height 10 --header "Create new worktree from:" --no-show-help
  ) || return 1

  case "$base_choice" in
    HEAD)
      start_point=HEAD
      ;;
    remote:\ *)
      remote=${base_choice#remote: }
      git fetch "$remote" || return 1

      remote_branches=$(git for-each-ref --format='%(refname)' "refs/remotes/$remote" | awk -v prefix="refs/remotes/$remote/" '
        $0 == prefix "HEAD" { next }
        index($0, prefix) == 1 { print substr($0, length(prefix) + 1) }
      ') || return 1
      if [ -z "$remote_branches" ]; then
        echo "No branches found for remote '$remote'."
        return 1
      fi

      remote_branch=$(printf '%s\n' "$remote_branches" | gum filter --height 10 --header "Pick a branch from $remote:" --no-show-help) || return 1
      start_point="$remote/$remote_branch"
      ;;
    *)
      echo "Invalid start point: $base_choice"
      return 1
      ;;
  esac

  branch=$(gum input --prompt "Branch name: " --placeholder "feature/my-branch") || return 1
  if [ -z "$branch" ]; then
    echo "Branch name is required."
    return 1
  fi

  worktree_path="$worktrees_dir/$repo_name/$branch"
  mkdir -p "$(dirname "$worktree_path")" || return 1
  git worktree add -b "$branch" "$worktree_path" "$start_point" || return 1
  pushd "$worktree_path"
}
