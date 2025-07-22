-- lua/java-deps/jdtls.lua

-- This module encapsulates all communication with the jdtls language server.
-- 该模块封装了所有与 jdtls 语言服务器的通信。

local NodeKind = require("java-deps.node_kind")

local M = {}

---@return vim.lsp.Client|nil
function M.get_jdtls_client()
  local clients = vim.lsp.get_clients({ name = "jdtls" })
  if not clients or #clients <= 0 then
    vim.notify("No avaliable running jdtls client", vim.log.levels.WARN)
    return nil
  end
  return clients[1]
end

-- Get the list of Java projects in the workspace.
-- 获取工作区中的 Java 项目列表。
function M.get_projects(callback)
  local jdtls_client = M.get_jdtls_client()
  if not jdtls_client then
    return
  end
  local params = {
    command = "java.project.list",
    -- The second argument 'true' corresponds to the 'filterNonJava' parameter.
    arguments = { vim.uri_from_fname(jdtls_client.root_dir), false },
  }
  jdtls_client:request("workspace/executeCommand", params, function(err, result)
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
local function get_node_children(params, callback)
  local command_params = {
    command = "java.getPackageData",
    arguments = { params },
  }
  M.get_jdtls_client():request("workspace/executeCommand", command_params, function(err, result)
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
function M.get_children(project_uri, node, callback)
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

  get_node_children(params, callback)
end

-- Resolve a file path using jdtls.
-- 使用 jdtls 解析文件路径。
function M.resolve_path(uri, callback)
  local params = {
    command = "java.resolvePath",
    arguments = { uri },
  }
  M.get_jdtls_client():request("workspace/executeCommand", params, function(err, result)
    if err then
      vim.notify("Error resolving path: " .. vim.inspect(err), vim.log.levels.ERROR)
      callback(nil)
    else
      callback(result)
    end
  end)
end

return M
