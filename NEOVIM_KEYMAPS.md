# Neovim 快捷键记录（场景速查）

> 说明：`<leader>` 在你的配置中未显式重定义，通常为 `Space`。

## 0. 10 秒上手（12 个最高频）

- `<leader>ac`：打开/切换 AI Chat（CodeCompanion）
- `<C-s>` / `<C-g>`（Chat 插入模式）：发送给 Agent
- `ga`（Chat 内）：切换 Agent（Codex/Claude/Gemini）
- `<leader>ai`：对当前代码做 AI Inline 操作
- `<leader>/`：全局搜索（live_grep）
- `gl`：看当前行诊断
- `jk`（插入模式）：退出插入模式
- `<leader>wh`：切到左分屏
- `<leader>wl`：切到右分屏
- `<C-w>c`：关闭当前分屏
- `<leader>gd`：打开/关闭 Diffview
- `<leader>dc`：开始/继续调试

## 1. 日常编辑（最常用）

- `H`：跳到行首（忽略行首空白）
- `L`：跳到行尾
- `x`：删除字符但不写入寄存器
- `n`：跳到下一个搜索结果并居中
- `N`：跳到上一个搜索结果并居中
- `gl`：显示当前行诊断信息（LSP）
- `<leader>/`：在当前工作目录执行 `live_grep`
- 插入模式 `jk`：退出插入模式
- 可视模式 `K`：选中行上移
- 可视模式 `J`：选中行下移

## 2. AI 协作（CodeCompanion）

### 2.1 入口

- `<leader>aa`：打开 `CodeCompanionActions`
- `<leader>ac`：切换 `CodeCompanionChat`（Toggle）
- `<leader>an`：打开新的 `CodeCompanionChat`
- `<leader>ah`：打开历史会话（`CodeCompanionHistory`）
- `<leader>ai`：使用 `CodeCompanion` Inline

### 2.2 Chat 内操作

- `?`：查看 Chat Buffer 全部快捷键
- `ga`：切换当前会话的 Agent/Adapter（`codex` / `claude_code` / `gemini_cli`）
- 插入模式 `<C-s>`（备用 `<C-g>`）：发送消息
- 普通模式 `<CR>` 或 `<C-s>`：发送消息
- 插入模式 `Enter`：换行（不发送）
- `q`：停止当前请求（不是关闭窗口）
- `<C-c>`：关闭 Chat Buffer

### 2.3 历史对话与消息调用（codecompanion-history）

- `gh`（Chat Buffer 内）：打开历史对话列表
- `:CodeCompanionHistory`：打开历史对话列表（命令方式）
- 历史列表内 `<CR>`：恢复/打开选中的历史对话
- 历史列表内 `d`：删除选中的历史对话
- 历史列表内 `r`：重命名选中的历史对话
- 历史列表内 `<C-y>`：复制（duplicate）选中的历史对话
- `sc`（Chat Buffer 内）：手动保存当前对话到历史
- 特性说明：在当前对话进行中切换到其他历史对话，不会中断当前对话

### 2.4 光标跟随说明（CodeCompanion 特性）

- 回答流式输出时，只有当光标在最后一行附近，才会自动跟随到底部
- 一旦光标移到历史内容（不在最后一行），插件会停止自动跟随
- 想恢复跟随：先 `Esc` 回普通模式，再按 `G` 跳到末尾
- 当前配置使用普通模式打开 Chat（`start_in_insert_mode=false`），以提高自动跟随稳定性

## 3. 窗口与分屏

### 3.1 切换分屏

- `<leader>wh`：到左侧分屏
- `<leader>wj`：到下方分屏
- `<leader>wk`：到上方分屏
- `<leader>wl`：到右侧分屏

### 3.2 缩放分屏

- `<leader>wH`：向左调整分屏大小
- `<leader>wJ`：向下调整分屏大小
- `<leader>wK`：向上调整分屏大小
- `<leader>wL`：向右调整分屏大小

### 3.3 关闭分屏

