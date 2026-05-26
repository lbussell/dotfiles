-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore

return {
  { "LazyVim/LazyVim", opts = { colorscheme = "color256" } },
  { "rktjmp/lush.nvim" },
  -- point Lazy at your local clone
  { dir = vim.fn.expand("~/src/nvim-color256"), name = "color256", lazy = false, priority = 1000 },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = require("color256.lualine")
    end,
  },
}
