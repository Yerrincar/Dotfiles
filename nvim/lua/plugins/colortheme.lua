return {
  'ellisonleao/gruvbox.nvim',
  priority = 1000, -- se carga antes que otros plugins
  config = function()
    require('gruvbox').setup {
      -- aquí puedes poner tus opciones
      contrast = 'hard', -- "hard", "medium" o "soft"
      transparent_mode = true,
    }

    -- Activa el esquema de colores
    vim.cmd.colorscheme 'gruvbox'
  end,
}
