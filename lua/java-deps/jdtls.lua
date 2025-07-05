-- lua/java-deps/jdtls.lua

local NodeKind = require("java-deps.node_kind")

local M = {}

function M.get_projects(bufnr, root_dir, callback)
  local params = {
    command = "java.project.list",
    arguments = { vim.uri_from_fname(root_dir) },
  }
  vim.lsp.buf_request(bufnr, "workspace/executeCommand", params, function(err, result)
    if err then
      vim.notify("Error getting Java projects: " .. vim.inspect(err), vim.log.levels.ERROR)
      callback(nil)
    else
      callback(result)
    end
  end)
end

function M.get_children(bufnr, project_uri, node, callback)
  local params = {
    projectUri = project_uri,
    kind = node.kind,
    path = node.path,
    handlerIdentifier = node.handlerIdentifier,
  }
  if node.kind == NodeKind.Project then
    params.kind = NodeKind.Project
  end
  local command_params = {
    command = "java.getPackageData",
    arguments = { params },
  }
  vim.lsp.buf_request(bufnr, "workspace/executeCommand", command_params, function(err, result)
    if err then
      vim.notify("Error getting node children: " .. vim.inspect(err), vim.log.levels.ERROR)
      callback(nil)
    else
      callback(result)
    end
  end)
end

return M