# dotfiles

My dotfiles, managed with [chezmoi](https://github.com/twpayne/chezmoi).

## Install

### Linux

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io/lb)" -- init --apply lbussell
```

### Windows

```pwsh
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/lbussell/dotfiles/main/Setup-Windows.ps1)))
chezmoi init lbussell
chezmoi diff
chezmoi apply
```

The setup script installs chezmoi and gum with WinGet, then configures the
active PowerShell profile to load the shared profile managed by chezmoi.
