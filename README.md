# dotfiles

My dotfiles, managed with [chezmoi](https://github.com/twpayne/chezmoi).

## Install

### macOS and Linux

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply lbussell
```

### Windows

```pwsh
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/lbussell/dotfiles/main/Setup-Windows.ps1)))
```
