-- File: ~/.config/nvim/lua/sync_photos.lua
local M = {}

local function generate_dates(start_date, end_date)
  local dates = {}
  local pattern = "(%d+)-(%d+)-(%d+)"
  local y1, m1, d1 = start_date:match(pattern)
  local y2, m2, d2 = end_date:match(pattern)

  local start_time = os.time({ year = y1, month = m1, day = d1 })
  local end_time   = os.time({ year = y2, month = m2, day = d2 })

  local day_seconds = 86400
  local current = start_time

  while current <= end_time do
    table.insert(dates, os.date("%Y-%m-%d", current))
    current = current + day_seconds
  end

  return dates
end

local function run(cmd, opts)
  opts = opts or {}
  local result = vim.system(cmd, { text = true }):wait()

  if result.code ~= 0 then
    print("❌ Command failed:", table.concat(cmd, " "))
    print(result.stderr)
    return nil
  end

  return result.stdout
end

M.sync_photos = function(opts)
  print("🔌 Forwarding adb port 8022...")
  run({ "adb", "forward", "tcp:8022", "tcp:8022" })

  local home = vim.fn.expand("~")
  local localDir = home .. "/phone/photos/"
  local remoteUser = "user"
  local remoteHost = "localhost"
  local remotePort = "8022"
  local remotePhotosDir = "/data/data/com.termux/files/home/storage/dcim/Camera/"

  local dates = {}
  if #opts.fargs == 2 then
    dates = generate_dates(opts.fargs[1], opts.fargs[2])
  else
    table.insert(dates, os.date("%Y-%m-%d"))
  end

  for _, dateFolder in ipairs(dates) do
    print("\n📅 Processing " .. dateFolder)

    local destDir = localDir .. dateFolder .. "/"
    vim.fn.mkdir(destDir, "p")

    -- FIX: make paths relative to "/"
    local findCmd = {
      "ssh", "-p", remotePort, remoteUser .. "@" .. remoteHost,
      string.format(
        [[cd / && find %s -type f -newermt "%s 00:00:00" ! -newermt "%s 23:59:59" | sed 's|^/||']],
        remotePhotosDir, dateFolder, dateFolder
      )
    }

    print("🔍 Finding files...")
    local fileList = run(findCmd)

    if not fileList or fileList == "" then
      print("⚠️  No files found")
      goto continue
    end

    -- write temp file list
    local tmpFile = vim.fn.tempname()
    local f = io.open(tmpFile, "w")
    f:write(fileList)
    f:close()

    print("📦 Syncing files...")

    local rsyncCmd = {
      "rsync",
      "-avz",
      "--no-relative",
      "--files-from=" .. tmpFile,
      "-e", "ssh -p " .. remotePort,
      remoteUser .. "@" .. remoteHost .. ":/",
      destDir
    }

    local output = run(rsyncCmd)

    if output then
      print("✅ Transferred files:")

      -- parse rsync output (only actual files)
      for line in output:gmatch("[^\r\n]+") do
        if not line:match("^sending incremental file list") and
           not line:match("^sent ") and
           not line:match("^total size") and
           line ~= "" then
          print("  " .. line)
        end
      end
    end

    os.remove(tmpFile)

    ::continue::
  end

  print("\n🎉 Done.")
end

vim.api.nvim_create_user_command("SyncPhotos", M.sync_photos, {
  nargs = "*",
})

return M
