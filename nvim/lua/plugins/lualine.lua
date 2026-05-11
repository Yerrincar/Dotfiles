-- Set lualine as statusline
return {
  'nvim-lualine/lualine.nvim',
  config = function()
    -- Paleta clara tipo gruvbox (fondo oscuro)
    local colors = {
      none = 'none',
      white = '#ffffff',
      fg_lt = '#ebdbb2',
      yellow = '#fabd2f',
      blue = '#83a598',
      purple = '#d3869b',
      aqua = '#8ec07c',
      red = '#fb4934',
      gray1 = '#a89984',
    }

    -- Tema personalizado: transparente + gruvbox-like + insert en blanco
    local onedark_theme = {
      normal = {
        a = { fg = colors.fg_lt, bg = colors.none, gui = 'bold' },
        b = { fg = colors.fg_lt, bg = colors.none },
        c = { fg = colors.fg_lt, bg = colors.none },
      },
      insert = { a = { fg = colors.white, bg = colors.none, gui = 'bold' } },
      visual = { a = { fg = colors.purple, bg = colors.none, gui = 'bold' } },
      replace = { a = { fg = colors.red, bg = colors.none, gui = 'bold' } },
      command = { a = { fg = colors.yellow, bg = colors.none, gui = 'bold' } },
      terminal = { a = { fg = colors.aqua, bg = colors.none, gui = 'bold' } },
      inactive = {
        a = { fg = colors.gray1, bg = colors.none, gui = 'bold' },
        b = { fg = colors.gray1, bg = colors.none },
        c = { fg = colors.gray1, bg = colors.none },
      },
    }

    -- Import color theme based on environment variable NVIM_THEME
    local env_var_nvim_theme = os.getenv 'NVIM_THEME' or 'onedark'

    -- Define a table of themes
    local themes = {
      onedark = onedark_theme, -- nuestro tema custom
      nord = 'nord',           -- fallback al tema integrado de lualine
    }

    local mode = {
      'mode',
      fmt = function(str)
        return ' ' .. str
      end,
    }

    local filename = {
      'filename',
      file_status = true,
      path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
    }

    local hide_in_width = function()
      return vim.fn.winwidth(0) > 100
    end

    local diagnostics = {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      sections = { 'error', 'warn' },
      symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
      colored = false,
      update_in_insert = false,
      always_visible = false,
      cond = hide_in_width,
    }

    local diff = {
      'diff',
      colored = false,
      symbols = { added = ' ', modified = ' ', removed = ' ' },
      cond = hide_in_width,
    }

    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = themes[env_var_nvim_theme], -- usa nuestro custom si NVIM_THEME=onedark
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        disabled_filetypes = { 'alpha', 'neo-tree', 'Avante' },
        always_divide_middle = true,
      },
      sections = {
        lualine_a = { mode },
        lualine_b = { 'branch' },
        lualine_c = { filename },
        lualine_x = { diagnostics, diff, { 'encoding', cond = hide_in_width }, { 'filetype', cond = hide_in_width } },
        lualine_y = { 'location' },
        lualine_z = { 'progress' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { { 'location', padding = 0 } },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = { 'fugitive' },
    }
  end,
}
