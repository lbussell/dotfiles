find_brew() {
    local brew_path

    brew_path="$(command -v brew 2>/dev/null || true)"
    if [[ -n "$brew_path" && -x "$brew_path" ]]; then
        printf '%s\n' "$brew_path"
        return 0
    fi

    for brew_path in \
        /opt/homebrew/bin/brew \
        /usr/local/bin/brew \
        /home/linuxbrew/.linuxbrew/bin/brew
    do
        if [[ -x "$brew_path" ]]; then
            printf '%s\n' "$brew_path"
            return 0
        fi
    done

    return 1
}
