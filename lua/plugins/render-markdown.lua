return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    code = {
      conceal_delimiters = false,
      langauge_icon = false,
    },
    checkbox = {
      checked = {
        highlight = 'DiffAdd',
        -- scope_highlight = '@markup.strikethrough' -- doesn't seem to work
      },
      unchecked = {
        highlight = 'DiffDelete',
        -- scope_highlight = '@markup.strikethrough' -- doesn't seem to work
      }
    }
  },
}
