return {
  "epwalsh/pomo.nvim",
  version = "*",  -- Recommended, use latest release instead of latest commit
  lazy = true,
  cmd = { "TimerStart", "TimerRepeat", "TimerSession" },
  dependencies = {
    -- Optional, but highly recommended if you want to use the "Default" timer
    "rcarriga/nvim-notify",
  },
  opts = {
    notifiers = {
      -- The "Default" notifier uses 'vim.notify' and works best when you have 'nvim-notify' installed.
      {
        name = "Default",
        opts = {
          sticky = false,
          title_icon = "󱎫",
          text_icon = "󰄉",
        },
      },
      -- { name = "System" },
    },

    sessions = {
      pomodoro = {
        { name = "Work", duration = "25m" },
        { name = "Short Break", duration = "5m" },
        { name = "Work", duration = "25m" },
        { name = "Short Break", duration = "5m" },
        { name = "Work", duration = "25m" },
        { name = "Long Break", duration = "15m" },
      },
    },
  },
}
