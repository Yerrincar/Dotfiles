return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    vim.filetype.add {
      pattern = {
        ['.*/.github/workflows/.*%.ya?ml'] = 'yaml.ghaction',
      },
    }

    local lint = require 'lint'

    lint.linters_by_ft = {
      bash = { 'shellcheck' },
      dockerfile = { 'hadolint' },
      helm = {},
      sh = { 'shellcheck' },
      yaml = { 'yamllint' },
      ['yaml.ghaction'] = { 'actionlint', 'yamllint' },
      zsh = { 'shellcheck' },
    }

    local group = vim.api.nvim_create_augroup('nvim-lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = group,
      callback = function(args)
        local filetype = vim.bo[args.buf].filetype
        local name = vim.api.nvim_buf_get_name(args.buf)

        if filetype == 'helm' then
          if name:match '/Chart%.ya?ml$' or name:match '/values[^/]*%.ya?ml$' then
            lint.try_lint 'yamllint'
          end
          return
        end

        lint.try_lint()
      end,
    })
  end,
}
