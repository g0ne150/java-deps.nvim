-- lua/java-deps/nodes/folder_node.lua

-- Folder node class that handles folder-type nodes
-- 文件夹节点类，处理文件夹类型的节点

local BaseNode = require("java-deps.nodes.base_node")
local NodeKind = require("java-deps.node_kind").NodeKind
local jdtls = require("java-deps.jdtls")

local FolderNode = setmetatable({}, { __index = BaseNode })
FolderNode.__index = FolderNode

function FolderNode:new(node_data, parent)
  local instance = BaseNode:new(node_data, parent)
  setmetatable(instance, self)
  return instance
end

-- Get the root node for this folder (traverse up the hierarchy until we find a PackageRoot or Project)
-- 获取此文件夹的根节点（向上遍历层次结构直到找到PackageRoot或Project）
function FolderNode:get_root_node()
  local current = self.parent
  while current do
    -- Check if current is a table with a kind field or a node object with get_kind method
    -- 检查current是具有kind字段的表还是具有get_kind方法的节点对象
    local kind = nil
    if type(current.get_kind) == "function" then
      kind = current:get_kind()
    elseif current.node_data and current.node_data.kind then
      kind = current.node_data.kind
    elseif current.kind then
      kind = current.kind
    else
      break
    end

    if kind == NodeKind.PackageRoot or kind == NodeKind.Project then
      return current
    end
    current = current.parent
  end
  return current
end

-- Get children of the folder node
-- 获取文件夹节点的子节点
function FolderNode:get_children(callback)
  -- For folder nodes, we need to pass the rootPath and handlerIdentifier from the root node
  -- 对于文件夹节点，我们需要从根节点传递rootPath和handlerIdentifier
  local node_data = vim.deepcopy(self.node_data)
  local root_node = self:get_root_node()

  if root_node then
    -- Get rootPath and handlerIdentifier from the root node
    -- 从根节点获取rootPath和handlerIdentifier
    if type(root_node.get_path) == "function" then
      node_data.rootPath = root_node:get_path()
    elseif root_node.node_data and root_node.node_data.path then
      node_data.rootPath = root_node.node_data.path
    elseif root_node.path then
      node_data.rootPath = root_node.path
    end

    if type(root_node.get_handler_identifier) == "function" then
      node_data.handlerIdentifier = root_node:get_handler_identifier()
    elseif root_node.node_data and root_node.node_data.handlerIdentifier then
      node_data.handlerIdentifier = root_node.node_data.handlerIdentifier
    elseif root_node.handlerIdentifier then
      node_data.handlerIdentifier = root_node.handlerIdentifier
    end
  end

  jdtls.get_children(self:get_project_uri(), node_data, callback)
end

return FolderNode
