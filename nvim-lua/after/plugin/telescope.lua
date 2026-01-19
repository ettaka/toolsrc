local function git_root()
  local dot_git_path = vim.fn.finddir('.git', '.;')
  if dot_git_path == '' then
    return vim.fn.getcwd()
  end
  return vim.fn.fnamemodify(dot_git_path, ':h')
end

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', function()
  builtin.find_files({ cwd = git_root() })
end)
vim.keymap.set('n', '<leader>fg', function()
  builtin.live_grep({ cwd = git_root() })
end)
vim.keymap.set('n', '<leader>fb', function()
  builtin.buffers({ cwd = git_root() })
end)
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

require('telescope').setup{
  defaults = { mappings = { i = { ["<CR>"] = require('telescope.actions').select_default } } }
}

