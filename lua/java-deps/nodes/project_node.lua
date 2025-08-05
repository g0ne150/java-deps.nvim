-- lua/java-deps/nodes/project_node.lua

-- Project node class that handles project-type nodes
-- 项目节点类，处理项目类型的节点

local BaseNode = require("java-deps.nodes.base_node")
local NodeKind = require("java-deps.node_kind").NodeKind
local jdtls = require("java-deps.jdtls")

local ProjectNode = setmetatable({}, { __index = BaseNode })
ProjectNode.__index = ProjectNode

function ProjectNode:new(node_data, parent)
  local instance = BaseNode:new(node_data, parent)
  setmetatable(instance, self)
  return instance
end

-- Get children of the project node
-- 获取项目节点的子节点
function ProjectNode:get_children(callback)
  jdtls.get_children(self:get_project_uri(), self.node_data, callback)
end

return ProjectNode