-- ===============================
-- Task navigation using Telescope
-- ===============================

-- CONFIG: set this to your PKB root folder
local PKB_ROOT = "/home/eelis/pkb"  -- <<< change this to your vault/root

local TASK_ID_REGEX = "t%-%d%d%d%d%-%d%d%-%d%dT%d%d:%d%d"

-- get full task ID under cursor or first on line
local function get_task_id_under_cursor()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  if not line then return nil end

  -- find all task IDs on the line
  local matches = {}
  for start_pos, match in line:gmatch("()(" .. TASK_ID_REGEX .. ")") do
    local end_pos = start_pos + #match - 1
    table.insert(matches, {start = start_pos, finish = end_pos, id = match})
  end

  if #matches == 0 then return nil end

  local cursor_pos = col + 1 -- Lua 1-indexed

  -- find the match containing cursor
  for _, m in ipairs(matches) do
    if cursor_pos >= m.start and cursor_pos <= m.finish then
      return m.id
    end
  end

  -- fallback: return first match
  return matches[1].id
end

-- Telescope search for task definition
local function jump_to_task_definition()
  local ok, telescope = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  local task_id = get_task_id_under_cursor()
  if not task_id then
    vim.notify("No task ID under cursor", vim.log.levels.WARN)
    return
  end

  local search_str = "task::" .. task_id

  telescope.grep_string({
    search = search_str,
    cwd = PKB_ROOT,
    prompt_title = "Task definition: " .. task_id,
  })
end

-- Telescope search for backlinks (all mentions)
local function task_backlinks()
  local ok, telescope = pcall(require, "telescope.builtin")
  if not ok then return end

  local task_id = get_task_id_under_cursor()
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

-- insert a new task ID at cursor
local function insert_new_task_id()
  local ts = vim.fn.strftime("%Y-%m-%dT%H:%M")
  vim.api.nvim_put({ "task::t-" .. ts }, "", true, true)
end

-- mappings
vim.keymap.set("n", "<leader>jt", jump_to_task_definition, { desc = "Jump to task definition (Telescope)" })
vim.keymap.set("n", "<leader>tb", task_backlinks, { desc = "Task backlinks (Telescope)" })
vim.keymap.set("i", "<C-t>", insert_new_task_id, { desc = "Insert new task ID" })

