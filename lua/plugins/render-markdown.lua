return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    code = {
      conceal_delimiters = false,
      langauge_icon = false,
    },
    checkbox = {
      checked = {
        icon = ' ',
        highlight = 'RainbowDelimiterGreen',
        scope_highlight = '@markup.strikethrough' -- works with my mess below!
      },
      unchecked = {
        icon = ' ',
        highlight = 'RainbowDelimiterRed',
      }
    },
  },

  config = function (_, opts)
    require('render-markdown').setup(opts)

    local function set_heading_highlights()
      local heading_links = {
        "RainbowDelimiterRed",
        "RainbowDelimiterOrange",
        "RainbowDelimiterYellow",
        "RainbowDelimiterGreen",
        "RainbowDelimiterBlue",
        "RainbowDelimiterViolet",
      }
      for i, group in ipairs(heading_links) do
        vim.api.nvim_set_hl(0, "RenderMarkdownH" .. i .. "Bg", { link = group })
      end
    end

    local function set_strikethrough_highlights()
      -- Define strikethrough highlight groups
      vim.api.nvim_set_hl(0, "@text.strikethrough", {
        strikethrough = true,
        fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg or "#888888",
      })
      vim.api.nvim_set_hl(0, "@markup.strikethrough", {
        link = "@text.strikethrough"
      })
    end

    -- Set highlights immediately
    set_heading_highlights()
    set_strikethrough_highlights()

    -- Re-apply after colorscheme changes
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        set_heading_highlights()
        set_strikethrough_highlights()
      end,
    })

    -- Apply strikethrough highlighting and concealing to markdown files
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
      pattern = "*.md",
      callback = function()
        -- Enable concealing for strikethrough delimiters
        vim.wo.conceallevel = 2
        vim.wo.concealcursor = "nvic"
        
        -- Apply strikethrough highlighting
        vim.cmd("syntax match markdownStrikethrough /\\~\\~[^~]\\+\\~/ conceal cchar= ")
        vim.cmd("highlight link markdownStrikethrough @text.strikethrough")
        
        -- Add fill characters to headings using virtual text
        local function setup_heading_fills()
          local fill_char = "–"
          local ns_id = vim.api.nvim_create_namespace("markdown_heading_fills")
          
          -- Create a function to add fill characters to heading lines
          local function add_heading_fills()
            local bufnr = vim.api.nvim_get_current_buf()
            
            -- Clear existing virtual text
            vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
            
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            
            for i, line in ipairs(lines) do
              -- Check if line is a heading (starts with #)
              local hashes, text = line:match("^(#+)%s+(.+)")
              if hashes then
                local heading_level = #hashes
                
                if heading_level <= 6 then
                  -- Calculate how many fill characters we need
                  local current_length = #line
                  local window_width = vim.api.nvim_win_get_width(0)
                  local fill_length = math.max(0, window_width - current_length - 1)
                  
                  if fill_length > 0 then
                    -- Add virtual text at the end of the line
                    local fill_text = " " .. string.rep(fill_char, fill_length)
                    vim.api.nvim_buf_set_extmark(bufnr, ns_id, i-1, #line, {
                      virt_text = {{fill_text, "RenderMarkdownH" .. heading_level .. "Bg"}},
                      virt_text_pos = "eol",
                      hl_mode = "combine",
                    })
                  end
                end
              end
            end
          end
          
          -- Add fill characters when buffer is entered
          add_heading_fills()
          
          -- Recalculate fill characters when window is resized
          vim.api.nvim_create_autocmd("VimResized", {
            buffer = vim.api.nvim_get_current_buf(),
            callback = add_heading_fills,
          })
          
          -- Recalculate fill characters when text changes (for editing headings)
          vim.api.nvim_create_autocmd("TextChanged", {
            buffer = vim.api.nvim_get_current_buf(),
            callback = function()
              -- Debounce the update to avoid excessive recalculations
              vim.defer_fn(add_heading_fills, 100)
            end,
          })
          
          -- Recalculate fill characters after buffer is written
          vim.api.nvim_create_autocmd("BufWritePost", {
            buffer = vim.api.nvim_get_current_buf(),
            callback = add_heading_fills,
          })
        end
        
        setup_heading_fills()
      end,
    })
  end
}
