-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = false

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'

  -- Choose a clipboard backend that works everywhere, including inside containers
  -- such as the `sbx` Docker sandbox, where there is no usable native clipboard.
  -- A clipboard binary being installed isn't enough: containers often ship `xclip`
  -- with no X server (`$DISPLAY` empty), or set `$WAYLAND_DISPLAY` with no
  -- `wl-copy`, so the tool exists but silently fails. Only treat a provider as
  -- usable when its binary AND its display are both present. Otherwise fall back
  -- to OSC 52, which sends the yanked text to the terminal emulator as an escape
  -- sequence so it reaches the real system clipboard across the sandbox boundary.
  local function has(bin)
    return vim.fn.executable(bin) == 1
  end
  local function nonempty(name)
    local v = vim.env[name]
    return v ~= nil and v ~= ''
  end
  local has_native = has 'pbcopy' -- macOS
    or (nonempty 'WAYLAND_DISPLAY' and has 'wl-copy') -- Wayland
    or (nonempty 'DISPLAY' and (has 'xclip' or has 'xsel')) -- X11

  if not has_native then
    local osc52 = require 'vim.ui.clipboard.osc52'
    vim.g.clipboard = {
      name = 'OSC 52',
      copy = {
        ['+'] = osc52.copy '+',
        ['*'] = osc52.copy '*',
      },
      -- Many terminals only support OSC 52 writes, not reads, and a read attempt
      -- can hang waiting for a response. Paste from Neovim's own register instead
      -- so `p` still works predictably; use Cmd+V to paste the OS clipboard into
      -- the terminal.
      paste = {
        ['+'] = function()
          return { vim.split(vim.fn.getreg '"', '\n'), vim.fn.getregtype '"' }
        end,
        ['*'] = function()
          return { vim.split(vim.fn.getreg '"', '\n'), vim.fn.getregtype '"' }
        end,
      },
    }
  end
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.softtabstop = 2

vim.g.python3_host_prog = '/Users/mkilgore/.pyenv/versions/3.11.x/bin/python3'
