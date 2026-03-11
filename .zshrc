# Aliases
alias l='ls -la -G -1'
alias ll='ls -lah -G'
alias lg='lazygit'
alias lgy='lazygit --git-dir="$HOME/.local/share/yadm/repo.git" --work-tree="$HOME"'
alias cz='chezmoi'
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
alias wt="/Users/loganbussell/src/worktree-manager/artifacts/WorktreeManager/WorktreeManager"
wtcd() { pushd "$(wt d "$1")" }
wtcp() { pushd "$(wt d "$1")" && if [[ -n "$2" ]]; then copilot --yolo -i "$2"; else copilot --yolo; fi }

. "$HOME/.local/bin/env"

# BEGIN Agency MANAGED BLOCK
if [[ ":${PATH}:" != *":/Users/loganbussell/.config/agency/CurrentVersion:"* ]]; then
    export PATH="/Users/loganbussell/.config/agency/CurrentVersion:${PATH}"
fi
# END Agency MANAGED BLOCK
