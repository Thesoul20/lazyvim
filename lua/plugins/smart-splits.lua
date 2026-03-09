local term = vim.trim((vim.env.TERM_PROGRAM or ""):lower())
local mux = term == "tmux" or term == "wezterm" or vim.env.KITTY_LISTEN_ON

return {
  "mrjones2014/smart-splits.nvim",
  lazy = true,
  event = mux and "VeryLazy" or nil, -- load early if mux detected
  keys = {
    { "<leader>wh", function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" },
    { "<leader>wj", function() require("smart-splits").move_cursor_down() end, desc = "Move to below split" },
    { "<leader>wk", function() require("smart-splits").move_cursor_up() end, desc = "Move to above split" },
    { "<leader>wl", function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" },
    { "<leader>wH", function() require("smart-splits").resize_left() end, desc = "Resize split left" },
    { "<leader>wJ", function() require("smart-splits").resize_down() end, desc = "Resize split down" },
    { "<leader>wK", function() require("smart-splits").resize_up() end, desc = "Resize split up" },
    { "<leader>wL", function() require("smart-splits").resize_right() end, desc = "Resize split right" },
  },
  opts = { ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" }, ignored_buftypes = { "nofile" } },
}
