-- Custom configuration: plugins, keymaps, options
-- This file is separate from kickstart's init.lua to avoid merge conflicts on upstream updates.

local gh = function(repo) return 'https://github.com/' .. repo end

-- ============================================================
-- Options
-- ============================================================

vim.opt.modeline = false
vim.o.relativenumber = true
vim.o.number = true

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevel = 99
vim.opt.foldenable = true

-- Linker script syntax highlighting
vim.filetype.add({ extension = { lds = 'ld' } })

-- C/C++ tab settings
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'c,h,cpp',
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- ============================================================
-- Plugins
-- ============================================================

-- Telescope live grep args + custom defaults
vim.pack.add { gh 'nvim-telescope/telescope-live-grep-args.nvim' }
require('telescope').setup {
  defaults = {
    vimgrep_arguments = {
      'rg', '--color=never', '--no-heading', '--with-filename',
      '--line-number', '--column', '--smart-case', '--follow',
    },
    mappings = {
      i = {
        ['<C-j>'] = require('telescope.actions').cycle_history_next,
        ['<C-k>'] = require('telescope.actions').cycle_history_prev,
      },
    },
  },
}
pcall(require('telescope').load_extension, 'live_grep_args')

-- vim-tmux-navigator
vim.pack.add { gh 'christoomey/vim-tmux-navigator' }

-- vim-fugitive (git commands via :G)
vim.pack.add { gh 'tpope/vim-fugitive' }

-- nvim-navic (breadcrumbs)
vim.pack.add {
  gh 'SmiteshP/nvim-navic',
}
require('nvim-navic').setup {
  highlight = true,
  separator = ' > ',
  depth_limit = 0,
  depth_limit_indicator = '..',
  safe_output = true,
}

-- lazygit
vim.pack.add { gh 'kdheepak/lazygit.nvim' }

-- flash.nvim
vim.pack.add { gh 'folke/flash.nvim' }
require('flash').setup {}

-- vim-maximizer
vim.pack.add { gh 'szw/vim-maximizer' }

-- toggleterm
vim.pack.add { gh 'akinsho/toggleterm.nvim' }
require('toggleterm').setup {}

-- diffview
vim.pack.add { gh 'sindrets/diffview.nvim' }

-- lazydev (better lua LSP for neovim config)
vim.pack.add { gh 'folke/lazydev.nvim' }
require('lazydev').setup {}

-- neo-tree
vim.pack.add {
  gh 'nvim-neo-tree/neo-tree.nvim',
  gh 'MunifTanjim/nui.nvim',
}
require('neo-tree').setup {}

-- ============================================================
-- LSP customizations
-- ============================================================

-- Disable stylua as LSP (it's a formatter, not an LSP server — upstream bug)
vim.lsp.enable('stylua', false)

vim.lsp.config('pyright', {})
vim.lsp.enable('pyright')

vim.lsp.config('clangd', {
  cmd = {
    'clangd',
    '--background-index',
    '--clang-tidy',
    '--completion-style=detailed',
    '--header-insertion=never',
  },
})
vim.lsp.enable('clangd')

-- nvim-navic attach on LspAttach
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('custom-navic-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentSymbolProvider then
      local ok = pcall(require('nvim-navic').attach, client, event.buf)
      if ok then
        vim.opt_local.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
      end
    end
  end,
})

-- ============================================================
-- Formatting customizations
-- ============================================================

-- Add python formatter
local conform = require 'conform'
conform.formatters_by_ft.python = { 'black' }

-- ============================================================
-- Telescope keymaps
-- ============================================================

local builtin = require 'telescope.builtin'

vim.keymap.set('n', '<leader>sg', function()
  require('telescope').extensions.live_grep_args.live_grep_args()
end, { desc = '[S]earch by [G]rep (with args)' })

vim.keymap.set('n', '<leader>sG', function()
  builtin.live_grep {
    additional_args = function(_)
      return { '--smart-case' }
    end,
  }
end, { desc = '[S]earch by [G]rep (case sensitive)' })

vim.keymap.set('n', '<leader>sp', function()
  local dir = vim.fn.input('Grep in dir: ', vim.fn.getcwd(), 'dir')
  builtin.live_grep { cwd = dir }
end, { desc = '[S]earch by grep in custom [P]ath' })

