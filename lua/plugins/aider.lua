return {
  "GeorgesAlkhouri/nvim-aider",
  cmd = "Aider",
  keys = {
    { "<leader>a/", "<cmd>Aider toggle<cr>", desc = "Toggle Aider" },
    { "<leader>as", "<cmd>Aider send<cr>", desc = "Send to Aider", mode = { "n", "v" } },
    { "<leader>ac", "<cmd>Aider command<cr>", desc = "Aider Commands" },
    { "<leader>ab", "<cmd>Aider buffer<cr>", desc = "Send Buffer" },
    { "<leader>a=", "<cmd>Aider add<cr>", desc = "Add File" },
    { "<leader>a-", "<cmd>Aider drop<cr>", desc = "Drop File" },
    { "<leader>ar", "<cmd>Aider add readonly<cr>", desc = "Add Read-Only" },
    { "<leader>aR", "<cmd>Aider reset<cr>", desc = "Reset Session" },
  },
  dependencies = {
    "folke/snacks.nvim",
  },
  opts = function()
    local args = {
      "--no-auto-commits",
      "--pretty",
      "--stream",
    }

    -- Always include global CLAUDE.md
    local global_claude = vim.fn.expand("~/.claude/CLAUDE.md")
    if vim.fn.filereadable(global_claude) == 1 then
      table.insert(args, "--read")
      table.insert(args, global_claude)
    end

    -- Include project CLAUDE.md if in a git repo
    local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
    if git_root ~= "" then
      local project_claude = git_root .. "/CLAUDE.md"
      if vim.fn.filereadable(project_claude) == 1 then
        table.insert(args, "--read")
        table.insert(args, project_claude)
      end
    end

    return { args = args }
  end,
}
