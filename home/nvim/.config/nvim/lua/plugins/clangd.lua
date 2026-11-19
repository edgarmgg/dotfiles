-- clangd formatea con clang-format; sin .clang-format en el proyecto usa Google
-- en vez de LLVM. El resto de argumentos son los que trae el extra lang.clangd.
--
-- Solo muestro los errores de sintaxis por cosas sin cerrar o sin terminar
-- (';', '}', ')', comillas...). El resto de diagnósticos de clangd se descarta.
local function is_unclosed(diagnostic)
  local msg = diagnostic.message:lower()
  return msg:find("^expected ", 1)
    or msg:find("missing terminating", 1, true)
    or msg:find("unterminated", 1, true)
    or msg:find("to match this", 1, true)
    or msg:find("unexpected end of file", 1, true)
end

local function only_unclosed(err, result, ctx)
  if result and result.diagnostics then
    result.diagnostics = vim.tbl_filter(is_unclosed, result.diagnostics)
  end
  vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=Google",
          },
          handlers = { ["textDocument/publishDiagnostics"] = only_unclosed },
        },
      },
    },
  },
}