vim.keymap.set('n', '<leader>se', function()
  local ext = vim.fn.input 'File extension: '
  if ext ~= '' then
    builtin.find_files { find_command = { 'rg', '--files', '-g', '*.' .. ext } }
  end
end, { desc = '[S]earch files by [E]xtension' })

vim.keymap.set('n', '<leader>sC', function()
  local dir = vim.fn.expand '%:p:h'
  require('telescope').extensions.live_grep_args.live_grep_args { search_dirs = { dir } }
end, { desc = '[S]earch by grep in [C]urrent file dir' })

vim.keymap.set('n', '<leader>sF', function()
  local dir = vim.fn.input('Find files in: ', vim.fn.getcwd() .. '/', 'dir')
  if dir ~= '' then
    builtin.find_files { cwd = dir }
  end
end, { desc = '[S]earch [F]iles in custom dir' })

-- ============================================================
-- General keymaps
-- ============================================================

-- Tmux navigator
vim.keymap.set('n', '<c-h>', '<cmd>TmuxNavigateLeft<cr>')
vim.keymap.set('n', '<c-j>', '<cmd>TmuxNavigateDown<cr>')
vim.keymap.set('n', '<c-k>', '<cmd>TmuxNavigateUp<cr>')
vim.keymap.set('n', '<c-l>', '<cmd>TmuxNavigateRight<cr>')
vim.keymap.set('n', '<c-\\>', '<cmd>TmuxNavigatePrevious<cr>')

-- LazyGit
vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<cr>', { desc = 'LazyGit' })
vim.keymap.set('n', '<leader>lf', '<cmd>LazyGitCurrentFile<cr>', { desc = 'LazyGit current file' })

-- Flash
vim.keymap.set({ 'n', 'x', 'o' }, '<leader>j', function() require('flash').jump() end, { desc = 'Flash jump' })

-- Maximizer
vim.keymap.set('n', '<leader>wz', ':MaximizerToggle<CR>', { desc = 'Toggle maximize window' })

-- Splits
vim.keymap.set('n', '<leader>wv', ':vsplit<CR>', { desc = 'Vertical split' })
vim.keymap.set('n', '<leader>ws', ':split<CR>', { desc = 'Horizontal split' })
vim.keymap.set('n', '<leader>wo', ':%bd|e#<CR>', { desc = 'Close all buffers except current' })

-- Neo-tree
vim.keymap.set('n', '<leader>ee', ':Neotree toggle<CR>', { desc = 'Toggle file explorer' })
vim.keymap.set('n', '<leader>er', ':Neotree reveal<CR>', { desc = 'Reveal file in Neo-tree' })

-- Toggle relative line numbers
vim.keymap.set('n', '<leader>wp', function()
  vim.wo.relativenumber = not vim.wo.relativenumber
end, { desc = 'Toggle relative line numbers' })

-- Copy file name
vim.keymap.set('n', '<leader>un', function()
  local filename = vim.fn.expand '%:t'
  vim.fn.setreg('+', filename)
  vim.notify('Copied file name: ' .. filename, vim.log.levels.INFO)
end, { desc = 'Utils: copy file name' })

-- Copy full file path
vim.keymap.set('n', '<leader>up', function()
  local filepath = vim.fn.expand '%:p'
  vim.fn.setreg('+', filepath)
  vim.notify('Copied file path: ' .. filepath, vim.log.levels.INFO)
end, { desc = 'Utils: copy file path' })

-- Copy directory path
vim.keymap.set('n', '<leader>ud', function()
  local dir = vim.fn.expand '%:p:h'
  vim.fn.setreg('+', dir)
  vim.notify('Copied directory: ' .. dir, vim.log.levels.INFO)
end, { desc = 'Utils: copy directory' })

-- Git rebase interactive to commit that last changed current line
vim.keymap.set('n', '<leader>gi', function()
  local hash = vim.trim(vim.fn.system('git log -n 1 --pretty=format:%H -L ' .. vim.fn.line('.') .. ',' .. vim.fn.line('.') .. ':' .. vim.fn.expand('%'))):sub(1, 40)
  if hash == '' then
    vim.notify('No commit found for this line', vim.log.levels.WARN)
    return
  end
  vim.cmd('G rebase -i ' .. hash .. '^')
end, { desc = '[G]it rebase [I]nteractive to line commit' })
