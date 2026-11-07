-- Local folder for arXiv PDFs, inside the PKB.
local PDF_DIR = vim.fn.expand(vim.env.PKB_ROOT or "~/pkb") .. "/papers/pdfs/"

vim.keymap.set("n", "<leader>ap", function()
  local text = vim.fn.expand("<cWORD>")

  -- try modern arXiv id
  local id = text:match("(%d+%.%d+v?%d*)")

  -- fallback: old archive/id format
  if not id then
    id = text:match("([%a%-]+/%d+v?%d*)")
  end

  if not id then
    vim.notify("Could not detect arXiv id", vim.log.levels.ERROR)
    return
  end

  local dir = PDF_DIR
  vim.fn.mkdir(dir, "p")

  local filepath = dir .. id:gsub("/", "_") .. ".pdf"
  local pdf_url = "https://arxiv.org/pdf/" .. id .. ".pdf"

  vim.fn.system("curl -L -o " .. filepath .. " " .. pdf_url)

  local line = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, line, line, false, { "filepath: [url](" .. filepath ..")"})

  vim.notify("Downloaded " .. id)
end)

vim.keymap.set("n", "<leader>aS", function() -- <leader>as is avante's "toggle suggestions"
  local local_dir = PDF_DIR
  local remote_dir = "~/pkb/papers/pdfs/" -- on the phone (Termux, over ssh), not this machine's $PKB_ROOT
  local remote = "user@localhost"
  local rsync_opts = "-avz --ignore-existing --partial -e 'ssh -p 8022'"

  -- ensure local directory exists
  vim.fn.mkdir(local_dir, "p")

  -- check adb device
  local devices = vim.fn.system("adb devices")
  if not devices:match("device") then
    vim.notify("No adb device connected", vim.log.levels.ERROR)
    return
  end

  -- forward port
  vim.fn.system("adb forward tcp:8022 tcp:8022")

  -- sync commands
  local cmd1 = "rsync " .. rsync_opts .. " " .. remote .. ":" .. remote_dir .. " " .. local_dir
  local cmd2 = "rsync " .. rsync_opts .. " " .. local_dir .. " " .. remote .. ":" .. remote_dir

  local r1 = vim.fn.system(cmd1)
  local r2 = vim.fn.system(cmd2)

  if vim.v.shell_error ~= 0 then
    vim.notify("PDF sync failed", vim.log.levels.ERROR)
    vim.cmd("split | terminal " .. cmd1 .. " && " .. cmd2)
  else
    vim.notify("PDF sync complete 📚")
  end
end)
