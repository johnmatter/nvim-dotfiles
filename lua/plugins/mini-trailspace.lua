return {

  'echasnovski/mini.trailspace',
  config = function()
    require('mini.trailspace').setup()
    -- Automatically trim on write
    vim.api.nvim_create_autocmd("BufWritePre", {
      callback = function()
        require('mini.trailspace').trim()
        require('mini.trailspace').trim_last_lines()
      end
    })
  end

}
