-- lua/java-deps/init.lua

-- This is the main entry point for the plugin.
-- 这是插件的主入口点。

local jdtls = require("java-deps.jdtls")
local picker = require("java-deps.picker")

local M = {}

-- The setup function for the plugin.
-- 插件的设置函数。
function M.setup()
end

-- The function to show the dependency view.
-- 显示依赖视图的函数。
function M.view()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ name = "jdtls", bufnr })
  local jdtls_client = clients[1]

  if not jdtls_client then
    vim.notify("jdtls is not running.", vim.log.levels.ERROR)
    return
  end

  local root_dir = jdtls_client.root_dir
  if not root_dir then
    vim.notify("Could not determine project root directory from jdtls.", vim.log.levels.ERROR)
    return
  end

  jdtls.get_projects(bufnr, root_dir, function(projects)
    if projects and #projects > 0 then
      picker.show(projects, bufnr)
    else
      vim.notify("No Java projects found in this workspace.", vim.log.levels.WARN)
    end
  end)
end

return M
