-- Indentation settings for GDScript
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2

local port = tonumber(os.getenv('GDScript_Port')) or 6005
local cmd = vim.lsp.rpc.connect('127.0.0.1', port)
local pipe = '/tmp/godot.pipe'

-- Get blink.cmp capabilities for proper LSP integration
local capabilities = require('blink.cmp').get_lsp_capabilities()

vim.lsp.start({
  name = 'Godot',
  cmd = cmd,
  root_dir = vim.fs.dirname(vim.fs.find({ 'project.godot', '.git' }, { upward = true })[1]),
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    pcall(vim.fn.serverstart, pipe)
  end
})
