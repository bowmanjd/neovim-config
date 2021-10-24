local fn = vim.fn
local cmd = vim.cmd
local opt = vim.opt

opt.hidden = true
opt.mouse = 'a'

opt.fileformat = 'unix'
opt.fileformats= {'unix','dos'}

opt.backup = false
opt.writebackup = false

opt.smartindent = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2

opt.number = true
opt.cursorline = true
opt.clipboard = 'unnamed'
opt.hlsearch = false
opt.ignorecase = true
opt.smartcase = true

opt.background = 'dark'
opt.guifont = 'Hack Nerd Font:h18'

cmd 'au BufNewFile,BufRead *.md set spell spelllang=en_us ft=markdown formatoptions=l lbr wrap textwidth=0 wrapmargin=0 nolist'
cmd 'au BufNewFile,BufRead ssh_config,*/.ssh/config.d/*  setf sshconfig'

local install_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path})
end

require 'paq' {
  'savq/paq-nvim';                  -- Let Paq manage itself
  'neovim/nvim-lspconfig';
  'kosayoda/nvim-lightbulb';
  'hrsh7th/cmp-nvim-lsp';
  'hrsh7th/cmp-buffer';
  'hrsh7th/nvim-cmp';
  'nvim-lualine/lualine.nvim';
  'kyazdani42/nvim-web-devicons';
  'L3MON4D3/LuaSnip';
  'saadparwaiz1/cmp_luasnip';
  'habamax/vim-colors-defnoche';
  'dart-lang/dart-vim-plugin';
  'nvim-lua/plenary.nvim';
  'nvim-telescope/telescope.nvim';
  'lewis6991/gitsigns.nvim';
  'nvim-treesitter/nvim-treesitter';
  -- 'lukas-reineke/indent-blankline.nvim';
}

cmd 'colorscheme defnoche'

local ts_status, ts = pcall(require, 'nvim-treesitter.configs')
if(ts_status) then
  ts.setup {
    ensure_installed = {
      'bash',
      'c',
      'css',
      'dart',
      'go',
      'html',
      'java',
      'javascript',
      'jsdoc',
      'json',
      'kotlin',
      'lua',
      'python',
      'rust',
      'toml',
      'vim',
      'yaml'
    },
    highlight = {
      enable = true,              -- false will disable the whole extension
      -- disable = { "c", "rust" },
      additional_vim_regex_highlighting = false,
    },
  }
end

local ll_status, lualine = pcall(require, "lualine")
if(ll_status) then
  lualine.setup()
end

local gs_status, gitsigns = pcall(require, "lualine")
if(gs_status) then
  gitsigns.setup()
end

-- Setup autocompletion with nvim-cmp
local cmp_status, cmp = pcall(require, 'cmp')
if(cmp_status) then
  cmp.setup({
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      end,
    },
    mapping = {
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    }, {
      { name = 'buffer' },
    })
  })
end

-- Setup lspconfig.
local cmp_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local lspconfig_status, lspconfig = pcall(require, "lspconfig")
if(cmp_lsp_status and lspconfig_status) then
  local capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())

  local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
    local opts = { noremap=true, silent=true }
    buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  end
  lspconfig.bashls.setup {
    capabilities = capabilities,
    on_attach = on_attach
  }
  lspconfig.dartls.setup {
    capabilities = capabilities,
    on_attach = on_attach
  }
  lspconfig.pyright.setup {
    capabilities = capabilities,
    on_attach = on_attach
  }
  lspconfig.jsonls.setup {
    capabilities = capabilities,
    on_attach = on_attach
  }
  lspconfig.html.setup {
    capabilities = capabilities,
    on_attach = on_attach
  }
  lspconfig.eslint.setup {
    capabilities = capabilities,
    on_attach = on_attach
  }
  lspconfig.efm.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    init_options = {documentFormatting = true},
    settings = {
      rootMarkers = {'.git/'},
      languages = {
        sql = {
            {formatCommand = 'sqlformat -a -k upper -s - && echo', formatStdin = true}
        }
      }
    }
  }
end
