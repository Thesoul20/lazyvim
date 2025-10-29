return {
  "okuuva/auto-save.nvim",
  event = { "InsertLeave", "TextChanged" }, -- 触发时机
  opts = {
    enabled = true,                           -- 全局开关
    write_all_buffers = false,                -- 只保存当前 buffer
    debounce_delay = 1000,                    -- 1 s 内无改动才真正落盘
    -- 下面两行可选：保存时打印点小提示
    execution_message = {
      message = function() return "Auto-saved at " .. vim.fn.strftime "%H:%M:%S" end,
      dim = 0.18,
      cleaning_interval = 1250,
    },
    -- 不自动保存的文件类型 / 缓冲区
    filter_buffer = function(buf)
      local ft = vim.bo[buf].filetype
      local skip = { "alpha", "TelescopePrompt", "DressingInput", "neo-tree" }
      return not vim.tbl_contains(skip, ft)
    end,
  },
}
