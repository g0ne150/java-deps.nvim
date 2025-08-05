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
  while current and current:get_kind() ~= NodeKind.PackageRoot and current:get_kind() ~= NodeKind.Project do
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
    node_data.rootPath = root_node:get_path()
    node_data.handlerIdentifier = root_node:get_handler_identifier()
  end

  jdtls.get_children(self:get_project_uri(), node_data, callback)
end

return FolderNode

