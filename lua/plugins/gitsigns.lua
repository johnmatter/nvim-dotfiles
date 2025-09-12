return {
  'lewis6991/gitsigns.nvim',
  opts = {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    -- Enable line highlighting
    linehl = false,       -- Enable background highlighting for lines
    numhl = true,        -- Enable highlighting for line numbers
    word_diff = false,   -- Enable word diff highlighting (optional)
    current_line_blame = false, -- Enable inline blame (optional)
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
      delay = 1000,
      ignore_whitespace = false,
    },
  },
  config = function(_, opts)
    -- Set up gitsigns with options
    require('gitsigns').setup(opts)

    -- Plugin-specific custom highlights
    local gitsigns_highlights = {
      -- Sign column backgrounds (these override the global ones from init.lua if you want different colors)
      GitSignsAddLn = {
        bg = "#18633e",  -- background for added lines
      },
      GitSignsChangeLn = {
        bg = "#2f619a",  -- background for changed lines
      },
      GitSignsDeleteLn = {
        bg = "#79141f",  -- background for deleted lines
      },
      -- Inline blame styling
      GitSignsCurrentLineBlame = {
        fg = "#888888",
        italic = true,
        blend = 20,
      },
      -- Number column highlights when showing diff in number column
      GitSignsAddNr = {
        fg = "#4CAF50",
      },
      GitSignsChangeNr = {
        fg = "#FFC107",
      },
      GitSignsDeleteNr = {
        fg = "#F44336",
      },
    }

    -- Function to apply gitsigns-specific highlights
    local function apply_gitsigns_highlights()
      for group, highlight_opts in pairs(gitsigns_highlights) do
        vim.api.nvim_set_hl(0, group, highlight_opts)
      end
    end

    -- Apply highlights immediately
    apply_gitsigns_highlights()

    -- Reapply when colorscheme changes
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = apply_gitsigns_highlights,
      desc = "Reapply gitsigns custom highlights after colorscheme change"
    })

    -- Gitsigns keybindings for hunk operations
    local gs = require('gitsigns')

    -- Hunk navigation
    vim.keymap.set('n', ']h', gs.next_hunk, { desc = 'Next git hunk' })
    vim.keymap.set('n', '[h', gs.prev_hunk, { desc = 'Previous git hunk' })

    -- Hunk preview (VS Code-like diff popup)
    vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview git hunk' })
    vim.keymap.set('n', '<leader>hP', gs.preview_hunk_inline, { desc = 'Preview hunk inline' })

    -- Hunk operations
    -- vim.keymap.set('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage git hunk' })
    -- vim.keymap.set('n', '<leader>hr', gs.reset_hunk, { desc = 'Reset git hunk' })
    -- vim.keymap.set('v', '<leader>hs', function() gs.stage_hunk({vim.fn.line('.'), vim.fn.line('v')}) end, { desc = 'Stage selected lines' })
    -- vim.keymap.set('v', '<leader>hr', function() gs.reset_hunk({vim.fn.line('.'), vim.fn.line('v')}) end, { desc = 'Reset selected lines' })

    -- -- Buffer operations
    -- vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { desc = 'Stage entire buffer' })
    -- vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { desc = 'Reset entire buffer' })
    -- vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'Undo stage hunk' })

    -- Diff view
    vim.keymap.set('n', '<leader>hd', gs.diffthis, { desc = 'Diff this buffer' })
    vim.keymap.set('n', '<leader>hD', function() gs.diffthis('~') end, { desc = 'Diff against last commit' })

    -- Blame
    vim.keymap.set('n', '<leader>hb', gs.toggle_current_line_blame, { desc = 'Toggle line blame' })
    vim.keymap.set('n', '<leader>hB', function() gs.blame_line({full=true}) end, { desc = 'Show full blame' })

    -- Text object for hunks
    vim.keymap.set({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select git hunk' })
  end,
}
