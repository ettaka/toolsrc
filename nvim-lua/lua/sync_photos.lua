-- File: ~/.config/nvim/lua/sync_photos.lua
local M = {}

local function generate_dates(start_date, end_date)
    local dates = {}
    local pattern = "(%d+)-(%d+)-(%d+)"
    local y1, m1, d1 = start_date:match(pattern)
    local y2, m2, d2 = end_date:match(pattern)

    local start_time = os.time({year=y1, month=m1, day=d1})
    local end_time = os.time({year=y2, month=m2, day=d2})

    local day_seconds = 24*60*60
    local current = start_time

    while current <= end_time do
        table.insert(dates, os.date("%Y-%m-%d", current))
        current = current + day_seconds
    end

    return dates
end

-- Main sync function
M.sync_photos = function(opts)
    print("Forwarding adb port 8022...")
    os.execute("adb forward tcp:8022 tcp:8022")

    local home = vim.fn.expand("~")
    local localDir = home .. "/phone/photos/"
    local remoteUser = "user"          -- change to your phone SSH username
    local remoteHost = "127.0.0.1"
    local remotePort = "8022"
    local remotePhotosDir = "/data/data/com.termux/files/home/storage/DCIM/Camera/"

    local dates = {}
    if #opts.fargs == 2 then
        dates = generate_dates(opts.fargs[1], opts.fargs[2])
    else
        table.insert(dates, os.date("%Y-%m-%d"))
    end

    for _, dateFolder in ipairs(dates) do
        local destDir = localDir .. dateFolder .. "/"
        os.execute("mkdir -p " .. destDir)

        -- Remote find photos matching date in YYYY-MM-DD
        local findCmd = string.format(
            [[ssh -p %s %s@%s 'find %s -type f -newermt "%s 00:00:00" ! -newermt "%s 23:59:59"']],
            remotePort, remoteUser, remoteHost, remotePhotosDir, dateFolder, dateFolder
        )

        print("Finding photos for date " .. dateFolder .. "...")
        local handle = io.popen(findCmd)
        local fileList = handle:read("*a")
        handle:close()

        if fileList == "" then
            print("No photos found for " .. dateFolder)
        else
            -- Write file list to temporary file
            local tmpFile = os.tmpname()
            local f = io.open(tmpFile, "w")
            f:write(fileList)
            f:close()

            -- Rsync only files from list
            local rsyncCmd = string.format(
                'rsync -avz -e "ssh -p %s" --files-from=%s %s@%s:/ %s',
                remotePort, tmpFile, remoteUser, remoteHost, destDir
            )

            print("Syncing photos for " .. dateFolder .. "...")
            os.execute(rsyncCmd)
            os.remove(tmpFile)
            print("Photos for " .. dateFolder .. " synced to " .. destDir)
        end
    end
end

vim.api.nvim_create_user_command(
    "SyncPhotos",
    M.sync_photos,
    { nargs = "*", complete = "file" }
)

return M
