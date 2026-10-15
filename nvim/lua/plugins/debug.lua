return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "mfussenegger/nvim-dap-python",
    },
    keys = {
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "Debug continue",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "Debug step over",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "Debug step into",
      },
      {
        "<F12>",
        function()
          require("dap").step_out()
        end,
        desc = "Debug step out",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle breakpoint",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Toggle debug UI",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.open()
        end,
        desc = "Debug REPL",
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()

      local lldb_dap = vim.fn.exepath("lldb-dap")
      if lldb_dap == "" and vim.fn.executable("/opt/homebrew/opt/lldb/bin/lldb-dap") == 1 then
        lldb_dap = "/opt/homebrew/opt/lldb/bin/lldb-dap"
      end
      dap.adapters.lldb = {
        type = "executable",
        command = lldb_dap ~= "" and lldb_dap or "lldb-dap",
        name = "lldb",
      }
      dap.configurations.cpp = {
        {
          name = "Launch executable",
          type = "lldb",
          request = "launch",
          program = function()
            return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
      dap.configurations.c = dap.configurations.cpp
      dap.configurations.asm = dap.configurations.cpp

      local data_home = vim.env.XDG_DATA_HOME or vim.fn.expand("~/.local/share")
      local managed_python = data_home .. "/nvim-dev-config/debugpy/bin/python"
      local python = vim.fn.executable(managed_python) == 1 and managed_python or vim.fn.exepath("python3")
      if python ~= "" then
        require("dap-python").setup(python)
      end

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
}
