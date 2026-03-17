# git.sh — Git helper functions

checkout() { gh pr checkout "$@"; }

register_command "Git" "checkout" "Shortcut for gh pr checkout"
