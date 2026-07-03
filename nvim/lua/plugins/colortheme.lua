return {
  'ellisonleao/gruvbox.nvim',
  priority = 1000, -- se carga antes que otros plugins
  config = function()
    local theme = {
      background = 'dark',
      contrast = 'hard',
      transparent_mode = true,
    }
    local local_theme = vim.fn.expand '~/.config/nvim-local/theme.lua'

    if vim.fn.filereadable(local_theme) == 1 then
      local ok, override = pcall(dofile, local_theme)
      if ok and type(override) == 'table' then
        theme = vim.tbl_deep_extend('force', theme, override)
      end
    end

    vim.o.background = theme.background

    require('gruvbox').setup {
      -- aquí puedes poner tus opciones
      contrast = theme.contrast, -- "hard", "medium" o "soft"
      transparent_mode = theme.transparent_mode,
    }

    -- Activa el esquema de colores
    vim.cmd.colorscheme 'gruvbox'
  end,
}