- `<C-w>c`：关闭当前分屏
- `:close`：关闭当前分屏
- `:q`：退出当前窗口（可关闭时）
- `:only`：仅保留当前分屏
- 在 `help` / `nofile` / `quickfix` 等窗口里，`q` 映射为关闭窗口

### 3.4 Neo-tree 后回到编辑区

- Neo-tree 打开后，回编辑区最稳妥方式：`<C-w>l`（切到右侧窗口）
- 回上一个窗口：`<C-w>p`
- 也可用当前配置的分屏切换键：`<leader>wl`（切到右侧编辑窗口）
- 说明：当前配置未在普通模式绑定 `<C-h/j/k/l>` 做窗口跳转；若你把这些 `Ctrl` 组合占用给别的功能，优先使用 `<C-w>` 系列或 `<leader>w*`

## 4. Git 与历史查看

- `<leader>gd`：打开 Diffview
- `<leader>gd`（Diffview 已打开时）：关闭 Diffview
- `<leader>gt`：查看当前分支历史
- `<leader>gT`：查看当前文件历史

## 5. Buffer 操作（切换与关闭）

### 5.1 切换 Buffer

- `<S-h>`：上一个 buffer（Prev Buffer）
- `<S-l>`：下一个 buffer（Next Buffer）
- `[b`：上一个 buffer
- `]b`：下一个 buffer
- `<leader>bb`：切换到上一个使用的 buffer（`e #`）
- `<leader>\``：切换到上一个使用的 buffer（`e #`）

### 5.2 关闭 Buffer

- `<leader>bd`：关闭当前 buffer（保留窗口）
- `<leader>bD`：关闭当前 buffer 并关闭窗口（`:bd`）
- `<leader>bo`：关闭其它 buffer（仅保留当前）

## 6. 调试（DAP）

### 6.1 常用调试控制

- `<leader>db`：切换断点
- `<leader>dB`：条件断点
- `<leader>dD`：清空全部断点
- `<leader>dc`：运行/继续调试
- `<leader>dq`：终止调试
- `<leader>du`：切换 DAP UI
- `<leader>dd`：切换 DAP 布局
- `<leader>dr`：重启当前调试帧
- `<leader>dH`：浮窗查看 DAP 元素
- `<leader>dh`：调试悬浮信息
- `<leader>dG`：生成 `.vscode/launch.json`

### 6.2 功能键

- `F5`：开始/继续
- `F6`：暂停
- `F9`：切换断点
- `F10`：单步跳过（Step Over）
- `F11`：单步进入（Step Into）
- `F23`：单步跳出（Step Out）
- `F29`：重启调试

## 7. 语言专项

### 7.1 Python（Molten）

> 仅在 `python` 文件类型下可用，前缀为 `<leader>j`

- `<leader>je`：按 operator 运行
- `<leader>jl`：运行当前行
- `<leader>jr`（可视模式）：运行选中区域
- `<leader>jc`：重新运行当前 cell
- `<leader>jk`：进入输出窗口
- `<leader>jmi`：初始化 Molten
- `<leader>jmp`：按当前虚拟环境初始化内核
- `<leader>jmh`：隐藏输出
- `<leader>jmI`：中断内核
- `<leader>jmR`：重启内核
- `]c`：下一个 Molten Cell
- `[c`：上一个 Molten Cell

### 7.2 Markdown

> 仅在 `markdown` 文件（marksman attach 后）可用

- `<leader>cP`：从剪贴板粘贴图片（`PasteImage`）
- `<leader>cU`：粘贴图片后上传图床并插入链接（`PasteImageToCloud`）
- `:PasteImageToCloud`：命令方式执行图床上传插入
- `<leader>ct`：将选区按 `Tab` 分隔转换为 Markdown 表格
- `<leader>cT`：输入分隔符后，将选区转换为 Markdown 表格

## 8. 其它工具

- `<leader>nh`：显示图片悬浮预览（Snacks）
- `<leader>nn`：打开通知历史（Snacks）
- `<leader>tf`：打开/切换浮动终端（当前工作目录）
- `<leader>tF`：打开/切换浮动终端（项目根目录）
- `<M-\`>`：打开/切换浮动终端（项目根目录，Alt+反引号）
