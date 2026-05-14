return {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    -- Mason must be loaded before its dependents so we need to set it up here.
    -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
    { 'mason-org/mason.nvim', opts = {} },
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Useful status updates for LSP.
    { 'j-hui/fidget.nvim',    opts = {} },

    -- Use blink.cmp for completion capabilities
    'saghen/blink.cmp',

    -- JSON schemas for jsonls
    'b0o/schemastore.nvim',
  },
  config = function()
    -- Global LSP client filter - runs before any LSP functionality
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-filter', { clear = true }),
      callback = function(event)
        local bufname = vim.api.nvim_buf_get_name(event.buf)
        local filetype = vim.bo[event.buf].filetype
        
        -- Stop LSP clients for special buffers
        if bufname:match('diffview://') or 
           bufname:match('^diffview:') or 
           bufname:match('^fugitive://') or
           bufname:match('^oil://') or
           filetype:match('Diffview') or
           filetype:match('^git') then
          
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client then
            client.stop()
            return
          end
        end
      end,
    })

    -- Prevent LSP attachment to special buffers (diffview, fugitive, oil, etc.)
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local bufname = vim.api.nvim_buf_get_name(event.buf)
        local filetype = vim.bo[event.buf].filetype
        
        -- Skip LSP attachment for special buffers
        if bufname:match('diffview://') or 
           bufname:match('^diffview:') or 
           bufname:match('^fugitive://') or
           bufname:match('^oil://') or
           filetype:match('Diffview') or
           filetype:match('^git') then
          return
        end
        -- Create a function that lets us more easily define mappings specific for LSP related
        -- items. It sets the mode, buffer and description for us each time.
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Rename the variable under your cursor.
        --  Most Language Servers support renaming across files, etc.
        map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

        -- Find references for the word under your cursor.
        map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

        -- Jump to the implementation of the word under your cursor.
        --  Useful when your language has ways of declaring types without an actual implementation.
        map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

        -- Jump to the definition of the word under your cursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        --  To jump back, press <C-t>.
        map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header.
        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- Fuzzy find all the symbols in your current document.
        --  Symbols are things like variables, functions, types, etc.
        map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

        -- Fuzzy find all the symbols in your current workspace.
        --  Similar to document symbols, except searches over your entire project.
        map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

        -- Jump to the type of the word under your cursor.
        --  Useful when you're not sure what type a variable is and you want to see
        --  the definition of its *type*, not where it was *defined*.
        map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

        -- Format code using LSP
        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_formatting, event.buf) then
          map('<leader>f', vim.lsp.buf.format, '[F]ormat code')
        end

        -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
        ---@param client vim.lsp.Client
        ---@param method vim.lsp.protocol.Method
        ---@param bufnr? integer some lsp support methods only in specific files
        ---@return boolean
        local function client_supports_method(client, method, bufnr)
          if vim.fn.has 'nvim-0.11' == 1 then
            return client:supports_method(method, bufnr)
          else
            return client.supports_method(method, { bufnr = bufnr })
          end
        end

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- The following code creates a keymap to toggle inlay hints in your
        -- code, if the language server you are using supports them
        --
        -- This may be unwanted, since they displace some of your code
        -- Changed from <leader>th to <leader>ti to avoid conflict with theme picker
        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          map('<leader>ti', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle [I]nlay hints')
        end
      end,
    })

    -- Diagnostic Config
    -- See :help vim.diagnostic.Opts
    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      } or {},
      virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    }

    -- blink.cmp capabilities for LSP
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- Enable the following language servers
    --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    --
    --  Add any additional override configuration in the following tables. Available keys are:
    --  - cmd (table): Override the default command used to start the server
    --  - filetypes (table): Override the default list of associated filetypes for the server
    --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
    --  - settings (table): Override the default settings passed when initializing the server.
    --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
    local servers = {
      clangd = {
        settings = {
          clangd = {
            arguments = {
              '--background-index',
              '--clang-tidy',
              '--header-insertion=iwyu',
              '--completion-style=detailed',
              '--function-arg-placeholders',
              '--fallback-style=file',
              '--style=' .. vim.fn.expand('~/.config/nvim/.clang-format')
            }
          }
        }
      },
      -- gopls = {},
      pyright = {
        settings = {
          python = {
            analysis = {
              extraPaths = { '/Users/matter/coldtype/coldtype/src' },
            },
          },
        },
      },
      -- rust_analyzer = {},
      -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
      --
      -- Some languages (like typescript) have entire language plugins that can be useful:
      --    https://github.com/pmizio/typescript-tools.nvim
      --
      -- But for many setups, the LSP (`ts_ls`) will work just fine
      -- ts_ls = {},
      --

      lua_ls = {
        -- cmd = { ... },
        -- filetypes = { ... },
        -- capabilities = {},
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            -- diagnostics = { disable = { 'missing-fields' } },
            -- diagnostics = { enable = true, globals = { "vim" }, },
          },
        },
      },

      marksman = {
        -- Marksman LSP for Markdown
        filetypes = { 'markdown' },
        root_dir = require('lspconfig').util.root_pattern('.marksman.toml', '.git'),
        settings = {
          marksman = {
            completion = {
              wiki = { enabled = true }
            }
          }
        }
      },

      jsonls = {
        -- JSON Language Server with schema support
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      },

      texlab = {
        -- LaTeX Language Server
        settings = {
          texlab = {
            build = {
              executable = 'latexmk',
              args = { '-pdf', '-interaction=nonstopmode', '-synctex=1', '%f' },
              onSave = false,  -- Set to true to build on save
            },
            forwardSearch = {
              executable = nil,  -- Set to your PDF viewer (e.g., 'zathura', 'skim')
              args = {},
            },
            chktex = {
              onOpenAndSave = false,  -- LaTeX linter
              onEdit = false,
            },
            diagnosticsDelay = 300,
            latexFormatter = 'latexindent',
            latexindent = {
              modifyLineBreaks = false,
            },
          },
        },
      },

      neocmakelsp = {
        -- CMake Language Server
        filetypes = { 'cmake' },
        settings = {
          neocmakelsp = {
            format = { enable = true },
            lint = { enable = true },
          },
        },
      },

      ts_ls = {},

      yamlls = {
        settings = {
          yaml = {
            schemaStore = {
              enable = false,
              url = '',
            },
            schemas = require('schemastore').yaml.schemas(),
            validate = true,
          },
        },
      },

    }

    -- Ensure the servers and tools above are installed
    -- You can add other tools here that you want Mason to install
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua',
      'marksman',
      'clangd',
      'clang-format',
      'texlab',
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    -- Register per-server config via nvim 0.11 native API.
    -- mason-lspconfig v2 removed the `handlers` block; `automatic_enable`
    -- (default true) will call vim.lsp.enable() for each installed server.
    for server_name, server in pairs(servers) do
      server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
      vim.lsp.config(server_name, server)
    end

    require('mason-lspconfig').setup {
      ensure_installed = {},
      automatic_installation = false,
    }

    -- Formatting command aliases
    vim.api.nvim_create_user_command('Format', function()
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer using LSP' })

    vim.api.nvim_create_user_command('ClangFormat', function()
      vim.cmd('!clang-format -i --style=file ' .. vim.fn.expand('%'))
      vim.cmd('edit!')
    end, { desc = 'Format current C++ file using clang-format' })


  end,
}
