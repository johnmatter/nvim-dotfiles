-- some lines taken from https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua

vim.g.project_root = vim.fn.getcwd()


--   __       _     _
--  / _| ___ | | __| |___
-- | |_ / _ \| |/ _` / __|
-- |  _| (_) | | (_| \__ \
-- |_|  \___/|_|\__,_|___/

vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 3
vim.opt.foldnestmax = 5

-- plugins
require('config.lazy')

--            _
--   ___ ___ | | ___  _ __ ___
--  / __/ _ \| |/ _ \| '__/ __|
-- | (_| (_) | | (_) | |  \__ \
--  \___\___/|_|\___/|_|  |___/

vim.opt.termguicolors = true

-- set cursorline and visual selection colors, with an autocmd to apply whenever colorscheme changes
_G.custom_cursorline_color = "#18573e"
_G.custom_cursorline_fg = "#cac0ae"
_G.custom_visual_fg = "#cac0ae"
_G.custom_visual_bg = "#4c7842"

vim.api.nvim_set_hl(0, "CursorLine", {
  fg = _G.custom_cursorline_fg,
  bg = _G.custom_cursorline_color,
})
vim.api.nvim_set_hl(0, "Visual", {
  fg = _G.custom_visual_fg,
  bg = _G.custom_visual_bg,
})

-- Disable LSP semantic token highlighting for comment type in C++
-- This prevents #ifdef blocks from being dimmed while keeping other semantic tokens
vim.api.nvim_set_hl(0, "@lsp.type.comment.cpp", {})

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLine", {
      fg = _G.custom_cursorline_fg,
      bg = _G.custom_cursorline_color,
    })
    vim.api.nvim_set_hl(0, "Visual", {
      fg = _G.custom_visual_fg,
      bg = _G.custom_visual_bg,
    })
    -- Reapply LSP comment token override after colorscheme change
    vim.api.nvim_set_hl(0, "@lsp.type.comment.cpp", {})
  end,
})

-- Load Base16 theme synchronization module
local theme_sync = require('base16-theme-sync')
theme_sync.initialize_theme()

-- Theme management keymap is handled by telescope.lua

-- Create a command to manually set Base16 theme
vim.api.nvim_create_user_command('SetTheme', function(opts)
  theme_sync.set_theme(opts.args)
end, {
  nargs = 1,
  complete = function()
    return theme_sync.get_available_themes()
  end,
  desc = 'Set Base16 theme for Kitty, Neovim, and Fish'
})

--            _                        _
--  _ __ ___ (_)___  ___    ___  _ __ | |_ ___
-- | '_ ` _ \| / __|/ __|  / _ \| '_ \| __/ __|
-- | | | | | | \__ \ (__  | (_) | |_) | |_\__ \
-- |_| |_| |_|_|___/\___|  \___/| .__/ \__|___/
--                              |_|

vim.o.mouse = 'a'
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.showbreak = "↪ "
vim.o.showmode = false -- Hide mode indicator since lualine already shows it
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "number"

-- spacebar is leader
vim.g.mapleader = " "

-- tabs
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2

-- keep undo history
vim.o.undofile = true

-- case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Note: `map` was previously used for scnvim.map (lines 20-21) but that's no longer in scope
-- Redefining here as vim.keymap.set for convenience in split/window keymaps
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- display whitespace
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- preview substitutions as you type
vim.o.inccommand = 'split'

-- cursor options
vim.o.cursorline = true
vim.o.scrolloff = 10

-- if e.g. :q would fail because of unsaved changes, prompt to save
vim.o.confirm = true

--            _ _ _
--  ___ _ __ | (_) |_ ___
-- / __| '_ \| | | __/ __|
-- \__ \ |_) | | | |_\__ \
-- |___/ .__/|_|_|\__|___/
--     |_|

-- splits
vim.o.splitright = true
vim.o.splitbelow = true

map('n', '<leader>ll', ':vsplit<CR>', opts)
map('n', '<leader>jj', ':split<CR>', opts)
map('n', '<leader>kk', ':split<CR><C-w>k', opts)
map('n', '<leader>hh', ':vsplit<CR><C-w>h', opts)

