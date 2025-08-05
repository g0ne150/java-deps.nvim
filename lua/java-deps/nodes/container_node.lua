-- lua/java-deps/nodes/container_node.lua

-- Container node class that handles container-type nodes (like Maven Dependencies, JRE System Library)
-- 容器节点类，处理容器类型的节点（如Maven依赖、JRE系统库）

local BaseNode = require("java-deps.nodes.base_node")
local NodeKind = require("java-deps.node_kind").NodeKind
local jdtls = require("java-deps.jdtls")

local ContainerNode = setmetatable({}, { __index = BaseNode })
ContainerNode.__index = ContainerNode

function ContainerNode:new(node_data, parent)
  local instance = BaseNode:new(node_data, parent)
  setmetatable(instance, self)
  return instance
end

-- Get children of the container node
-- 获取容器节点的子节点
function ContainerNode:get_children(callback)
  jdtls.get_children(self:get_project_uri(), self.node_data, callback)
end

return ContainerNode
