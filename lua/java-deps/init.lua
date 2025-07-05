-- lua/java-deps/init.lua

local jdtls = require("java-deps.jdtls")
local picker = require("java-deps.picker")

local M = {}

function M.setup()
end

function M.view()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  local jdtls_client
  for _, client in ipairs(clients) do
    if client.name == "jdtls" then
      jdtls_client = client
      break
    end
  end

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