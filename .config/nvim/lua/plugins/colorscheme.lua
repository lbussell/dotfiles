-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore

return {
  {
    "cpplain/flexoki.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "flexoki",
    },
  },
}
