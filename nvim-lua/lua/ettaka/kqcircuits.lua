-- KQCircuits checkout: $KQC (set in zsh/set_kqcircuits.sh), else ~/git/KQCircuits
local KQC = vim.env.KQC or vim.fn.expand("~/git/KQCircuits")

local function KQC_simulate_current_file()
    local file = vim.fn.expand('%')
    local enter_key = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
    local cmd = "ikqc simulate "..file..enter_key
    vim.cmd("sp")
    vim.cmd("te")
    vim.api.nvim_feedkeys(cmd, "i", true)
end

local function KQC_run_current_file()
    local file = vim.fn.expand('%')
    local enter_key = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
    local cmd = "iklayout -z -r "..file..enter_key
    vim.cmd("sp")
    vim.cmd("te")
    vim.api.nvim_feedkeys(cmd, "i", true)
end

local function KQC_open_element()
    local file = vim.fn.expand('%')
    local enter_key = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
    local cmd = "iklayout -e -rm "..KQC.."/util/create_element_from_path.py -rd element_path="..file..enter_key.."exit"
--    klayout -e -rm {FULL PATH TO create_element_from_path.py} -rd element_path="
    vim.cmd("sp")
    vim.cmd("te")
    vim.api.nvim_feedkeys(cmd, "i", true)
end

vim.keymap.set("n", "<leader>kl", KQC_open_element)
vim.keymap.set("n", "<leader>ks", KQC_simulate_current_file, { desc = "KQC: simulate current file" }) -- <leader><space> is the floating terminal
vim.keymap.set("n", "<leader><enter>", KQC_run_current_file)
