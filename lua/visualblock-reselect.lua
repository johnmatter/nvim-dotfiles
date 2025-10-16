-- ~/.config/nvim/lua/visualblock-reselect.lua
local M = {}

local last_block = nil

function M.save()
  local mode = vim.fn.mode()
  
  if mode ~= "\22" then  -- CTRL-V visual block mode
    print("Not in visual block mode! Mode is: " .. vim.inspect(mode))
    return
  end

  -- Get current cursor position and visual selection start
  local cursor_pos = vim.fn.getpos(".")
  local visual_start = vim.fn.getpos("v")
  
  print("Cursor pos: " .. vim.inspect(cursor_pos))
  print("Visual start: " .. vim.inspect(visual_start))

  local top = math.min(cursor_pos[2], visual_start[2])
  local bottom = math.max(cursor_pos[2], visual_start[2])
  local left = math.min(cursor_pos[3], visual_start[3])
  local right = math.max(cursor_pos[3], visual_start[3])

  print("Calculated - top: " .. top .. ", bottom: " .. bottom .. ", left: " .. left .. ", right: " .. right)

  last_block = {
    height = bottom - top + 1,
    width = right - left + 1
  }

  print("Saved block: " .. last_block.height .. "x" .. last_block.width)
end

function M.restore()
  if not last_block then
    print("No block saved")
    return
  end

  -- Build the complete key sequence
  local key_sequence = "<Esc><C-v>"
  
  -- Add down movements
  if last_block.height > 1 then
    local down_moves = last_block.height - 1
    for i = 1, down_moves do
      key_sequence = key_sequence .. "j"
    end
  end

  -- Add right movements
  if last_block.width > 1 then
    local right_moves = last_block.width - 1
    for i = 1, right_moves do
      key_sequence = key_sequence .. "l"
    end
  end

  print("Key sequence: " .. key_sequence)
  
  -- Convert and send the keys
  local keys = vim.api.nvim_replace_termcodes(key_sequence, true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)

  print("Restored block: " .. last_block.height .. "x" .. last_block.width)
end

return M