map('n', '<leader>wh', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<leader>wl', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<leader>wj', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<leader>wk', '<C-w><C-k>', { desc = 'Move focus to the upper window' })


--       _ _       _                         _
--   ___| (_)_ __ | |__   ___   __ _ _ __ __| |
--  / __| | | '_ \| '_ \ / _ \ / _` | '__/ _` |
-- | (__| | | |_) | |_) | (_) | (_| | | | (_| |
--  \___|_|_| .__/|_.__/ \___/ \__,_|_|  \__,_|
--          |_|

-- clipboard sync state
_G.clipboard_sync_enabled = false

-- Function to toggle clipboard sync
local function toggle_clipboard_sync()
  _G.clipboard_sync_enabled = not _G.clipboard_sync_enabled
  if _G.clipboard_sync_enabled then
    vim.o.clipboard = 'unnamedplus'
    vim.notify('OS clipboard sync enabled', vim.log.levels.INFO)
  else
    vim.o.clipboard = ''
    vim.notify('OS clipboard sync disabled', vim.log.levels.INFO)
  end
end

-- Keybind to toggle clipboard sync
vim.keymap.set(
  'n',
  '<leader>yp',
  toggle_clipboard_sync,
  { desc = 'Toggle OS clipboard sync' }
)

-- highlight yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- oil
function _G.get_oil_winbar()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require("oil").get_current_dir(bufnr)
  if dir then
    return vim.fn.fnamemodify(dir, ":~")
  else
    -- If there is no current directory (e.g. over ssh), just show the buffer name
    return vim.api.nvim_buf_get_name(0)
  end
end
local detail = false

-- if a file has four spaces per indent level, this will convert it to two per indent level
vim.api.nvim_create_user_command("Retab4to2", function()
  vim.opt.expandtab = false
  vim.opt.tabstop = 4
  vim.cmd("retab!")
  vim.opt.expandtab = true
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.softtabstop = 2
  vim.cmd("retab")
end, {})

-- Toggle clean UI mode: git blame virtual text and diagnostics virtual text
local ui_clean_mode = false
local saved_diagnostic_virt_text = nil

vim.keymap.set('n', '<leader>u', function()
  ui_clean_mode = not ui_clean_mode

  -- Toggle git-blame.nvim
  vim.cmd('GitBlameToggle')

  -- Toggle diagnostics virtual text
  local current_config = vim.diagnostic.config()

  if ui_clean_mode then
    -- Turning clean mode ON: save current config and disable
    if current_config.virtual_text then
      saved_diagnostic_virt_text = current_config.virtual_text
    end
    vim.diagnostic.config({ virtual_text = false })
  else
    -- Turning clean mode OFF: restore saved config
    if saved_diagnostic_virt_text then
      vim.diagnostic.config({ virtual_text = saved_diagnostic_virt_text })
    end
  end

  -- Show notification
  local status = ui_clean_mode and "mute diagnostics and git blame" or "unmute diagnostics and git blame"
  vim.notify(status, vim.log.levels.INFO)
end, { desc = 'Toggle clean UI mode (hide git blame & diagnostics)' })

-- telescope helpers
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local builtin = require('telescope.builtin')

-- Custom action: Insert selected file path at cursor
local function insert_file_path_at_cursor(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  actions.close(prompt_bufnr)

  local path = entry.path or entry.filename
  if path then
    -- Escape backslashes and quotes for safety (optional)
    path = path:gsub("\\", "\\\\"):gsub('"', '\\"')

    -- Insert at cursor position
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local before = line:sub(1, col)
    local after = line:sub(col + 1)
    vim.api.nvim_set_current_line(before .. path .. after)
  end
end

-- Wrapper to call Telescope with the custom action
local function browse_and_insert_path()
  require('telescope.builtin').find_files({
    attach_mappings = function(_, map)
      map("i", "<CR>", insert_file_path_at_cursor)
      map("n", "<CR>", insert_file_path_at_cursor)
      return true
    end
  })
end

vim.keymap.set("n", "<Leader>fp", browse_and_insert_path, { desc = "Insert file path at cursor" })
vim.keymap.set("i", "<C-g>", browse_and_insert_path, { desc = "Insert file path at cursor" }) -- Changed from <C-f> to avoid neoscroll/blink conflicts

vim.keymap.set("n", "<leader>o", function()
  vim.cmd("vsplit | wincmd h")
  require("oil").open()
end)

require('notify').setup ({
    background_colour = "#000000"
})

require("lualine").setup {
  sections = {
    lualine_x = {
      function()
        local ok, pomo = pcall(require, "pomo")
        if not ok then
          return ""
        end

        local timer = pomo.get_first_to_finish()
        if timer == nil then
          return ""
        end

        return "󰄉 " .. tostring(timer)
      end,
      "encoding",
      "fileformat",
      "filetype",
    },
  },
}

--                     _
--  _ __ ___ _ __   __| | ___ _ __
-- | '__/ _ \ '_ \ / _` |/ _ \ '__|
-- | | |  __/ | | | (_| |  __/ |
-- |_|  \___|_| |_|\__,_|\___|_|
--                       _       _
--  _ __ ___   __ _ _ __| | ____| | _____      ___ __
-- | '_ ` _ \ / _` | '__| |/ / _` |/ _ \ \ /\ / / '_ \
-- | | | | | | (_| | |  |   < (_| | (_) \ V  V /| | | |
-- |_| |_| |_|\__,_|_|  |_|\_\__,_|\___/ \_/\_/ |_| |_|
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "NONE" })
  end,
})

--                                      _ _
--  _ __   ___  ___  ___  ___ _ __ ___ | | |
-- | '_ \ / _ \/ _ \/ __|/ __| '__/ _ \| | |
-- | | | |  __/ (_) \__ \ (__| | | (_) | | |
-- |_| |_|\___|\___/|___/\___|_|  \___/|_|_|

neoscroll = require('neoscroll')
local keymap = {
  ["<C-b>"] = function() neoscroll.ctrl_b({ duration = 450 }) end;
  ["<C-f>"] = function() neoscroll.ctrl_f({ duration = 450 }) end;
}
local modes = { 'n', 'v', 'x' }
for key, func in pairs(keymap) do
  vim.keymap.set(modes, key, func)
end

local vb = require("visualblock-reselect")
vim.keymap.set("x", "<leader>vv", vb.save, { desc = "Save block selection" })
vim.keymap.set("n", "<leader>vb", vb.restore, { desc = "Restore block selection" })

--  _
-- | | _____ _   _ _ __ ___   __ _ _ __  ___
-- | |/ / _ \ | | | '_ ` _ \ / _` | '_ \/ __|
-- |   <  __/ |_| | | | | | | (_| | |_) \__ \
-- |_|\_\___|\__, |_| |_| |_|\__,_| .__/|___/
--           |___/                |_|

vim.keymap.set('n', '<leader>q', ':q<cr>')
vim.keymap.set('n', '<leader>x', ':qa<cr>')
vim.keymap.set('n', '<leader>w', ':w<cr>')
vim.keymap.set('n', '<leader>t', ':tabnew<cr>')
vim.keymap.set('n', '<leader>kj', 'gT')
vim.keymap.set('n', '<leader>jk', 'gt')
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>.', ':s/^/#/<CR><cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>,', ':s/^#//<CR><cmd>nohlsearch<CR>')
