return require'packer'.startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  
  -- Color schemes
  use 'EdenEast/nightfox.nvim'

  -- Dev icons
  use 'kyazdani42/nvim-web-devicons'

  -- Tree
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icon
    },
    tag = 'nightly' -- optional, updated every week. (see issue #1193)
  }
end)
