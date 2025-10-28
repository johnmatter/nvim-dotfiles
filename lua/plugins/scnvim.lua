return {
  'davidgranstrom/scnvim',
  ft = 'supercollider',
  config = function()
    local scnvim = require 'scnvim'
    local map = scnvim.map
    local map_expr = scnvim.map_expr

    scnvim.setup({
      keymaps = {
        ['<M-e>'] = map('editor.send_line', {'i', 'n'}),
        ['<leader>se'] = {  -- Changed from <C-e> to avoid blink.cmp conflict
          map('editor.send_block', {'i', 'n'}),
          map('editor.send_selection', 'x'),
        },
        ['<CR>'] = map('postwin.toggle'),
        ['<M-CR>'] = map('postwin.toggle', 'i'),
        ['<M-L>'] = map('postwin.clear', {'n', 'i'}),
        ['<C-k>'] = map('signature.show', {'n', 'i'}),
        ['<leader>sq'] = map('sclang.hard_stop', {'n', 'x', 'i'}), -- Changed from <F12> to avoid dial conflict
        ['<leader>st'] = map('sclang.start'),
        ['<leader>sk'] = map('sclang.recompile'),
        -- ['<F1>'] = map_expr('s.boot'),
        ['<F6>'] = map_expr('s.meter'),

      },
      editor = {
        highlight = {
          color = 'IncSearch',
        },
      },
      postwin = {
        float = {
          enabled = true,
        },
      },
      -- Enable completion features
      completion = {
        enabled = true,
      },
      -- Ensure signature help shows argument info
      signature = {
        hint = {
          enabled = true,
        },
      },
    })
  end,
  dependencies = {
    'L3MON4D3/LuaSnip', -- For snippet support
  }
}
