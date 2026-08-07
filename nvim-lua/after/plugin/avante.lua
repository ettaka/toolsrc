require('avante').setup({
  provider = "gemini",
  providers = {
    gemini = {
--      model = "gemini-3.6-flash", -- Gemini 3.6 Flash workhorse model
      model = "gemini-3.5-flash-lite", -- Temporary swap while 3.6 Flash quota resets
      timeout = 30000,
      disable_tools = true, -- Disables background tool loops for fast, direct text answers
    },
  },

-- Override Avante's default prompt to strip out all tool/completion references
  system_prompt = [[
  You are an expert Neovim Lua developer.
  Provide direct markdown responses and code snippets only.
  DO NOT use tools, DO NOT use write_todos, and DO NOT use attempt_completion. 
  Answer the user's prompt directly and concisely.
  ]],

  mappings = {
    --- Custom global shortcuts
    ask = "<leader>aa",      -- Open ask chat window
    edit = "<leader>ae",     -- Edit selected text in visual mode
    refresh = "<leader>ar",  -- Refresh sidebar response
    focus = "<leader>af",    -- Switch focus to/from sidebar
    toggle = {
      default = "<leader>at", -- Toggle sidebar visibility
      debug = "<leader>ad",   -- Toggle debug mode
      hint = "<leader>ah",    -- Toggle hints
      suggestion = "<leader>as", -- Toggle auto-suggestions
      repomap = "<leader>aR", -- Toggle repository map
    },
    
    --- Diff mode mappings
    diff = {
      ours = "co",
      theirs = "ct",
      all_theirs = "ca",
      both = "cb",
      cursor = "cc",
      next = "]x",
      prev = "[x",
    },

    --- Prompt input box keymaps
    submit = {
      normal = "<CR>",  -- Send message in normal mode
      insert = "<C-s>", -- Send message in insert mode
    },

    --- Sidebar navigation
    sidebar = {
      apply_all = "A",
      apply_cursor = "a",
      switch_windows = "<Tab>",
      reverse_switch_windows = "<S-Tab>",
      remove_file = "d",
      add_file = "@",
      close = "q",
    },
  },
})
