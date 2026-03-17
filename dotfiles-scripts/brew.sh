# brew.sh — Brew wrapper with auto-commit and sync

brew() {
  command brew "$@"
  local exit_code=$?
  case "$1" in
    install|uninstall|remove|reinstall|upgrade)
      command brew bundle dump --force --no-vscode --file=~/.brewfile
      yadm add ~/.brewfile
      yadm diff --quiet --cached -- ~/.brewfile || yadm commit -m "brew $*"
      ;;
  esac
  return $exit_code
}

brew-sync() {
  command brew bundle --file=~/.brewfile
}

register_command "Brew" "brew" "Brew wrapper: auto-updates .brewfile and commits via YADM"
register_command "Brew" "brew-sync" "Install everything from the brewfile"
