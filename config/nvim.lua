local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

vim.o.completeopt = 'menu,menuone,noselect'
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.wo.number = true
vim.wo.relativenumber = true

vim.cmd [[set mouse=a]]

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- Telescope
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' }, config = function()
    require('telescope').setup()
    vim.keymap.set('n', '<leader>/', require('telescope.builtin').current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer]' })
    vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
  end}

  -- Treesitter
  use { 'nvim-treesitter/nvim-treesitter', config = function()
    require('nvim-treesitter.configs').setup {
      highlight = { enable = true },
      indent = { enable = true },
    }
  end}

  use { 'nvim-treesitter/nvim-treesitter-textobjects', after = 'nvim-treesitter' }

  -- LSP
  use { 'neovim/nvim-lspconfig', after = { 'telescope.nvim', 'cmp-nvim-lsp' }, config = function()
    local on_attach = function(_, bufnr)
      local nmap = function(keys, func, desc)
        if desc then
          desc = 'LSP: ' .. desc
        end
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
      end

      nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

      nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
      nmap('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
      nmap('gr', require('telescope.builtin').lsp_references)
      nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
      nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
      nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
      nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

      vim.api.nvim_buf_create_user_command(bufnr, 'Format', vim.lsp.buf.format or vim.lsp.buf.formatting, { desc = 'Format current buffer with LSP' })
    end

    local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

    local lspconfig = require("lspconfig")
    local servers = {
      lspconfig.sumneko_lua,
      lspconfig.tsserver,
      lspconfig.rnix
    }

    for _, lsp in ipairs(servers) do
      lsp.setup {
        capabilities = capabilities,
        on_attach = on_attach
      }
    end
  end}

  -- Completion
  use { 'hrsh7th/nvim-cmp', requires = { 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path', 'hrsh7th/cmp-cmdline' }, after = 'LuaSnip', config = function()
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'

    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert {
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
      },
      sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
      },
    }

    cmp.setup.cmdline('/', {
      sources = {
        { name = 'buffer' }
      }
    })

    cmp.setup.cmdline(':', {
      sources = {
        { name = 'path' },
        { name = 'cmdline' }
      }
    })
  end}

  -- Other
  use { 'nvim-lualine/lualine.nvim', config = function() require('lualine').setup() end }
  use { 'numToStr/Comment.nvim', config = function() require('Comment').setup() end }
  use 'tpope/vim-surround'
  use { 'lukas-reineke/indent-blankline.nvim', config = function() require('indent_blankline').setup() end }
  use { 'L3MON4D3/LuaSnip' }
  use { 'saadparwaiz1/cmp_luasnip', after = { 'nvim-cmp', 'LuaSnip' } }
  use { 'lewis6991/gitsigns.nvim', config = function() require('gitsigns').setup() end }
  use { 'kyazdani42/nvim-tree.lua', requires = { 'kyazdani42/nvim-web-devicons' }, config = function()
    require('nvim-tree').setup{
      respect_buf_cwd = true,
      update_cwd = true,
      update_focused_file = {
        enable = true,
        update_cwd = true
      }
    }
  end}
  use 'tpope/vim-sleuth'
  use { 'windwp/nvim-autopairs', config = function() require('nvim-autopairs').setup() end }

  -- Theme
  use { "catppuccin/nvim", as = "catppuccin", config = function()
    vim.g.catppuccin_flavour = 'mocha'
    require("catppuccin").setup()
    vim.cmd [[colorscheme catppuccin]]
  end}

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
