-- lua/java-deps/nodes/node_factory.lua

-- Node factory that creates the appropriate node type based on the node data
-- 节点工厂，根据节点数据创建适当的节点类型

local BaseNode = require("java-deps.nodes.base_node")
local ContainerNode = require("java-deps.nodes.container_node")
local FolderNode = require("java-deps.nodes.folder_node")
local PackageNode = require("java-deps.nodes.package_node")
local PackageRootNode = require("java-deps.nodes.package_root_node")
local ProjectNode = require("java-deps.nodes.project_node")
local NodeKind = require("java-deps.node_kind").NodeKind

local NodeFactory = {}

-- Create a node of the appropriate type based on its kind
-- 根据节点类型创建适当类型的节点
function NodeFactory.create_node(node_data, parent)
  if node_data.kind == NodeKind.Project then
    return ProjectNode:new(node_data, parent)
  elseif node_data.kind == NodeKind.PackageRoot then
    return PackageRootNode:new(node_data, parent)
  elseif node_data.kind == NodeKind.Folder then
    return FolderNode:new(node_data, parent)
  elseif node_data.kind == NodeKind.Package then
    return PackageNode:new(node_data, parent)
  elseif node_data.kind == NodeKind.Container then
    return ContainerNode:new(node_data, parent)
  else
    -- For other node types, use the base node
    -- 对于其他节点类型，使用基础节点
    return BaseNode:new(node_data, parent)
  end
end

return NodeFactory

