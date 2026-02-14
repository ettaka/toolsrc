vim.keymap.set("n","<leader>zm",function()
  require("mount_phone").toggle()
end,{desc="Toggle phone mount"})
