-- Mismo tema que en Vim, con fondo transparente (el del terminal).
return {
  { "scottmckendry/cyberdream.nvim", lazy = false, priority = 1000, opts = { transparent = true } },
  { "LazyVim/LazyVim", opts = { colorscheme = "cyberdream" } },
  -- Temas que trae LazyVim por defecto y no uso.
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", name = "catppuccin", enabled = false },
}
