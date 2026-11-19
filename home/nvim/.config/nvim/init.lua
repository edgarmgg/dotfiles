-- Plantillas, sync .h/.cc, Makefile y erratas: Vimscript compartido con Vim.
-- Se carga aquí y no en autocmds.lua porque ese fichero se carga tarde
-- (VeryLazy) y el BufNewFile de `nvim nuevo.cc` ya habría pasado.
local cc_tools = vim.fn.expand("~/.vim/cc-tools.vim")
if vim.uv.fs_stat(cc_tools) then
  vim.cmd.source(cc_tools)
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
