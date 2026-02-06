return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'mfussenegger/nvim-dap-python',
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio', -- required by dap-ui
      'theHamsta/nvim-dap-virtual-text', -- optional, but great
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      require('mason').setup()

      -- Installs DAP adapters via Mason; "python" maps to the "debugpy" package :contentReference[oaicite:4]{index=4}
      require('mason-nvim-dap').setup {
        ensure_installed = { 'python' },
        automatic_installation = true,
      }

      dapui.setup() -- UI layout/panels :contentReference[oaicite:5]{index=5}
      require('nvim-dap-virtual-text').setup()

      -- Auto-open/close the UI when debugging starts/stops
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      --dap.listeners.before.event_terminated['dapui_config'] = function()
      --  dapui.close()
      --end
      --dap.listeners.before.event_exited['dapui_config'] = function()
      --  dapui.close()
      --end

      -- Use Mason's debugpy venv for the adapter
      -- (this python must be able to run: python -m debugpy --version) :contentReference[oaicite:6]{index=6}
      local mason_py = vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python'
      require('dap-python').setup(mason_py)

      -- Launch your code with your *project* venv if available (otherwise python3)
      -- nvim-dap-python will also try to auto-detect common venvs :contentReference[oaicite:7]{index=7}
      require('dap-python').resolve_python = function()
        local venv = os.getenv 'VIRTUAL_ENV'
        if venv then
          return venv .. '/bin/python'
        end

        local conda = os.getenv 'CONDA_PREFIX'
        if conda then
          return conda .. '/bin/python'
        end

        local cwd = vim.fn.getcwd()
        for _, dir in ipairs { 'venv', '.venv', 'env', '.env' } do
          local p = cwd .. '/' .. dir .. '/bin/python'
          if vim.fn.executable(p) == 1 then
            return p
          end
        end

        return 'python3'
      end

      -- Keymaps (change to taste)
      local map = vim.keymap.set
      map('n', '<F4>', function()
        dap.close()
        dapui.close()
      end)
      map('n', '<F5>', function()
        dap.continue()
      end)
      map('n', '<F10>', function()
        dap.step_over()
      end)
      map('n', '<F11>', function()
        dap.step_into()
      end)
      map('n', '<F12>', function()
        dap.step_out()
      end)
      map('n', '<leader>b', function()
        dap.toggle_breakpoint()
      end)
      map('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end)
      map('n', '<leader>dr', function()
        dap.repl.open()
      end)
      map('n', '<leader>dl', function()
        dap.run_last()
      end)
      map('n', '<leader>du', function()
        dapui.toggle()
      end)

      -- Python test debugging helpers :contentReference[oaicite:8]{index=8}
      map('n', '<leader>dt', function()
        require('dap-python').test_method()
      end)
      map('n', '<leader>dT', function()
        require('dap-python').test_class()
      end)
      map('v', '<leader>ds', function()
        require('dap-python').debug_selection()
      end)
    end,
  },
}
