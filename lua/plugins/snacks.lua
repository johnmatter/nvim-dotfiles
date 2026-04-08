return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- speed
    bigfile = {},
    quickfile = {}, -- Quick file operations

    lazygit = {},
    explorer = {
      enabled = true,
    },
    picker = {
      sources = {
        explorer = {
          hidden = true, -- Show hidden files by default
          ignored = true, -- Show gitignored files
          layout = {
            layout = {
              width = 25,
              min_width = 10,
            }
          }
        }
      }
    },

    notifier = {
      background_colour = "#000000",
      timeout = 5000,
      width = { min = 40, max = 0.9 },
      height = { min = 1, max = 0.6 },
      margin = { top = 0, right = 1, bottom = 0 },
      padding = true, -- add 1 cell of left/right padding to the notification window
      keep = function(notif)
        return vim.fn.getcmdpos() > 0
      end,
      ---@type snacks.notifier.style
      style = "compact",
      top_down = true, -- place notifications from top to bottom
      date_format = "%R", -- time format for notifications
      -- format for footer when more lines are available
      -- `%d` is replaced with the number of lines.
      -- only works for styles with a border
      ---@type string|boolean
      more_format = " ↓ %d lines ",
    },
    terminal = {
      win = {position = "right"},
      cmd = {"/opt/homebrew/bin/fish"},
    },
    toggle = {},
    words = {},

  }, -- snacks opts

  keys = {

    -- lazygit
    { "<leader>lg", function() Snacks.lazygit() end, desc = "[L]azy[g]it" },
    { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazy[g]it [L]og" },
    { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazy[g]it Current [F]ile History" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "[G]it [S]tatus" },

    -- explorer
    { "<leader>e", function() Snacks.explorer() end, desc = "Toggle [E]xplorer" },

    -- terminal
    { "<leader>nt", function() Snacks.terminal() end, desc = "Toggle Terminal" },

    -- notifications
    { "<leader>nh", function() Snacks.notifier.show_history() end, desc = "Notification History" },

    -- words
    { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
    { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },

  }, -- snacks keybinds

  -- Custom commands
  vim.api.nvim_create_user_command('SnacksToggleNotifier', function()
    Snacks.config.notifier.enabled = not Snacks.config.notifier.enabled
    local status = Snacks.config.notifier.enabled and "enabled" or "disabled"
    vim.notify("Snacks notifier " .. status, vim.log.levels.INFO)
  end, { desc = "Toggle Snacks notifier on/off" }),

}
