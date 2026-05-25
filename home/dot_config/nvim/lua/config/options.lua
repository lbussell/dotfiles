-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Use terminal 256 colors only.
-- Copied from https://github.com/LazyVim/LazyVim/discussions/1933
vim.cmd.colorscheme = nil
vim.opt.termguicolors = false
vim.cmd("set t_Co=256")
