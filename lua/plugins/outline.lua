return {
  'hedyhli/outline.nvim',
  lazy = true,
  cmd = { 'Outline', 'OutlineOpen' },
  keys = {
    { '<leader>0', '<cmd>Outline<CR>', desc = 'Toggle outline' },
  },
  config = function()
    require('outline').setup {
      outline_window = {
        position = 'left',
        width = 25,
        relative_width = true,
        auto_close = false,
        auto_jump = false,
        jump_highlight_duration = 300,
        center_on_jump = true,
        show_numbers = false,
        show_relative_numbers = false,
        show_symbol_details = true,
        preview_bg_highlight = 'Pmenu',
        keymaps = {
          close = {'<Esc>', 'q'},
          goto_location = '<Cr>',
          peek_location = 'o',
          goto_and_close = '<S-Cr>',
          restore_location = '<C-g>',
          hover_symbol = '<C-space>',
          toggle_preview = 'K',
          rename_symbol = 'r',
          code_actions = 'a',
          fold = 'h',
          unfold = 'l',
          fold_toggle = '<Tab>',
          fold_toggle_all = '<S-Tab>',
          fold_all = 'W',
          unfold_all = 'E',
          fold_reset = 'R',
        },
      },
      outline_items = {
        highlight_hovered_item = true,
        show_symbol_lineno = false,
        show_symbol_details = true,
        auto_set_cursor = true,
        auto_update_events = {
          follow = { 'CursorMoved' },
          items = { 'InsertLeave', 'WinEnter', 'BufEnter', 'BufWinEnter', 'TabEnter', 'BufWritePost' },
        },
      },
      guides = {
        enabled = true,
        markers = {
          bottom = '└',
          middle = '├',
          vertical = '│',
        },
      },
      symbol_folding = {
        autofold_depth = 1,
        auto_unfold = {
          hovered = true,
          only = true,
        },
        markers = { '', '' },
      },
      preview_window = {
        auto_preview = false,
        open_hover_on_preview = false,
        width = 50,
        min_width = 50,
        relative_width = true,
        border = 'single',
        winhl = 'NormalFloat:',
        live = false,
      },
      keymaps = {
        show_help = '?',
        close = 'q',
        toggle_preview = 'K',
        jump_close = 'o',
        jump = '<Cr>',
        hover = 'h',
        fold = 'c',
        unfold = 'e',
        fold_toggle = '<Tab>',
        fold_all = 'zM',
        unfold_all = 'zR',
        fold_reset = 'zX',
      },
      providers = {
        priority = { 'lsp', 'coc', 'markdown', 'norg' },
        lsp = {
          blacklist_clients = {},
        },
      },
      symbols = {
        filter = {
          default = {
            'String',
            exclude = true,
          },
          markdown = {
            'Interface',
            'Function',
            'Class',
            'Method',
            'Property',
            'Field',
            'Constructor',
            'Enum',
            'Module',
            'Constant',
            'String',
            'Number',
            'Boolean',
            'Array',
            'Object',
            'Package',
            'Namespace',
            exclude = false,
          },
        },
        icon_fetcher = nil,
        icon_source = nil,
        icons = {
          File = { icon = '󰈙', hl = 'Identifier' },
          Module = { icon = '󰆧', hl = 'Include' },
          Namespace = { icon = '󰅪', hl = 'Include' },
          Package = { icon = '󰏗', hl = 'Include' },
          Class = { icon = '𝓒', hl = 'Type' },
          Method = { icon = 'ƒ', hl = 'Function' },
          Property = { icon = '', hl = 'Identifier' },
          Field = { icon = '󰆨', hl = 'Identifier' },
          Constructor = { icon = '', hl = 'Special' },
          Enum = { icon = 'ℰ', hl = 'Type' },
          Interface = { icon = '󰜰', hl = 'Type' },
          Function = { icon = '', hl = 'Function' },
          Variable = { icon = '', hl = 'Constant' },
          Constant = { icon = '', hl = 'Constant' },
          String = { icon = '𝓐', hl = 'String' },
          Number = { icon = '#', hl = 'Number' },
          Boolean = { icon = '⊨', hl = 'Boolean' },
          Array = { icon = '󰅪', hl = 'Constant' },
          Object = { icon = '⦿', hl = 'Type' },
          Key = { icon = '🔐', hl = 'Type' },
          Null = { icon = 'NULL', hl = 'Type' },
          EnumMember = { icon = '', hl = 'Identifier' },
          Struct = { icon = '𝓢', hl = 'Structure' },
          Event = { icon = '🗲', hl = 'Type' },
          Operator = { icon = '+', hl = 'Identifier' },
          TypeParameter = { icon = '𝙏', hl = 'Identifier' },
          Component = { icon = '󰅴', hl = 'Function' },
          Fragment = { icon = '󰅴', hl = 'Constant' },
        },
      },
    }

    -- Set custom winbar to show filename in outline window
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'Outline',
      callback = function()
        -- Get the source buffer (the buffer being outlined)
        local outline_bufnr = vim.api.nvim_get_current_buf()
        local ok, outline_module = pcall(require, 'outline')

        if ok and outline_module.get_source_buffer then
          local source_buf = outline_module.get_source_buffer()

          if source_buf and vim.api.nvim_buf_is_valid(source_buf) then
            local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(source_buf), ':t')
            vim.wo.winbar = filename .. ' OUTLINE'
          else
            vim.wo.winbar = 'OUTLINE'
          end
        else
          vim.wo.winbar = 'OUTLINE'
        end
      end,
    })
  end,
}
