-- lua/java-deps/jdtls.lua

-- This module encapsulates all communication with the jdtls language server.
-- 该模块封装了所有与 jdtls 语言服务器的通信。

local NodeKind = require("java-deps.node_kind")

local M = {}

-- Get the list of Java projects in the workspace.
-- 获取工作区中的 Java 项目列表。
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

-- Private function to execute the java.getPackageData command.
-- 执行 java.getPackageData 命令的私有函数。
local function get_node_children(bufnr, params, callback)
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

-- Get the children of a node.
-- 获取节点的子节点。
function M.get_children(bufnr, project_uri, node, callback)
  local params = {
    projectUri = project_uri,
    kind = node.kind,
    handlerIdentifier = node.handlerIdentifier,
  }

  if node.kind == NodeKind.Package then
    params.path = node.name
  else
    params.path = node.path
  end

  if node.kind == NodeKind.Project then
    params.kind = NodeKind.Project
  end

  get_node_children(bufnr, params, callback)
end

return M
