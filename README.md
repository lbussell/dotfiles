# dotfiles

My dotfiles, managed with [chezmoi](https://github.com/twpayne/chezmoi).

The actual chezmoi source tree lives under `home/`. Repository-level infrastructure can live outside that directory.

## Install

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply lbussell
```

The generated chezmoi config points `sourceDir` at `home/`.

## Render example outputs

```bash
./scripts/render-examples.sh
```

This writes rendered examples to `.rendered-examples/`.
