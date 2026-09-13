show_chezmoi_motd() {
    local chezmoi_status

    if [ ! -t 0 ] || [ ! -t 1 ] || [ -f "$HOME/.hushlogin" ] ||
        [ -n "${CI:-}" ] || [ -n "${CHEZMOI:-}" ]; then
        return 0
    fi

    if ! command -v chezmoi >/dev/null 2>&1; then
        printf 'Cannot check your dotfiles: install chezmoi or add it to your PATH.\n' >&2
        return 0
    fi

    if chezmoi_status=$(chezmoi status --color=false); then
        if [ -z "$chezmoi_status" ]; then
            return 0
        fi
    else
        printf 'Could not check your dotfiles. Run chezmoi status to see what went wrong.\n' >&2
        return 0
    fi

    printf '%s\n' \
        'Your dotfiles have pending local changes.' \
        'Review changes:      chezmoi diff' \
        'Apply configuration: chezmoi apply' \
        'Sync from GitHub:    chezmoi update' \
        ''
}
