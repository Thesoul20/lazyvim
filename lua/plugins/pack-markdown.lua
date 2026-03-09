local utils = require("utils")

local function diagnostic()
  local system_config = vim.fn.stdpath("config") .. "/.markdownlint.jsonc"
  local project_config = vim.fn.getcwd() .. "/.markdownlint.jsonc"

  local markdownlint = require("lint").linters["markdownlint-cli2"]
  if not utils.contains_arg(markdownlint.args or {}, "--config") then
    markdownlint.args = {}
    table.insert(markdownlint.args, "--config")
  end

  if vim.fn.filereadable(project_config) == 1 then
    if not utils.contains_arg(markdownlint.args, project_config) then
      table.insert(markdownlint.args, project_config)
    end
  else
    if not utils.contains_arg(markdownlint.args, system_config) then
      table.insert(markdownlint.args, system_config)
    end
  end

  return markdownlint.args
end

local markdown_table_change = function()
  vim.ui.input({ prompt = "Separate Char: " }, function(input)
    if not input or #input == 0 then
      return
    end
    local execute_command = ([[:'<,'>MakeTable! ]] .. input)
    vim.cmd(execute_command)
  end)
end

local function shell_escape(str)
  return vim.fn.shellescape(str)
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "img-cloud" })
end

local function get_abs_img_dir()
  local rel_dir = "assets/imgs/"
  local current_dir = vim.fn.expand("%:p:h")
  if current_dir ~= "" then
    return vim.fs.normalize(current_dir .. "/" .. rel_dir)
  end
  return vim.fs.normalize(vim.fn.getcwd() .. "/" .. rel_dir)
end

local function extract_first_url(text)
  return text and text:match("https?://[%w%-%._~:/%?#%[%]@!$&'()*+,;=%%]+") or nil
end

local function validate_image_url(url)
  if vim.fn.executable("curl") ~= 1 then
    return true
  end

  local cmd = string.format("curl -sSLI --max-time 8 %s | tr -d '\\r'", shell_escape(url))
  local out = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    return false
  end

  local status_ok = out:match("^HTTP/%d%.%d%s+2%d%d") or out:match("\nHTTP/%d%.%d%s+2%d%d")
  local is_image = out:lower():match("\ncontent%-type:%s*image/")
  return status_ok and is_image
end

local function paste_image_to_cloud()
  local picgo_bin
  if vim.fn.executable("picgo") == 1 then
    picgo_bin = "picgo"
  elseif vim.fn.executable("picgo-core") == 1 then
    picgo_bin = "picgo-core"
  else
    notify("picgo or picgo-core not found in PATH", vim.log.levels.ERROR)
    return
  end

  local ok, img_clip = pcall(require, "img-clip")
  if not ok then
    notify("img-clip.nvim is not available", vim.log.levels.ERROR)
    return
  end

  local ext = "png"
  local stamp = os.date("%Y%m%d-%H%M%S")
  local suffix = tostring(math.floor((vim.uv or vim.loop).hrtime() % 10000))
  local file_stem = string.format("%s-%s", stamp, suffix)
  local abs_dir = get_abs_img_dir()
  local abs_path = vim.fs.normalize(abs_dir .. "/" .. file_stem .. "." .. ext)

  local pasted = img_clip.paste_image({
    dir_path = abs_dir,
    file_name = file_stem,
    extension = ext,
    relative_to_current_file = false,
    prompt_for_file_name = false,
    embed_image_as_base64 = false,
    template = "",
    insert_mode_after_paste = false,
  })
  if not pasted then
    notify("Paste image failed", vim.log.levels.ERROR)
    return
  end

  local upload_cmd = string.format("%s upload %s 2>&1", picgo_bin, shell_escape(abs_path))
  local output = vim.fn.system(upload_cmd)
  if vim.v.shell_error ~= 0 then
    notify("PicGo upload failed. Run :messages for details", vim.log.levels.ERROR)
    vim.schedule(function()
      vim.notify(output, vim.log.levels.WARN, { title = "picgo output" })
    end)
    return
  end

  local url = extract_first_url(output)
  if not url then
    notify("No URL found in PicGo output", vim.log.levels.ERROR)
    return
  end
  if not validate_image_url(url) then
    notify("Uploaded URL is not accessible image, please retry", vim.log.levels.WARN)
  end

  local markdown = string.format("![](%s)", url)
  vim.api.nvim_put({ markdown }, "l", true, true)
  notify("Uploaded and inserted image URL")
end

vim.g.mkdp_auto_close = 0
vim.g.mkdp_combine_preview = 1

return {
  recommended = function()
    return LazyVim.extras.wants({
      ft = { "markdown", "markdown.mdx" },
      root = "README.md",
    })
  end,
  { import = "lazyvim.plugins.extras.lang.markdown" },
  {
    "mattn/vim-maketable",
    cmd = "MakeTable",
    ft = { "markdown", "markdown.mdx" },
  },
  {
    "HakonHarnes/img-clip.nvim",
    cmd = { "PasteImage", "PasteImageToCloud", "ImgClipDebug", "ImgClipConfig" },
    opts = {
      default = {
        prompt_for_file_name = false,
        embed_image_as_base64 = false,
        drag_and_drop = {
          enabled = true,
          insert_mode = true,
        },
        use_absolute_path = vim.fn.has("win32") == 1,
        relative_to_current_file = true,
        show_dir_path_in_prompt = true,
        dir_path = "assets/imgs/",
      },
    },
    config = function(_, opts)
      require("img-clip").setup(opts)
      pcall(vim.api.nvim_del_user_command, "PasteImageToCloud")
      vim.api.nvim_create_user_command("PasteImageToCloud", paste_image_to_cloud, {
        desc = "Paste image, upload with PicGo, and insert cloud URL",
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {
          on_attach = function()
            vim.keymap.set(
              "n",
              "<leader>cP",
              "<cmd>PasteImage<cr>",
              { desc = "Paste image from system clipboard", noremap = true, silent = true, buffer = true }
            )
            vim.keymap.set(
              "n",
              "<leader>cU",
              paste_image_to_cloud,
              { desc = "Paste image then upload to cloud (PicGo)", noremap = true, silent = true, buffer = true }
            )
            vim.keymap.set(
              "n",
              "<leader>ct",
              [[:'<,'>MakeTable! \t<CR>]],
              { desc = "Markdown csv to table(Default:\\t)", noremap = true, silent = true, buffer = true }
            )
            vim.keymap.set(
              "n",
              "<leader>cT",
              markdown_table_change,
              { desc = "Markdown csv to table with separate char", noremap = true, silent = true, buffer = true }
            )
          end,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = diagnostic(),
        },
      },
      linters_by_ft = {
        markdown = { "markdownlint-cli2" },
      },
    },
  },
}
