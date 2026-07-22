local M = {}

-- Last marked wiki reference
M.mark = nil

-- Returns the closest markdown heading above the cursor.
local function current_heading()
    local row = vim.api.nvim_win_get_cursor(0)[1]

    for lnum = row, 1, -1 do
        local line = vim.fn.getline(lnum)

        -- Match markdown headings (#, ##, ###, ...)
        local heading = line:match("^#+%s*(.+)$")
        if heading then
            return heading
        end
    end

    return nil
end

-- Mark the current file and heading.
function M.mark_location()
    local page = vim.fn.expand("%:t:r") -- filename without .md
    local heading = current_heading()

    if heading then
        M.mark = string.format("[[%s#%s]]", page, heading)
    else
        M.mark = string.format("[[%s]]", page)
    end

    vim.notify("Marked: " .. M.mark)
end

-- Insert the previously marked reference.
function M.insert_location()
    if not M.mark then
        vim.notify("No wiki reference marked!", vim.log.levels.WARN)
        return
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()

    local new_line =
        line:sub(1, col) ..
        M.mark ..
        line:sub(col + 1)

    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(0, { row, col + #M.mark })
end

-- Toggle:
-- If no mark exists, mark current location.
-- Otherwise insert it.
function M.toggle()
    if M.mark == nil then
        M.mark_location()
    else
        M.insert_location()
    end
end

vim.api.nvim_create_user_command("WikiMark", function()
    M.mark_location()
end, {})

vim.api.nvim_create_user_command("WikiInsert", function()
    M.insert_location()
end, {})

vim.api.nvim_create_user_command("WikiRef", function()
    M.toggle()
end, {})

vim.keymap.set("n", "<leader>wm", M.mark_location, {
    desc = "Mark current wiki location",
})

vim.keymap.set("n", "<leader>wi", M.insert_location, {
    desc = "Insert marked wiki reference",
})

vim.keymap.set("n", "<leader>wr", M.toggle, {
    desc = "Wiki ref toggle",
})

return M
