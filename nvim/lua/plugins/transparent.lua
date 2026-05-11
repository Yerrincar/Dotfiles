-- plugins/transparent.lua
return {
  'xiyaowong/transparent.nvim',
  lazy = false,
  config = function()
    require('transparent').setup {
      groups = { -- grupos estándar que afectan statusline
        'Normal',
        'NormalNC',
        'NormalFloat',
        'FloatBorder',
        'StatusLine',
        'StatusLineNC',
        'EndOfBuffer',
      },
      extra_groups = {
        'VertSplit',
        'WinSeparator',
      },
    }

    -- Quita todos los highlights que empiecen con "lualine"
    require('transparent').clear_prefix 'lualine'
    require('transparent').clear_prefix 'bufferline'
  end,
}
