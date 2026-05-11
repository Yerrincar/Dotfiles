--For reference, check out github.com/hendrikmi

--Line number
vim.wo.number = true
vim.o.relativenumber = true

--Clipboard
vim.o.clipboard = 'unnamedplus'

--Line format
vim.o.wrap = false
vim.o.linebreak = true

--Mouse enable
vim.o.mouse = 'a'

--Tab/Indent behavior
vim.o.autoindent = true
vim.o.smartcase = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.showtabline = 2
vim.o.breakindent = true

--Cursos behavior
vim.o.scrolloff = 4
vim.o.sidescrolloff = 8

--Split windows behavior
vim.o.splitbelow = true
vim.o.splitright = true

--Colors
vim.opt.termguicolors = true

--Others
vim.o.numberwidth = 4
vim.o.backspace = 'indent,eol,start'
vim.o.pumheight = 10
vim.o.conceallevel = 0
vim.wo.signcolumn = 'yes'
vim.o.fileencoding = 'utf-8'
vim.o.cmdheight = 1
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.writebackup = false
vim.o.undofile = true
vim.o.completeopt = 'menuone,noselect'
vim.opt.formatoptions:remove {'c', 'r', 'o'}
vim.opt.runtimepath:remove 'usr/share/vim/vimfiles'
