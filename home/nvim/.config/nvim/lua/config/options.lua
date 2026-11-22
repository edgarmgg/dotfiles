-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- Vim: scrolloff=5, virtualedit=onemore, updatetime=300
opt.scrolloff = 5
opt.virtualedit = "onemore" -- el cursor puede ir una columna más allá del final de línea
opt.updatetime = 300

-- Estilo Google: 2 espacios (LazyVim ya lo hace; se deja explícito)
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2

-- Swap y undo: no se tocan. Neovim ya los guarda en ~/.local/state/nvim
-- (fuera de los proyectos) y no conviene compartir esos ficheros con Vim.

-- Corrector ortográfico en inglés y español (LazyVim lo activa en md/txt/gitcommit)
opt.spelllang = { "en", "es" }
