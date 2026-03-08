return {
  {
    "olimorris/codecompanion.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "Agent Actions", mode = { "n", "v" } },
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Agent Chat", mode = { "n", "v" } },
      { "<leader>an", "<cmd>CodeCompanionChat<cr>", desc = "Agent New Chat", mode = { "n", "v" } },
      { "<leader>ai", "<cmd>CodeCompanion<cr>", desc = "Agent Inline", mode = { "n", "v" } },
    },
    opts = function(_, opts)
      opts = opts or {}
      opts.adapters = opts.adapters or {}
      opts.adapters.acp = opts.adapters.acp or {}
      opts.strategies = opts.strategies or {}

      opts.adapters.acp.claude_code = function()
        return require("codecompanion.adapters").extend("claude_code", {})
      end

      opts.adapters.acp.codex = function()
        return require("codecompanion.adapters").extend("codex", {
          commands = { default = { "codex-acp" } },
          defaults = {
            auth_method = "chatgpt",
          },
        })
      end

      opts.adapters.acp.gemini_cli = function()
        return require("codecompanion.adapters").extend("gemini_cli", {})
      end

      opts.strategies.chat = vim.tbl_deep_extend("force", opts.strategies.chat or {}, {
        adapter = "codex",
      })
      opts.strategies.inline = vim.tbl_deep_extend("force", opts.strategies.inline or {}, {
        adapter = "codex",
      })

      return opts
    end,
    specs = {
      {
        "folke/which-key.nvim",
        optional = true,
        opts = {
          spec = {
            { "<leader>a", group = "agents" },
          },
        },
      },
    },
  },
}
