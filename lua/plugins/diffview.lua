return {
  'sindrets/diffview.nvim',
  event = 'VeryLazy',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  opts = {
    -- Default options for diffview
    diff_binaries = false, -- Show diffs for binaries
    enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
    git_cmd = { "git" }, -- The git executable to use
    use_icons = true, -- Requires nvim-web-devicons
    show_help_hints = true, -- Show hints in the diff view
    watch_index = true, -- Update views and index buffers when the git index changes
    icons = { -- Only applies when use_icons = true
      folder_closed = "-",
      folder_open = "o",
    },
    signs = {
      fold_closed = "▶",
      fold_open = "▼",
      done = "✓",
    },
    view = {
      -- Configure the layout and behavior of different types of views.
      -- Available layouts:
      --  'diff1_plain'
      --    |'diff2_horizontal'
      --    |'diff2_vertical'
      --    |'diff3_horizontal'
      --    |'diff3_vertical'
      --    |'diff3_mixed'
      --    |'diff4_mixed'
      -- For more info, see ':h diffview-config-view.x.layout'.
      default = {
        -- Config for changed files, and staged files in diff views.
        layout = "diff2_horizontal",
        winbar_info = false, -- See ':h diffview-config-view.x.winbar_info'
      },
      merge_tool = {
        -- Config for conflicted files in diff views during a merge or rebase.
        layout = "diff3_horizontal",
        disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers while in the view.
        winbar_info = true, -- See ':h diffview-config-view.x.winbar_info'
      },
      file_history = {
        -- Config for changed files in file history views.
        layout = "diff2_horizontal",
        winbar_info = false, -- See ':h diffview-config-view.x.winbar_info'
      },
    },
    file_panel = {
      listing_style = "tree", -- One of 'list' or 'tree'
      tree_options = { -- Only applies when listing_style is 'tree'
        flatten_dirs = true, -- Flatten empty dirs that only contain one single dir
        folder_statuses = "only_folded", -- One of 'never', 'only_folded' or 'always'
      },
      win_config = { -- See ':h diffview-config-win_config'
        position = "left",
        width = 35,
        win_opts = {}
      },
    },
    file_history_panel = {
      log_options = { -- See ':h diffview-config-log_options'
        git = {
          single_file = {
            diff_merges = "combined",
          },
          multi_file = {
            diff_merges = "first-parent",
          },
        },
      },
      win_config = { -- See ':h diffview-config-win_config'
        position = "bottom",
        height = 16,
        win_opts = {}
      },
    },
    default_args = { -- Default args prepended to the arg-list for the listed commands
      DiffviewOpen = {},
      DiffviewFileHistory = {},
    },
    hooks = {}, -- See ':h diffview-config-hooks'
    keymaps = {
      disable_defaults = false, -- Disable the default keymaps
      view = {
        -- The `view` bindings are active in the diff buffers, of the diff view.
        ["<tab>"] = function() require("diffview.actions").select_next_entry() end,
        ["<s-tab>"] = function() require("diffview.actions").select_prev_entry() end,
        ["gf"] = function() require("diffview.actions").goto_file() end,
        ["<C-w><C-f>"] = function() require("diffview.actions").goto_file_split() end,
        ["<C-w>gf"] = function() require("diffview.actions").goto_file_tab() end,
        ["<leader>e"] = function() require("diffview.actions").focus_files() end,
        ["<leader>b"] = function() require("diffview.actions").toggle_files() end,
        ["g<C-x>"] = function() require("diffview.actions").cycle_layout() end,
        ["[x"] = function() require("diffview.actions").prev_conflict() end,
        ["]x"] = function() require("diffview.actions").next_conflict() end,
        ["<leader>co"] = function() require("diffview.actions").conflict_choose("ours") end,
        ["<leader>ct"] = function() require("diffview.actions").conflict_choose("theirs") end,
        ["<leader>cb"] = function() require("diffview.actions").conflict_choose("base") end,
        ["<leader>ca"] = function() require("diffview.actions").conflict_choose("all") end,
        ["dx"] = function() require("diffview.actions").conflict_choose("ours") end,
        ["do"] = function() require("diffview.actions").conflict_choose("ours") end,
        ["dp"] = function() require("diffview.actions").conflict_choose("theirs") end,
      },
      diff1 = {
        -- Mappings in single-file diff view
        ["gx"] = function() require("diffview.actions").goto_file() end,
        ["<C-w><C-f>"] = function() require("diffview.actions").goto_file_split() end,
        ["<C-w>gf"] = function() require("diffview.actions").goto_file_tab() end,
      },
      diff2 = {
        -- Mappings in 2-way diff view
        ["gx"] = function() require("diffview.actions").goto_file() end,
        ["<C-w><C-f>"] = function() require("diffview.actions").goto_file_split() end,
        ["<C-w>gf"] = function() require("diffview.actions").goto_file_tab() end,
      },
      diff3 = {
        -- Mappings in 3-way diff view
        [{"<tab>", "x", "2"}] = function() require("diffview.actions").select_entry() end,
        [{"<s-tab>", "x", "1"}] = function() require("diffview.actions").select_base() end,
        [{"<tab>", "x", "3"}] = function() require("diffview.actions").select_ours() end,
        [{"<tab>", "x", "4"}] = function() require("diffview.actions").select_theirs() end,
        ["gx"] = function() require("diffview.actions").goto_file() end,
        ["<C-w><C-f>"] = function() require("diffview.actions").goto_file_split() end,
        ["<C-w>gf"] = function() require("diffview.actions").goto_file_tab() end,
      },
      diff4 = {
        -- Mappings in 4-way diff view
        [{"<tab>", "x", "1"}] = function() require("diffview.actions").select_base() end,
        [{"<tab>", "x", "2"}] = function() require("diffview.actions").select_ours() end,
        [{"<tab>", "x", "3"}] = function() require("diffview.actions").select_theirs() end,
        [{"<tab>", "x", "4"}] = function() require("diffview.actions").select_all() end,
        ["gx"] = function() require("diffview.actions").goto_file() end,
        ["<C-w><C-f>"] = function() require("diffview.actions").goto_file_split() end,
        ["<C-w>gf"] = function() require("diffview.actions").goto_file_tab() end,
      },
      file_panel = {
        ["j"] = function() require("diffview.actions").next_entry() end,
        ["<down>"] = function() require("diffview.actions").next_entry() end,
        ["k"] = function() require("diffview.actions").prev_entry() end,
        ["<up>"] = function() require("diffview.actions").prev_entry() end,
        ["<cr>"] = function() require("diffview.actions").select_entry() end,
        ["o"] = function() require("diffview.actions").select_entry() end,
        ["<2-LeftMouse>"] = function() require("diffview.actions").select_entry() end,
        ["-"] = function() require("diffview.actions").toggle_stage_entry() end,
        ["S"] = function() require("diffview.actions").stage_all() end,
        ["U"] = function() require("diffview.actions").unstage_all() end,
        ["X"] = function() require("diffview.actions").restore_entry() end,
        ["L"] = function() require("diffview.actions").open_commit_log() end,
        ["<c-b>"] = function() require("diffview.actions").scroll_view(-0.25) end,
        ["<c-f>"] = function() require("diffview.actions").scroll_view(0.25) end,
        ["<tab>"] = function() require("diffview.actions").select_next_entry() end,
        ["<s-tab>"] = function() require("diffview.actions").select_prev_entry() end,
        ["gf"] = function() require("diffview.actions").goto_file() end,
        ["<C-w><C-f>"] = function() require("diffview.actions").goto_file_split() end,
        ["<C-w>gf"] = function() require("diffview.actions").goto_file_tab() end,
        ["i"] = function() require("diffview.actions").listing_style() end,
        ["f"] = function() require("diffview.actions").toggle_flatten_dirs() end,
        ["R"] = function() require("diffview.actions").refresh() end,
        ["<leader>e"] = function() require("diffview.actions").focus_files() end,
        ["<leader>b"] = function() require("diffview.actions").toggle_files() end,
        ["g<C-x>"] = function() require("diffview.actions").cycle_layout() end,
        ["[x"] = function() require("diffview.actions").prev_conflict() end,
        ["]x"] = function() require("diffview.actions").next_conflict() end,
      },
      file_history_panel = {
        ["g!"] = function() require("diffview.actions").options() end,
        ["<C-A-d>"] = function() require("diffview.actions").open_in_diffview() end,
        ["y"] = function() require("diffview.actions").copy_hash() end,
        ["L"] = function() require("diffview.actions").open_commit_log() end,
        ["zR"] = function() require("diffview.actions").open_all_folds() end,
        ["zM"] = function() require("diffview.actions").close_all_folds() end,
        ["j"] = function() require("diffview.actions").next_entry() end,
        ["<down>"] = function() require("diffview.actions").next_entry() end,
        ["k"] = function() require("diffview.actions").prev_entry() end,
        ["<up>"] = function() require("diffview.actions").prev_entry() end,
        ["<cr>"] = function() require("diffview.actions").select_entry() end,
        ["o"] = function() require("diffview.actions").select_entry() end,
        ["<2-LeftMouse>"] = function() require("diffview.actions").select_entry() end,
        ["<c-b>"] = function() require("diffview.actions").scroll_view(-0.25) end,
        ["<c-f>"] = function() require("diffview.actions").scroll_view(0.25) end,
        ["<tab>"] = function() require("diffview.actions").select_next_entry() end,
        ["<s-tab>"] = function() require("diffview.actions").select_prev_entry() end,
        ["gf"] = function() require("diffview.actions").goto_file() end,
        ["<C-w><C-f>"] = function() require("diffview.actions").goto_file_split() end,
        ["<C-w>gf"] = function() require("diffview.actions").goto_file_tab() end,
        ["<leader>e"] = function() require("diffview.actions").focus_files() end,
        ["<leader>b"] = function() require("diffview.actions").toggle_files() end,
        ["g<C-x>"] = function() require("diffview.actions").cycle_layout() end,
      },
      option_panel = {
        ["<tab>"] = function() require("diffview.actions").select_entry() end,
        ["q"] = function() require("diffview.actions").close() end,
        ["<cr>"] = function() require("diffview.actions").select_entry() end,
      },
    },
  },
  config = function(_, opts)
    require('diffview').setup(opts)

    -- Custom keymaps for diffview
    -- Open diffview
    vim.keymap.set('n', '<leader>gd', ':DiffviewOpen<CR>', { desc = 'Open [G]it [D]iffview' })
    vim.keymap.set('n', '<leader>gD', ':DiffviewOpen HEAD~1<CR>', { desc = 'Open [G]it [D]iffview (HEAD~1)' })
    
    -- File history
    vim.keymap.set('n', '<leader>gfh', ':DiffviewFileHistory<CR>', { desc = 'Open [G]it [F]ile [H]istory' })
    vim.keymap.set('n', '<leader>gfH', ':DiffviewFileHistory %<CR>', { desc = 'Open [G]it [F]ile [H]istory (current file)' })
    
    -- Toggle diffview
    vim.keymap.set('n', '<leader>gt', ':DiffviewToggleFiles<CR>', { desc = '[G]it [T]oggle files panel' })
    
    -- Focus files (changed from <leader>gf to avoid conflict with snacks lazygit file history)
    vim.keymap.set('n', '<leader>gF', ':DiffviewFocusFiles<CR>', { desc = '[G]it [F]ocus files panel' })
    
    -- Refresh
    vim.keymap.set('n', '<leader>gr', ':DiffviewRefresh<CR>', { desc = '[G]it [R]efresh diffview' })
    
    -- Close diffview
    vim.keymap.set('n', '<leader>gq', ':DiffviewClose<CR>', { desc = '[G]it [Q]uit diffview' })
  end,
}
