-- clangd formatea con clang-format; sin .clang-format en el proyecto usa Google
-- en vez de LLVM. El resto de argumentos son los que trae el extra lang.clangd.
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
        },
      },
    },
  },
}
