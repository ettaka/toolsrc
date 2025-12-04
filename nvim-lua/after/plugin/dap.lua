-- Utility: get path to python inside conda env
local function get_conda_python(env_name)
    local handle = io.popen("conda run -n " .. env_name .. " which python")
    if not handle then
        return nil
    end
    local result = handle:read("*a")
    handle:close()
    return vim.fn.trim(result)
end

local env = "kqcircuits"
-- local python_path = get_conda_python(env)

local dap = require('dap')
dap.adapters.python = function(cb, config)
  if config.request == 'attach' then
    ---@diagnostic disable-next-line: undefined-field
    local port = (config.connect or config).port
    ---@diagnostic disable-next-line: undefined-field
    local host = (config.connect or config).host or '127.0.0.1'
    cb({
      type = 'server',
      port = assert(port, '`connect.port` is required for a python `attach` configuration'),
      host = host,
      options = {
        source_filetype = 'python',
      },
    })
  else
    cb({
      type = 'executable',
      command = get_conda_python(env),
      args = { '-m', 'debugpy.adapter' },
      options = {
        source_filetype = 'python',
      },
    })
  end
end

dap.configurations.python = {
  {
    -- The first three options are required by nvim-dap
    type = 'python'; -- the type here established the link to the adapter definition: `dap.adapters.python`
    request = 'launch';
    name = "Launch file";

    -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

    program = "${file}"; -- This configuration will launch the current file if used.
    pythonPath = function()
      -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
      -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
      -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
      return get_conda_python(env)
    end;
  },
}

dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
}

dap.configurations.fortran = {
  {
    name = "Run Fortran program",
    type = "gdb",
    request = "launch",
    program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/a.out", "file")
    end,
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
  }
}

local dap = require("dap")
local dapui = require("dapui")

-- F-keys (universal)
vim.keymap.set("n", "<F4>", function()
  vim.cmd("!gfortran -g " .. vim.api.nvim_buf_get_name(0))
end)

vim.keymap.set("n", "<F5>", dap.continue)
vim.keymap.set("n", "<F10>", dap.step_over)
vim.keymap.set("n", "<F11>", dap.step_into)
vim.keymap.set("n", "<F12>", dap.step_out)

-- Breakpoints
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>B", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end)

-- Leader-d namespace
vim.keymap.set("n", "<leader>dc", dap.continue)
vim.keymap.set("n", "<leader>dr", dap.repl.open)
vim.keymap.set("n", "<leader>dl", dap.run_last)
vim.keymap.set("n", "<leader>do", dap.step_over)
vim.keymap.set("n", "<leader>di", dap.step_into)
vim.keymap.set("n", "<leader>dO", dap.step_out)
vim.keymap.set("n", "<leader>ds", dap.terminate)

-- UI
vim.keymap.set("n", "<leader>du", dapui.toggle)
vim.keymap.set("n", "<leader>de", dapui.eval)
