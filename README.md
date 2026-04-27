# dotfiles

## Windows setup

Install the curated WinGet package list from any shell with `pwsh` on `PATH`:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/lbussell/dotfiles/main/Setup-Windows.ps1 | iex"
```

The script imports `winget-packages.json` and assumes WinGet is already available.
