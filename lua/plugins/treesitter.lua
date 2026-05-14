return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter').setup()
    require('nvim-treesitter').install({
      'bash', 'c', 'cpp', 'diff', 'gdscript', 'html', 'lua', 'luadoc',
      'markdown', 'markdown_inline', 'python', 'query', 'supercollider',
      'vim', 'vimdoc',
    })
    -- Enable treesitter highlighting for filetypes not handled by Neovim's ftplugins
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'sh', 'c', 'cpp', 'diff', 'gdscript', 'html', 'python', 'supercollider', 'vim' },
      callback = function() pcall(vim.treesitter.start) end,
    })
  end,
}
