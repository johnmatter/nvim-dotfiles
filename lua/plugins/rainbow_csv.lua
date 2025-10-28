return {
  "mechatroner/rainbow_csv",
  dir = "/Users/matter/repos/rainbow_csv", -- Use local dev version with fix
  ft = { "csv", "tsv", "csv_semicolon", "csv_whitespace", "csv_pipe", "rfc_csv", "rfc_semicolon" },
  config = function()
    -- Rainbow CSV auto-detects and highlights CSV files with different colors per column
    -- Commands available:
    -- :RainbowDelim - Manually set delimiter
    -- :RainbowAlign - Align columns
    -- :RainbowShrink - Shrink columns
    -- :Select - SQL-like queries on CSV
    vim.g.rainbow_csv_delim_auto = 1 -- Auto-detect delimiter
  end,
}
