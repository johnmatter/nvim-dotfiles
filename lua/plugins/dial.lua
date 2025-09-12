return {
  "monaqa/dial.nvim",
  event = "VeryLazy",
  config = function()

    local function feed_and_save(keys)
      local feedkeys = vim.api.nvim_feedkeys
      local replace_termcodes = vim.api.nvim_replace_termcodes
      feedkeys(replace_termcodes(keys, true, false, true), "n", false)
      vim.defer_fn(function()
        vim.cmd("write")
      end, 20)
    end

    vim.keymap.set("n", "<F12>", function()
      feed_and_save("<Plug>(dial-increment)")
    end, { noremap = true })

    vim.keymap.set("n", "<F11>", function()
      feed_and_save("<Plug>(dial-decrement)")
    end, { noremap = true })

  end,
} 