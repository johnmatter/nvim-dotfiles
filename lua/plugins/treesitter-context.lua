return {
  'nvim-treesitter/nvim-treesitter-context',
  config = function()
    require('treesitter-context').setup{
      enable = true,
      multiwindow = false,
      max_lines = 0, -- <= 0 means no limit
      min_window_height = 0,
      line_numbers = true,
      multiline_threshold = 20,
      trim_scope = 'outer', -- lines to discard if `max_lines` exceeded. ['inner', 'outer']
      mode = 'cursor',  -- ['cursor', 'topline']
      -- Separator between context and content. Should be a single character string, like '-'.
      -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      separator = nil,
      zindex = 20, -- The Z-index of the context window
      on_attach = function(buf)
        return vim.bo[buf].filetype ~= 'markdown'
      end,
    }
  end,
}
