-- ~/.config/nvim/lua/takepicture.lua
local M = {}

-- date helpers
local function today_file()
  return os.date("%Y%m%d")     -- for filenames
end

local function today_dir()
  return os.date("%Y-%m-%d")   -- for folders
end

local function take_photo()
  -- wake device
  vim.fn.jobstart({"adb","shell","input","keyevent","KEYCODE_WAKEUP"}, {detach=true})

  -- dismiss keyguard shortly after
  vim.defer_fn(function()
    vim.fn.jobstart({"adb","shell","wm","dismiss-keyguard"}, {detach=true})
  end, 300)

  -- launch camera after keyguard is dismissed
  vim.defer_fn(function()
    vim.fn.jobstart({
      "adb","shell","am","start","-a","android.media.action.STILL_IMAGE_CAMERA"
    }, {detach=true})
  end, 600)

  -- take photo after camera app is fully ready
  vim.defer_fn(function()
    vim.fn.jobstart({"adb","shell","input","keyevent","KEYCODE_CAMERA"}, {detach=true})
  end, 1500)  -- ~1.5 seconds after launch
end

function M.sync_photos()
  local dest = vim.fn.expand("~/conference_photos/" .. today_dir() .. "/")
  vim.fn.mkdir(dest, "p")

  vim.fn.jobstart({
    "rsync","-az",
    "-e","ssh -p 8022",
    "--include=*/",
    "--include=" .. os.date("%Y%m%d") .. "*.jpg",
    "--exclude=*",
    "user@localhost:/sdcard/DCIM/Camera/",
    dest
  }, {detach=true})
end

function M.take_picture()
  -- insert marker
  vim.api.nvim_put({"picture::" .. os.date("%Y-%m-%dT%H:%M") .. require'calendar'.local_tz_suffix()}, "c", true, true)

  -- take photo
  take_photo()

  -- sync after phone saves image
  vim.defer_fn(M.sync_photos, 1500)
end

function M.setup()
  vim.api.nvim_create_user_command("TakePicture", M.take_picture, {})
end

return M
