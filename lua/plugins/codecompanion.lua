return {
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionActions", "CodeCompanionChat", "CodeCompanionCmd" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/codecompanion-history.nvim",
    },
    init = function()
      local group = vim.api.nvim_create_augroup("codecompanion_local_opts", { clear = true })
      local function ensure_codecompanion_wrap(buf, win)
        if not (buf and vim.api.nvim_buf_is_valid(buf)) then
          return
        end
        if vim.bo[buf].filetype ~= "codecompanion" then
          return
        end
        win = win or vim.api.nvim_get_current_win()
        if not (win and vim.api.nvim_win_is_valid(win)) then
          return
        end
        vim.wo[win].wrap = true
        vim.wo[win].linebreak = true
        vim.wo[win].breakindent = true
      end

      vim.api.nvim_create_autocmd("FileType", {
        desc = "CodeCompanion local options and C-g fallback send",
        group = group,
        pattern = "codecompanion",
        callback = function(args)
          ensure_codecompanion_wrap(args.buf, vim.api.nvim_get_current_win())
          vim.keymap.set("i", "<C-g>", function()
            local keys = vim.api.nvim_replace_termcodes("<C-s>", true, false, true)
            vim.api.nvim_feedkeys(keys, "m", false)
          end, {
            buffer = args.buf,
            silent = true,
            desc = "CodeCompanion send message (fallback)",
          })
        end,
      })
      vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
        desc = "Keep CodeCompanion wrapping options enabled on window enter",
        group = group,
        callback = function(args)
          ensure_codecompanion_wrap(args.buf, vim.api.nvim_get_current_win())
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        desc = "Set local chat title from first user message",
        group = group,
        pattern = "CodeCompanionChatSubmitted",
        callback = function(opts)
          local ok_chat_module, chat_module = pcall(require, "codecompanion.interactions.chat")
          if not ok_chat_module then
            return
          end
          local bufnr = opts.data and opts.data.bufnr
          if not bufnr then
            return
          end
          local chat = chat_module.buf_get_chat(bufnr)
          if not chat or (chat.opts and chat.opts.title and chat.opts.title ~= "") then
            return
          end
          local messages = chat.messages or {}
          local first_user_content
          for _, msg in ipairs(messages) do
            local is_user = msg.role == "user"
            local content = msg.content and vim.trim(msg.content) or ""
            local is_meta = msg.opts and (msg.opts.tag or msg.opts.reference or msg.opts.context_id)
            if is_user and content ~= "" and not is_meta then
              first_user_content = content
              break
            end
          end
          if not first_user_content then
            return
          end
          local title = first_user_content:gsub("%s+", " ")
          title = vim.trim(title)
          local max_len = 48
          if #title > max_len then
            title = title:sub(1, max_len) .. "..."
          end
          if title == "" then
            return
          end
          chat.opts.title = title
          local ok_cc, cc = pcall(require, "codecompanion")
          if ok_cc and cc.extensions and cc.extensions.history and cc.extensions.history.save_chat then
            cc.extensions.history.save_chat(chat)
          end
        end,
      })

    end,
    keys = {
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "Agent Actions", mode = { "n", "v" } },
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Agent Chat", mode = { "n", "v" } },
      { "<leader>an", "<cmd>CodeCompanionChat<cr>", desc = "Agent New Chat", mode = { "n", "v" } },
      { "<leader>ah", "<cmd>CodeCompanionHistory<cr>", desc = "Agent History", mode = { "n", "v" } },
      { "<leader>ai", "<cmd>CodeCompanion<cr>", desc = "Agent Inline", mode = { "n", "v" } },
    },
    opts = function(_, opts)
      opts = opts or {}
      opts.adapters = opts.adapters or {}
      opts.adapters.acp = opts.adapters.acp or {}
      opts.interactions = opts.interactions or {}
      opts.interactions.chat = opts.interactions.chat or {}
      opts.interactions.chat.keymaps = opts.interactions.chat.keymaps or {}
      opts.interactions.chat.keymaps.send = opts.interactions.chat.keymaps.send or {}
      opts.interactions.chat.keymaps.send.modes = opts.interactions.chat.keymaps.send.modes or {}
      opts.strategies = opts.strategies or {}
      opts.display = opts.display or {}
      opts.display.chat = opts.display.chat or {}
      opts.display.chat.window = opts.display.chat.window or {}
      opts.extensions = opts.extensions or {}

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
      opts.interactions.chat.keymaps.send.modes.i = "<C-s>"
      opts.display.chat.window = vim.tbl_deep_extend("force", opts.display.chat.window, {
        layout = "buffer",
        opts = {
          wrap = true,
          linebreak = true,
          breakindent = true,
        },
      })
      opts.display.chat.start_in_insert_mode = false
      opts.extensions.history = vim.tbl_deep_extend("force", opts.extensions.history or {}, {
        enabled = true,
        opts = {
          dir_to_save = vim.fn.stdpath("data") .. "/codecompanion_chats.json",
          auto_generate_title = false,
        },
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
