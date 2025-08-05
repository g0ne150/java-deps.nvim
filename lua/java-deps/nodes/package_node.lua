-- lua/java-deps/nodes/package_node.lua

-- Package node class that handles package-type nodes
-- 包节点类，处理包类型的节点

local BaseNode = require("java-deps.nodes.base_node")
local NodeKind = require("java-deps.node_kind").NodeKind
local jdtls = require("java-deps.jdtls")

local PackageNode = setmetatable({}, { __index = BaseNode })
PackageNode.__index = PackageNode

function PackageNode:new(node_data, parent)
  local instance = BaseNode:new(node_data, parent)
  setmetatable(instance, self)
  return instance
end

-- Get children of the package node
-- 获取包节点的子节点
function PackageNode:get_children(callback)
  jdtls.get_children(self:get_project_uri(), self.node_data, callback)
end

return PackageNode

