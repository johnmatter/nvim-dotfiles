return {
  'folke/todo-comments.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    keywords = {
      MARK = { icon = '󰃀 ', color = 'hint', alt = { 'SECTION' } },
      TODO = { icon = ' ', color = 'info' },
      FIX  = { icon = ' ', color = 'error', alt = { 'FIXME', 'BUG', 'ISSUE' } },
      HACK = { icon = ' ', color = 'warning' },
      WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
      PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
      NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
      TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
    },
    -- Match both `// MARK:` (modern XCode) and `#pragma mark` (legacy) in addition to the default `KEYWORD:` style.
    highlight = {
      pattern = {
        [[.*<(KEYWORDS)\s*:]],
        [[.*#\s*pragma\s+(mark)\s+-?\s*]],
      },
    },
    search = {
      pattern = [[\b(KEYWORDS):|#\s*pragma\s+mark\s+]],
    },
  },
  keys = {
    { ']t', function() require('todo-comments').jump_next() end, desc = 'Next todo comment' },
    { '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous todo comment' },
    { '<leader>ft', '<cmd>TodoTelescope<cr>',                          desc = 'Find todo/MARK comments' },
    { '<leader>fT', '<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>',  desc = 'Find TODO/FIX only' },
    { '<leader>fm', '<cmd>TodoTelescope keywords=MARK,SECTION<cr>',    desc = 'Find MARK sections' },
  },
}
