vim.pack.add({
    -- Telescope + dependency
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-telescope/telescope.nvim", version = "0.1.8" },

    -- Colorscheme
    { src = "https://github.com/sainnhe/everforest" },

    -- Git
    { src = "https://github.com/tpope/vim-fugitive" },

    -- Completion
    { src = "https://github.com/hrsh7th/nvim-cmp" },
    { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
    { src = "https://github.com/hrsh7th/cmp-buffer" },
    { src = "https://github.com/hrsh7th/cmp-path" },

    -- Snippets
    { src = "https://github.com/L3MON4D3/LuaSnip" },
    { src = "https://github.com/saadparwaiz1/cmp_luasnip" },
    { src = "https://github.com/rafamadriz/friendly-snippets" },

    -- Multi-cursor
    { src = "https://github.com/mg979/vim-visual-multi" },

    -- UI
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/BlakeJC94/alpha-nvim-fortune" },
    { src = "https://github.com/goolord/alpha-nvim" },

    -- Misc
    { src = "https://github.com/ettaka/vim-elmer" },

    -- Statusline
    { src = "https://github.com/nvim-lualine/lualine.nvim" },

    -- Debugging
    { src = "https://github.com/mfussenegger/nvim-dap" },
    { src = "https://github.com/nvim-neotest/nvim-nio" },
    { src = "https://github.com/rcarriga/nvim-dap-ui" },

    -- Notes
    { src = "https://github.com/renerocksai/telekasten.nvim" },

    -- File explorer
    { src = "https://github.com/stevearc/oil.nvim" },

    -- Tables
    { src = "https://github.com/dhruvasagar/vim-table-mode" },
})

vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  {
    src = 'https://github.com/yetone/avante.nvim', -- need to run `cd "$(find ~/.local/share/nvim -type d -name "avante.nvim" 2>/dev/null | head -n 1)" && make` to install avante binary
  },
})

vim.pack.add({
      "https://github.com/ettaka/pkb-nvim",
      "https://github.com/ettaka/calendar-nvim",
})
require("calendar").setup({
  get_tasks_duration = require("pkb.effort_calculation").get_tasks_duration,
})

-- =========================
-- CONFIGURATION (AFTER LOAD)
-- =========================

-- Configure render-markdown
require('render-markdown').setup({
  file_types = { "markdown", "Avante" },
})

-- Colorscheme
vim.g.everforest_background = "medium"
vim.g.everforest_enable_italic = 1
vim.cmd.colorscheme("everforest")

-- Oil
require("oil").setup()

-- Lualine
require("lualine").setup()

-- DAP UI
require("dapui").setup()

-- nvim-web-devicons
require('nvim-web-devicons').setup({
  default = true,
})

