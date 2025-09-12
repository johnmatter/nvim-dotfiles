return {
  'tidalcycles/vim-tidal',
  ft = 'tidal',
  config = function()
    -- vim.g.tidal_sc_enable = 1
    vim.g.tidal_target = "tmux"
    vim.g.tidal_flash_duration = 150
    vim.g.tidal_paste_file = "/tmp/tidal_paste_file.txt"
  end,
} 