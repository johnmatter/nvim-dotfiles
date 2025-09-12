return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',

      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- Telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- The easiest way to use Telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of `help_tags` options and
    -- a corresponding preview of the help.
    --
    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- Telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      -- defaults = {
      --   mappings = {
      --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
      --   },
      -- },
      -- pickers = {telescope.setup{
      pickers = { colorscheme = { enable_preview = true } },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- Set Telescope colors to match global colorscheme
    local function set_telescope_colors()
      local highlights = {
        TelescopeNormal = { link = "Normal" },
        TelescopeBorder = { link = "Normal" },
        TelescopePromptBorder = { link = "Normal" },
        TelescopeResultsBorder = { link = "Normal" },
        TelescopePreviewBorder = { link = "Normal" },
        TelescopeMatching = { link = "Search" },
        TelescopePromptPrefix = { link = "Identifier" },
        TelescopeSelection = { link = "CursorLine" },
        TelescopeSelectionCaret = { link = "Identifier" },
      }
      
      for group, opts in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, opts)
      end
    end

    -- Apply colors immediately and when colorscheme changes
    set_telescope_colors()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_telescope_colors,
    })

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })

    -- Custom Base16 theme picker that syncs all applications
    local function theme_picker()
      local theme_sync = require('base16-theme-sync')
      local available_themes = theme_sync.get_available_themes()
      
      if #available_themes == 0 then
        vim.notify("No Base16 themes found. Make sure base16-kitty is installed.", vim.log.levels.ERROR)
        return
      end
      
      local theme_config = require('telescope.themes').get_dropdown({
        winblend = 10,
        previewer = false,
      })
      
      local pickers = require('telescope.pickers')
      local finders = require('telescope.finders')
      local conf = require('telescope.config').values
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')
      
      pickers.new(theme_config, {
        prompt_title = "Change Base16 Theme (All Apps)",
        finder = finders.new_table {
          results = available_themes,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry,
              ordinal = entry,
            }
          end,
        },
        sorter = conf.generic_sorter(theme_config),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            if selection then
              theme_sync.set_theme(selection.value)
              actions.close(prompt_bufnr)
            end
          end)
          
          -- Preview themes as you navigate
          local function preview_theme()
            local selection = action_state.get_selected_entry()
            if selection then
              theme_sync.set_theme(selection.value)
            end
          end
          
          map('i', '<C-p>', function()
            actions.move_selection_previous(prompt_bufnr)
            preview_theme()
          end)
          
          map('i', '<C-n>', function()
            actions.move_selection_next(prompt_bufnr)
            preview_theme()
          end)
          
          map('i', '<Up>', function()
            actions.move_selection_previous(prompt_bufnr)
            preview_theme()
          end)
          
          map('i', '<Down>', function()
            actions.move_selection_next(prompt_bufnr)
            preview_theme()
          end)
          
          return true
        end,
      }):find()
    end
    
    -- Register the Base16 theme picker
    vim.keymap.set('n', '<leader>th', theme_picker, { desc = 'Change [th]eme (Base16 - All Apps)' })
  end,
} 