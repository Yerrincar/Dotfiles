return {
  'pmizio/typescript-tools.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'neovim/nvim-lspconfig',
  },
  ft = {
    'typescript',
    'typescriptreact',
    'javascript',
    'javascriptreact',
  },
  opts = {
    -- Puedes seguir usando tu propio on_attach si lo necesitas
    on_attach = function(client, bufnr)
      -- Mantenerlo vacío si ya gestionas esto globalmente
    end,
    settings = {
      -- Diagnóstico más rápido y separado del LSP principal
      separate_diagnostic_server = true,
      publish_diagnostic_on = 'insert_leave',

      -- Acciones disponibles como "code actions"
      expose_as_code_action = {
        'add_missing_imports',
        'remove_unused',
        'remove_unused_imports',
        'organize_imports',
        'fix_all',
      },

      -- Configuración del servidor
      tsserver_max_memory = 'auto',
      tsserver_locale = 'en',
      complete_function_calls = true,
      include_completions_with_insert_text = true,

      -- CodeLens (puedes activar si lo necesitas)
      code_lens = 'off',
      disable_member_code_lens = true,

      -- Cierre automático de etiquetas JSX (desactivado por seguridad)
      jsx_close_tag = {
        enable = false,
        filetypes = { 'javascriptreact', 'typescriptreact' },
      },

      -- Preferencias del archivo
      tsserver_file_preferences = {
        includeInlayParameterNameHints = 'all',
        includeCompletionsForModuleExports = true,
        quotePreference = 'auto',
      },

      -- Opciones de formateo
      tsserver_format_options = {
        allowIncompleteCompletions = false,
        allowRenameOfImportPath = true,
      },
    },
  },
}
