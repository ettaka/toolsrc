-- Extend LSP capabilities for nvim-cmp autocomplete
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Define Pyright configuration
vim.lsp.config['pyright'] = {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  capabilities = capabilities,

  root_markers = {
    { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt' },
    '.git',
  },

  settings = {
    python = {
    pythonPath = "/home/eelis/miniconda3/envs/kqcircuits/bin/python",
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,  -- make Pyright search sys.path automatically
        useLibraryCodeForTypes = true,
      },
    },
  },
}

-- Enable the server
vim.lsp.enable('pyright')

-- Define FortLS configuration
vim.lsp.config['fortls'] = {
  cmd = { 'fortls' },
  filetypes = { 'fortran' },
  capabilities = capabilities,

  root_markers = {
    { '.fortls', 'CMakeLists.txt', 'Makefile' },
    '.git',
  },

  settings = {
    fortls = {
      -- General behavior
      incremental_sync = true,
      debounce_text_changes = 150,

      -- Diagnostics
      disable_diagnostics = false,
      max_line_length = 132,

      -- Code intelligence
      autocomplete = true,
      hover_signature = true,
      use_signature_help = true,

      -- Project parsing
      source_dirs = { '.' },
      include_dirs = { '.' },

      -- Formatting (optional)
      enable_code_actions = true,
    },
  },
}

-- Enable the server
vim.lsp.enable('fortls')

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    -- LSP-capable buffer
    local buf = ev.buf
    local opts = { buffer = buf, silent = true, noremap = true }

    -- Common LSP keymaps
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})


-- lsp.setup()

