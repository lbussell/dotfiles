# dotfiles

My dotfiles, managed with [chezmoi](https://github.com/twpayne/chezmoi).

The repository root contains infrastructure. A root-level `.chezmoiroot` points chezmoi at `home/` for the actual source tree.

## Install

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply lbussell
```

The root-level `.chezmoiroot` file points chezmoi at `home/`.

## Render example outputs

```bash
./scripts/render-examples.sh
```

This writes rendered examples to `.rendered-examples/`.
