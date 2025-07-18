-- lua/java-deps/init.lua

-- This is the main entry point for the plugin.
-- 这是插件的主入口点。

local jdtls = require("java-deps.jdtls")
local picker = require("java-deps.picker")

local M = {}

-- The setup function for the plugin.
-- 插件的设置函数。
function M.setup() end

-- The function to show the dependency view.
-- 显示依赖视图的函数。
function M.view()
  jdtls.get_projects(function(projects)
    if projects and #projects > 0 then
      picker.show(projects)
    else
      vim.notify("No Java projects found in this workspace.", vim.log.levels.WARN)
    end
  end)
end

return M
