function KQC_simulate_current_file()
    local file = vim.fn.expand('%')
    local enter_key = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
    local cmd = "ikqc simulate "..file..enter_key
    vim.cmd("sp")
    vim.cmd("te")
    vim.api.nvim_feedkeys(cmd, "i", true)
end

function KQC_run_current_file()
    local file = vim.fn.expand('%')
    local enter_key = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
    local cmd = "iklayout -z -r "..file..enter_key
    vim.cmd("sp")
    vim.cmd("te")
    vim.api.nvim_feedkeys(cmd, "i", true)
end

function KQC_open_element()
    local file = vim.fn.expand('%')
    local enter_key = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
    local cmd = "iklayout -e -rm /home/eelis/git/KQCircuits/util/create_element_from_path.py -rd element_path="..file..enter_key.."exit"
--    klayout -e -rm {FULL PATH TO create_element_from_path.py} -rd element_path="
    vim.cmd("sp")
    vim.cmd("te")
    vim.api.nvim_feedkeys(cmd, "i", true)
end

vim.keymap.set("n", "<leader>kl", KQC_open_element)
vim.keymap.set("n", "<leader><space>", KQC_simulate_current_file)
vim.keymap.set("n", "<leader><enter>", KQC_run_current_file)
