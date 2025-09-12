return {
  'davidgranstrom/scnvim',
  ft = 'supercollider',
  config = function()
    local scnvim = require 'scnvim'
    local map = scnvim.map
    local map_expr = scnvim.map_expr
    
    scnvim.setup {
      -- Enable scnvim's built-in completion
      completion = {
        enabled = true,
      },
      
      -- Enable snippets (scnvim generates these automatically)
      snippet = {
        engine = {
          name = "luasnip"
        }
      },
    }
  end,
  dependencies = {
    'L3MON4D3/LuaSnip', -- For snippet support
  }
}
