# index.sh — Source all helper scripts in ~/dotfiles-scripts/
# Source help.sh first so register_command is available to all other scripts.

_dotfiles_scripts_dir="${0:A:h}"

source "$_dotfiles_scripts_dir/help.sh"

for _f in "$_dotfiles_scripts_dir"/*.sh; do
  [[ "$_f" == */index.sh ]] && continue
  [[ "$_f" == */help.sh ]] && continue
  source "$_f"
done

unset _f _dotfiles_scripts_dir
