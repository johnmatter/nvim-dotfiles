return {
  "saghen/blink.cmp",
  lazy = false,
  dependencies = {
    "rafamadriz/friendly-snippets",
    {
      "L3MON4D3/LuaSnip",
      dependencies = { "rafamadriz/friendly-snippets" },
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
  },
  version = "v0.*",
  opts = {
    keymap = {
      ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = { 'hide', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },

      ['<Tab>'] = { 'snippet_forward', 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },

      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-n>'] = { 'select_next', 'fallback' },

      ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },   -- Changed from <C-b> to avoid neoscroll conflict
      ['<C-d>'] = { 'scroll_documentation_down', 'fallback' }, -- Changed from <C-f> to avoid neoscroll conflict
    },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono"
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      menu = {
        border = "rounded",
      },
    },
    snippets = {
      expand = function(snippet, _)
        require('luasnip').lsp_expand(snippet)
      end,
      active = function(filter)
        local luasnip = require('luasnip')
        if filter and filter.direction then
          return luasnip.in_snippet() and luasnip.jumpable(filter.direction)
        end
        return luasnip.in_snippet()
      end,
      jump = function(direction)
        require('luasnip').jump(direction)
      end,
    },
  },
  opts_extend = { "sources.default" }
} 