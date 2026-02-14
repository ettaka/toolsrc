local M = {}

--------------------------------------------------
-- CONFIG
--------------------------------------------------

M.local_dir = vim.fn.expand("~/pkb/")
M.phone_dir = vim.fn.expand("~/phone/Internal storage/Documents/pkb/")

--------------------------------------------------
-- UTILS
--------------------------------------------------

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO)
end

local function git_dirty()
  local handle = io.popen("git -C "..M.local_dir.." status --porcelain 2>/dev/null")
  if not handle then return false end
  local result = handle:read("*a")
  handle:close()
  return result ~= ""
end

local function path_exists(p)
  return vim.loop.fs_stat(p) ~= nil
end

local function is_phone_mounted()
  return path_exists(M.phone_dir)
end

--------------------------------------------------
-- FLOATING WINDOW
--------------------------------------------------

local function create_float()
  local buf = vim.api.nvim_create_buf(false,true)

  local width  = math.floor(vim.o.columns * 0.7)
  local height = math.floor(vim.o.lines * 0.6)

  local win = vim.api.nvim_open_win(buf,true,{
    relative="editor",
    width=width,
    height=height,
    col=(vim.o.columns-width)/2,
    row=(vim.o.lines-height)/2,
    border="rounded",
    title=" PKB Sync ",
    style="minimal"
  })

  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "log"

  -- simple cancel key
  vim.keymap.set("n","q",function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win,true)
    end
  end,{buffer=buf})

  return buf, win
end

--------------------------------------------------
-- STREAM WRITER
--------------------------------------------------

local function make_stream_writer(buf)
  return function(chunk)
    if not chunk or chunk=="" then return end
    local lines = vim.split(chunk,"\n",{plain=true})
    vim.api.nvim_buf_set_lines(buf,-1,-1,false,lines)
  end
end

--------------------------------------------------
-- RSYNC CORE
--------------------------------------------------

local function run_rsync(src,dst)
  if not path_exists(src) then
    notify("Source path does not exist: "..src,vim.log.levels.ERROR)
    return
  end
  if not path_exists(dst) then
    notify("Destination path does not exist: "..dst,vim.log.levels.ERROR)
    return
  end

  if git_dirty() then
    notify("Local PKB has unsaved git changes — aborting sync",vim.log.levels.WARN)
    return
  end

  local inplace = dst:match("phone") and "--inplace" or ""

  local cmd = {
    "rsync",
    "-a",
    "--delete",
    "--info=name,stats",
    "--exclude=.git/",
  }

  if inplace ~= "" then table.insert(cmd,inplace) end
  table.insert(cmd,src)
  table.insert(cmd,dst)

  local buf,win = create_float()
  local append = make_stream_writer(buf)
  append("Starting sync...\n")

  vim.system(cmd,{
    text=true,
    stdout = function(_,data)
      vim.schedule(function() append(data) end)
    end,
    stderr = function(_,data)
      vim.schedule(function() append(data) end)
    end,
  },function(obj)
    vim.schedule(function()
      if obj.code == 0 then
        append("\n✓ Sync complete")
      else
        append("\n✗ Sync failed (code "..(obj.code or "?")..")")
      end
      append("\nPress q to close")
    end)
  end)
end

--------------------------------------------------
-- SMART SYNC
--------------------------------------------------

function M.smart_sync()
  if not is_phone_mounted() then
    notify("Phone not mounted!",vim.log.levels.ERROR)
    return
  end

  local local_time = path_exists(M.local_dir) and vim.fn.getftime(M.local_dir) or 0
  local phone_time = path_exists(M.phone_dir) and vim.fn.getftime(M.phone_dir) or 0

  if local_time > phone_time then
    notify("Sync direction: local → phone")
    run_rsync(M.local_dir,M.phone_dir)

  elseif phone_time > local_time then
    notify("Sync direction: phone → local")
    run_rsync(M.phone_dir,M.local_dir)

  else
    notify("Already in sync ✓")
  end
end

--------------------------------------------------
-- USER COMMAND
--------------------------------------------------

vim.api.nvim_create_user_command("PKBSync",function()
  M.smart_sync()
end,{})

--------------------------------------------------
-- RETURN MODULE
--------------------------------------------------

return M
