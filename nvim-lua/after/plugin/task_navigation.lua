-- ===============================
-- Task navigation using Telescope
-- ===============================

-- CONFIG: set this to your PKB root folder
local PKB_ROOT = vim.env.PKB_ROOT
if not vim.env.PKB_ROOT then
    print("task_navigation.lua:Warning! $PKB_ROOT environment variable is not found!")
end

-- The task id format (t-YYYY-MM-DDTHH:MM, written in a task as task::<id>) is defined in pkb-nvim.
local ids = require("pkb.task_id")

-- Telescope search for task definition
local function jump_to_task_definition()
  local ok, telescope = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  local task_id = ids.under_cursor()
  if not task_id then
    vim.notify("No task ID under cursor", vim.log.levels.WARN)
    return
  end

  telescope.grep_string({
    search = ids.tag(task_id),
    cwd = PKB_ROOT,
    prompt_title = "Task definition: " .. task_id,
  })
end

-- Telescope search for backlinks (all mentions)
local function task_backlinks()
  local ok, telescope = pcall(require, "telescope.builtin")
  if not ok then return end

  local task_id = ids.under_cursor()
  if not task_id then
    vim.notify("No task ID under cursor", vim.log.levels.WARN)
    return
  end

  telescope.grep_string({
    search = task_id,
    cwd = PKB_ROOT,
    prompt_title = "Task backlinks: " .. task_id,
  })
end

-- insert a new task ID at cursor (unique among known tasks and this buffer)
local function insert_new_task_id()
  local id = require("pkb.notifier").new_task_id(vim.api.nvim_buf_get_lines(0, 0, -1, false))
  vim.api.nvim_put({ ids.tag(id) }, "", true, true)
end

-- mappings
vim.keymap.set("n", "<leader>jt", jump_to_task_definition, { desc = "Jump to task definition (Telescope)" })
vim.keymap.set("n", "<leader>tb", task_backlinks, { desc = "Task backlinks (Telescope)" })
vim.keymap.set("i", "<C-t>", insert_new_task_id, { desc = "Insert new task ID" })
