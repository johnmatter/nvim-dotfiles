return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  event = 'VeryLazy', -- Load after colorscheme
  config = function()
    require('bufferline').setup({
      options = {
        mode = 'tabs',
        diagnostics = "nvim_lsp",
        separator_style = "none",
        show_buffer_close_icons = true,
        show_close_icon = true,
        color_icons = true,
        get_element_icon = function(element)
          local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(element.filetype, { default = false })
          return icon, hl
        end,
      },
    })

    -- Programmatically force all bufferline colors to use colorscheme colors
    local function set_bufferline_colors()
      -- Get all highlight groups that start with "BufferLine"
      local all_highlights = vim.fn.getcompletion('BufferLine', 'highlight')

      -- Define mapping rules based on highlight group patterns
      local highlight_mapping = {
        -- Selected/active elements
        { pattern = "Selected", link = "FloatTitle" },
        { pattern = "Pick", link = "Function" },
        { pattern = "Indicator", link = "Function" },

        -- Diagnostic states
        { pattern = "Error", link = "ErrorMsg" },
        { pattern = "Warning", link = "WarningMsg" },
        { pattern = "Info", link = "Directory" },
        { pattern = "Hint", link = "Comment" },
        { pattern = "Modified", link = "WarningMsg" },

        -- Default fallback (should be last)
        { pattern = ".*", link = "Normal" },
      }

      -- Apply mapping to each BufferLine highlight group
      for _, hl_name in ipairs(all_highlights) do
        for _, mapping in ipairs(highlight_mapping) do
          if hl_name:match(mapping.pattern) then
            vim.api.nvim_set_hl(0, hl_name, { link = mapping.link })
            break -- Stop at first match
          end
        end
      end

      -- Optional: Print discovered groups for debugging
      -- print("Found BufferLine highlights:", vim.inspect(all_highlights))
    end

    -- Apply colors immediately
    set_bufferline_colors()

    -- Ensure it works when switching colorschemes
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_bufferline_colors,
    })
  end
}
