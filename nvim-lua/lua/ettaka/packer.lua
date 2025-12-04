vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    use 'ellisonleao/gruvbox.nvim'
    use 'mbbill/undotree'
    use 'tpope/vim-fugitive'
    -- LSP: built-in client (no plugin needed)
    -- Completion plugins:
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'

    -- Snippets
    use 'L3MON4D3/LuaSnip'
    use 'saadparwaiz1/cmp_luasnip'
    use 'rafamadriz/friendly-snippets'

    use 'mg979/vim-visual-multi'
    use {
        'goolord/alpha-nvim',
        requires = {
            {'nvim-tree/nvim-web-devicons'},
            {'BlakeJC94/alpha-nvim-fortune'},
        },
    }

    use 'ettaka/vim-elmer'
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }
    use 'mfussenegger/nvim-dap'
    use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} }
end)
