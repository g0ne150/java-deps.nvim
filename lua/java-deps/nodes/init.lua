-- lua/java-deps/nodes/init.lua

-- Init file for the nodes module
-- 节点模块的初始化文件

return {
  BaseNode = require("java-deps.nodes.base_node"),
  ProjectNode = require("java-deps.nodes.project_node"),
  PackageRootNode = require("java-deps.nodes.package_root_node"),
  FolderNode = require("java-deps.nodes.folder_node"),
  PackageNode = require("java-deps.nodes.package_node"),
  ContainerNode = require("java-deps.nodes.container_node"),
  NodeFactory = require("java-deps.nodes.node_factory"),
}