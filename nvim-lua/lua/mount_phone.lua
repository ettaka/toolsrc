local M = {}

--------------------------------------------------
-- CONFIG
--------------------------------------------------

M.mountpoint = vim.fn.expand("~/phone")
M.mount_cmd  = "jmtpfs"
M.unmount_cmd = "fusermount -u"

--------------------------------------------------
-- helpers
--------------------------------------------------

local function notify(msg, lvl)
  vim.notify(msg, lvl or vim.log.levels.INFO)
end

local function system(cmd)
  local ok = os.execute(cmd)
  return ok == true or ok == 0
end

--------------------------------------------------
-- state check
--------------------------------------------------

function M.is_mounted()
  local check = "mount | grep -q '"..M.mountpoint.."'"
  return system(check)
end

--------------------------------------------------
-- mount
--------------------------------------------------

function M.mount()
  if M.is_mounted() then
    notify("Phone already mounted ✓")
    return true
  end

  notify("Mounting phone…")

  local cmd = string.format(
    "%s '%s'",
    M.mount_cmd,
    M.mountpoint
  )

  if system(cmd) then
    notify("Mounted ✓")
    return true
  else
    notify("Mount failed!", vim.log.levels.ERROR)
    return false
  end
end

--------------------------------------------------
-- unmount
--------------------------------------------------

function M.unmount()
  if not M.is_mounted() then
    notify("Already unmounted")
    return
  end

  notify("Unmounting phone…")

  local cmd = string.format(
    "%s '%s'",
    M.unmount_cmd,
    M.mountpoint
  )

  system(cmd)
  notify("Unmounted ✓")
end

--------------------------------------------------
-- toggle
--------------------------------------------------

function M.toggle()
  if M.is_mounted() then
    M.unmount()
  else
    M.mount()
  end
end

--------------------------------------------------
-- status
--------------------------------------------------

function M.status()
  if M.is_mounted() then
    notify("Phone mounted ✓")
  else
    notify("Phone NOT mounted", vim.log.levels.WARN)
  end
end

--------------------------------------------------
-- commands
--------------------------------------------------

vim.api.nvim_create_user_command(
  "PhoneMount",
  function() require("mount_phone").mount() end,
  {}
)

vim.api.nvim_create_user_command(
  "PhoneUnmount",
  function() require("mount_phone").unmount() end,
  {}
)

vim.api.nvim_create_user_command(
  "PhoneToggle",
  function() require("mount_phone").toggle() end,
  {}
)

vim.api.nvim_create_user_command(
  "PhoneStatus",
  function() require("mount_phone").status() end,
  {}
)

return M

