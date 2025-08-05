-- lua/java-deps/nodes/package_root_node.lua

-- Package root node class that handles package root-type nodes
-- 包根节点类，处理包根类型的节点

local BaseNode = require("java-deps.nodes.base_node")
local NodeKind = require("java-deps.node_kind").NodeKind
local jdtls = require("java-deps.jdtls")

local PackageRootNode = setmetatable({}, { __index = BaseNode })
PackageRootNode.__index = PackageRootNode

function PackageRootNode:new(node_data, parent)
  local instance = BaseNode:new(node_data, parent)
  setmetatable(instance, self)
  return instance
end

-- Get children of the package root node
-- 获取包根节点的子节点
function PackageRootNode:get_children(callback)
  jdtls.get_children(self:get_project_uri(), self.node_data, callback)
end

return PackageRootNode

