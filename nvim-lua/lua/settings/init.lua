local id = vim.api.nvim_create_augroup("lua_file", {
    clear = false
})

local lua_file_setup = function(t)
--       • id: (number) the autocommand id
--       • event: (string) the name of the event that
--	 triggered the autocommand |autocmd-events|
--       • group: (number|nil) the autocommand group id,
--	 if it exists
--       • match: (string) the expanded value of
--	 |<amatch>|
--       • buf: (number) the expanded value of |<abuf>|
--       • file: (string) the expanded value of
--	 |<afile>|
--       • data: (any) arbitrary data passed to
--	 |nvim_exec_autocmds()|

--    vim.opt_local.foldmethod=marker
    vim.opt_local.tabstop=4
    vim.opt_local.shiftwidth=4
end

vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = {"*.lua"},
    callback = lua_file_setup,
    group = "lua_file",
})

