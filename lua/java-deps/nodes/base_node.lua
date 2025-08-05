-- lua/java-deps/nodes/base_node.lua

-- Base node class that defines the common interface for all node types
-- 基础节点类，定义所有节点类型的通用接口

local NodeKind = require("java-deps.node_kind").NodeKind
local jdtls = require("java-deps.jdtls")

local BaseNode = {}
BaseNode.__index = BaseNode

function BaseNode:new(node_data, parent)
  local instance = setmetatable({}, self)
  instance.node_data = node_data
  instance.parent = parent
  return instance
end

-- Get children of the node
-- 获取节点的子节点
function BaseNode:get_children(callback)
  -- Default implementation that calls jdtls directly
  -- 默认实现直接调用jdtls
  jdtls.get_children(self:get_project_uri(), self.node_data, callback)
end

-- Check if the node is expandable
-- 检查节点是否可展开
function BaseNode:is_expandable()
  return self.node_data.kind == NodeKind.Container
    or self.node_data.kind == NodeKind.PackageRoot
    or self.node_data.kind == NodeKind.Package
    or self.node_data.kind == NodeKind.Project
    or self.node_data.kind == NodeKind.Folder
end

-- Get the node's display name
-- 获取节点的显示名称
function BaseNode:get_display_name()
  return self.node_data.displayName or self.node_data.name
end

-- Get the node's kind
-- 获取节点的类型
function BaseNode:get_kind()
  return self.node_data.kind
end

-- Get the node's path
-- 获取节点的路径
function BaseNode:get_path()
  return self.node_data.path
end

-- Get the node's URI
-- 获取节点的URI
function BaseNode:get_uri()
  return self.node_data.uri
end

-- Get the node's handler identifier
-- 获取节点的处理程序标识符
function BaseNode:get_handler_identifier()
  return self.node_data.handlerIdentifier
end

-- Get the project URI
-- 获取项目URI
function BaseNode:get_project_uri()
  return self.node_data.project_uri
end

return BaseNode

