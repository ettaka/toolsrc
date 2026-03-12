vim.keymap.set("n", "<leader>ap", function()
  local url = vim.fn.expand("<cWORD>")
  local id = url:match("arxiv.org/%a+/(%d+%.%d+v%d+)") or url

  if not id then
    print("Could not detect arXiv id")
    return
  end

  local dir = vim.fn.expand("~/pkb/papers/pdfs/")
  vim.fn.mkdir(dir, "p")

  local filepath = dir .. id .. ".pdf"
  local pdf_url = "https://arxiv.org/pdf/" .. id .. ".pdf"

  -- download pdf
  vim.fn.system("curl -L -o " .. filepath .. " " .. pdf_url)

  -- insert new line with path
  local line = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, line, line, false, { "filepath: [url](" .. filepath .. ")" })

  print("Downloaded: " .. filepath)
end)
