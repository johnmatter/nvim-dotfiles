-- some lines taken from https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua

vim.g.project_root = vim.fn.getcwd()


--   __       _     _     
--  / _| ___ | | __| |___ 
-- | |_ / _ \| |/ _` / __|
-- |  _| (_) | | (_| \__ \
-- |_|  \___/|_|\__,_|___/

vim.opt.foldmethod = 'indent'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 3
vim.opt.foldnestmax = 5

-- plugins
require('config.lazy')
require('lualine').setup()

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

-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     vim.cmd("vertical topleft 30vsplit | SnacksExplorer")
--   end
-- })

-- quick keymaps
vim.keymap.set('n', '<leader>q', ':q<cr>')
vim.keymap.set('n', '<leader>x', ':qa<cr>')
vim.keymap.set('n', '<leader>w', ':w<cr>')
vim.keymap.set('n', '<leader>t', ':tabnew<cr>')
vim.keymap.set('n', '<leader>kj', 'gT')
vim.keymap.set('n', '<leader>jk', 'gt')

-- colors
vim.opt.termguicolors = true

-- set cursorline, with an autocmd to apply whenever colorscheme changes
_G.custom_cursorline_color = "#18573e"
vim.api.nvim_set_hl(0, "CursorLine", {
  bg = _G.custom_cursorline_color,
})
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLine", {
      bg = _G.custom_cursorline_color,
    })
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

vim.api.nvim_set_hl(0, "Visual", {
  fg = "#cac0ae",
  bg = "#4c7842",
})

vim.o.mouse = 'a'
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.showbreak = "↪ "
-- vim.o.showmode = false
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

-- splits
vim.o.splitright = true
vim.o.splitbelow = true
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Split to the right
map('n', '<leader>ll', ':vsplit<CR>', opts)
map('n', '<leader>jj', ':split<CR>', opts)
map('n', '<leader>kk', ':split<CR><C-w>k', opts)
map('n', '<leader>hh', ':vsplit<CR><C-w>h', opts)

map('n', '<leader>wh', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<leader>wl', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<leader>wj', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<leader>wk', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

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

-- clear highlights in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

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

-- -- aider
-- local function update_aider_watch_list()
--   local files = {}
--   local seen = {}
--   for _, buf in ipairs(vim.api.nvim_list_bufs()) do
--     if vim.api.nvim_buf_is_loaded(buf) then
--       local name = vim.api.nvim_buf_get_name(buf)
--       if name ~= '' and vim.fn.filereadable(name) == 1 and
--          name:find(vim.g.project_root, 1, true) == 1 and not seen[name] then
--         table.insert(files, name)
--         seen[name] = true
--       end
--     end
--   end
--   local path = vim.fn.expand("~/.aider-watch-list")
--   vim.fn.writefile(files, path)
-- end
-- vim.api.nvim_create_augroup("AiderWatchSync", {clear=true})
-- vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost"}, {
--    pattern = "*",
--    callback = update_aider_watch_list,
--    group = "AiderWatchSync",
-- })

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

-- vim.keymap.set('n', '<leader>o', ':Oil<CR>')
vim.keymap.set("n", "<leader>o", function()
  vim.cmd("vsplit | wincmd l")
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


-- --                     _
-- --  _ __ ___ _ __   __| | ___ _ __
-- -- | '__/ _ \ '_ \ / _` |/ _ \ '__|
-- -- | | |  __/ | | | (_| |  __/ |
-- -- |_|  \___|_| |_|\__,_|\___|_|
-- --
--                       _       _
--  _ __ ___   __ _ _ __| | ____| | _____      ___ __
-- | '_ ` _ \ / _` | '__| |/ / _` |/ _ \ \ /\ / / '_ \
-- | | | | | | (_| | |  |   < (_| | (_) \ V  V /| | | |
-- |_| |_| |_|\__,_|_|  |_|\_\__,_|\___/ \_/\_/ |_| |_|
require("render-markdown").setup()
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
