# Aliases
alias l='ls -la -G -1'
alias ll='ls -lah -G'
alias lg='lazygit'
alias lgy='lazygit --git-dir="$HOME/.local/share/yadm/repo.git" --work-tree="$HOME"'

# Reload zshrc
alias reload='source ~/.zshrc'
# Easily put things in the clipboard
# ls -l | clip
# pwd | clip
# cat file.txt | clip OR clip < file.txt
alias clip='pbcopy'
# ghostty config
# Reload ghostty config with cmd+shift+comma (ctrl+shift+comma on Linux)
alias ged='ghostty +edit-config'

# Colors in ls
export CLICOLOR=1

# Prompt: green username, directory, and %
# PROMPT='[%F{green}%n%f %1~] %F{green}%#%f '
setopt PROMPT_SUBST
PROMPT='%F{green}[%f%F{green}%n%f %1~%F{green}]%f%F{green}%# %f'

# Use neovim instead of vim
export EDITOR='nvim'
alias vim='nvim'

# .NET SDK tools
export PATH="$PATH:/Users/loganbussell/.dotnet/tools"

# Atuin configuration
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# Set tab title to current directory (and keep it that way)
DISABLE_AUTO_TITLE="true"
precmd() {
  echo -ne "\033]0;${PWD##*/}\007"
}
preexec() {
  echo -ne "\033]0;${PWD##*/}\007"
}

# Brew wrapper: auto-update .brewfile and commit via YADM
brew() {
  command brew "$@"
  local exit_code=$?
  command brew bundle dump --force --no-vscode --file=~/.brewfile
  yadm add ~/.brewfile
  yadm diff --quiet --cached -- ~/.brewfile || yadm commit -m "brew $*"
}

# Install everything from the brewfile
brew-sync() {
  command brew bundle --file=~/.brewfile
  return $exit_code
}

# Print dotfiles README
dotfiles() { cat ~/README.md; }
alias help='dotfiles'

# Shortcut for gh pr checkout
checkout() { gh pr checkout "$@"; }

# c -> Open Copilot CLI
alias c="copilot"

# c -> Copilot "ephemeral"
# Open Copilot CLI in scratchpad
ce() {
  pushd /Users/loganbussell/src/scratchpad/;
  copilot && popd;
}

# Add ~/src/bin to PATH
export PATH="$HOME/src/bin:$PATH"

# Worktrunk: switch/create worktree and open copilot
alias wsc='wt switch -x copilot'

# Worktrunk: interactive worktree wizard (gum-powered)
wti() {
  # Step 1: What do you want to do?
  local action
  action=$(gum choose --header="What do you want to do?" \
    "Create a new branch" \
    "Switch to existing worktree" \
    "Check out a PR") || return 0

  local cmd="wt switch"

  case "$action" in
    "Create a new branch")
      # Branch name
      local branch
      branch=$(gum input --header="Branch name" --placeholder="my-feature") || return 0
      [[ -z "$branch" ]] && { echo "No branch name provided."; return 1; }

      # Base branch
      local base
      base=$(gum choose --header="Base branch" \
        "upstream/main" \
        "upstream/nightly" \
        "(custom)") || return 0

      if [[ "$base" == "(custom)" ]]; then
        base=$(gum input --header="Custom base branch" --placeholder="origin/main") || return 0
        [[ -z "$base" ]] && { echo "No base branch provided."; return 1; }
      fi

      cmd+=" --create $branch --base $base"
      ;;

    "Switch to existing worktree")
      local branches
      branches=$(wt list --format=json --branches 2>/dev/null \
        | jq -r '.[] | ((now - .commit.timestamp) / 3600 | floor) as $h |
          (if $h < 1 then "just now" elif $h < 24 then "\($h)h" elif ($h/24|floor) < 30 then "\($h/24|floor)d" elif ($h/24|floor) < 365 then "\($h/24/30|floor)mo" else "\($h/24/365|floor)y" end) as $age |
          "\(.branch) (\(.kind), \($age))"' 2>/dev/null)
      [[ -z "$branches" ]] && { echo "No branches found."; return 1; }

      local selection
      selection=$(echo "$branches" | gum choose --header="Pick a branch") || return 0
      cmd+=" ${selection%% (*}"
      ;;

    "Check out a PR")
      local pr
      pr=$(gum input --header="PR number" --placeholder="123") || return 0
      [[ -z "$pr" ]] && { echo "No PR number provided."; return 1; }
      cmd+=" pr:$pr"
      ;;
  esac

  # Launch copilot?
  if gum confirm "Launch copilot after switching?" --default; then
    cmd+=" -x copilot"
  fi

  # Show and execute
  gum style --faint "→ $cmd"
  eval "$cmd"
}

# MOTD: yadm dotfiles status
() {
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
}

s() {
  local choice
  choice=$(ls -1 ~/src/ | gum filter --height 10 --header "Pick a directory:") || return 1
  pushd ~/src/"$choice"
}

. "$HOME/.local/bin/env"

# BEGIN Agency MANAGED BLOCK
if [[ ":${PATH}:" != *":/Users/loganbussell/.config/agency/CurrentVersion:"* ]]; then
    export PATH="/Users/loganbussell/.config/agency/CurrentVersion:${PATH}"
fi
# END Agency MANAGED BLOCK

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
