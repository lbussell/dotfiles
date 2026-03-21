# .zshrc

# Prompt: green username, directory, and %
setopt PROMPT_SUBST
PROMPT='%F{green}[%f%F{green}%n%f %1~%F{green}]%f%F{green}%# %f'

# Aliases
alias l='ls -la -G -1'
alias ll='ls -lah -G'
alias lg='lazygit'
alias lgy='lazygit --git-dir="$HOME/.local/share/yadm/repo.git" --work-tree="$HOME"'

# Reload zshrc
alias reload='source ~/.zshrc'

# Easily put things in the clipboard
# - `ls -l | clip`
# - `pwd | clip`
# - `cat file.txt | clip`
# - `clip < file.txt``
alias clip='pbcopy'

# ghostty config
# Reload ghostty config with cmd+shift+comma (ctrl+shift+comma on Linux).
# ghostty is also set up to type `ghostty +edit-config` when you press cmd+comma.
alias ged='ghostty +edit-config'

# Colors in ls
export CLICOLOR=1

# Use neovim instead of vim
export EDITOR='nvim'
alias vim='nvim'

# .NET SDK tools
export PATH="$PATH:/Users/loganbussell/.dotnet/tools"

# Atuin configuration
eval "$(atuin init zsh)"

# Helper functions/commands (sourced from ~/dotfiles-scripts/)
source "$HOME/dotfiles-scripts/index.sh"

# Aliases that reference helper functions
alias c="copilot"
alias wsc='wt switch -x copilot'

# MOTD
dotfiles_motd

# Add ~/src/bin to PATH
export PATH="$HOME/src/bin:$PATH"

# ~/.local/bin for standalone tools (e.g. claude)
export PATH="$HOME/.local/bin:$PATH"

# BEGIN Agency MANAGED BLOCK
if [[ ":${PATH}:" != *":/Users/loganbussell/.config/agency/CurrentVersion:"* ]]; then
    export PATH="/Users/loganbussell/.config/agency/CurrentVersion:${PATH}"
fi
# END Agency MANAGED BLOCK

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# Open dotfiles repo in browser
alias dotfiles="open https://github.com/lbussell/dotfiles"


if [ -f "$HOME/Library/Application Support/dnvm/env" ]; then
    . "$HOME/Library/Application Support/dnvm/env"
fi