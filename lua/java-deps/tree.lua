-- lua/java-deps/tree.lua

-- This module manages the state of the dependency tree, including node expansion and data storage.
-- 该模块管理依赖树的状态，包括节点展开和数据存储。

local jdtls = require("java-deps.jdtls")
local NodeKind = require("java-deps.node_kind").NodeKind

local M = {}

-- The state of the dependency tree.
-- 依赖树的状态。
local state = {}

-- Get a unique ID for a node.
-- 获取节点的唯一 ID。
local function get_id(node)
  local id = node.handlerIdentifier or node.uri or node.name
  if node.project_uri then
    return node.project_uri .. "::" .. id
  end
  return id
end

-- Reset the state of the tree.
-- 重置树的状态。
function M.reset()
  state = {
    nodes = {},
    children = {},
    open = {},
    bufnr = nil,
  }
end

-- Add a node to the root of the tree.
-- 将一个节点添加到树的根部。
local function add_node_to_root(node)
  local id = get_id(node)
  state.nodes[id] = node
  table.insert(state.children.root, id)
end

-- Initialize the tree with a list of projects.
-- 使用项目列表初始化树。
function M.init(projects, bufnr, callback)
  M.reset()
  state.bufnr = bufnr
  state.children.root = {}

  -- If there are multiple projects, use the projects as the root nodes.
  -- 如果有多个项目，则使用项目作为根节点。
  for _, project in ipairs(projects) do
    project.project_uri = project.uri -- Store project_uri for later use
    add_node_to_root(project)
  end
  callback()
end

-- Toggle the expansion state of a node.
-- 切换节点的展开状态。
function M.toggle(node_id, callback)
  state.open[node_id] = not state.open[node_id]
  local node = state.nodes[node_id]

  -- If the node is being opened and its children have not been loaded yet, load them.
  -- 如果节点正在打开并且其子节点尚未加载，则加载它们。
  if state.open[node_id] and not state.children[node_id] then
    jdtls.get_children(state.bufnr, node.project_uri, node, function(children)
      if children then
        state.children[node_id] = {}
        for _, child in ipairs(children) do
          child.project_uri = node.project_uri -- Propagate project_uri to children
          child.parent = node
          if node.kind == NodeKind.Project then
            if child.kind == NodeKind.PackageRoot or child.kind == NodeKind.Container then
              local child_id = get_id(child)
              state.nodes[child_id] = child
              table.insert(state.children[node_id], child_id)
            end
          else
            local child_id = get_id(child)
            state.nodes[child_id] = child
            table.insert(state.children[node_id], child_id)
          end
        end
      end
      callback()
    end)
  else
    callback()
  end
end

-- Check if a node is open.
-- 检查节点是否打开。
function M.is_open(node_id)
  return state.open[node_id]
end

-- Check if a node is expandable.
-- 检查节点是否可展开。
local function is_expandable(node)
  return node.kind == NodeKind.Container
    or node.kind == NodeKind.PackageRoot
    or node.kind == NodeKind.Package
    or node.kind == NodeKind.Project
end

-- Get the list of visible nodes.
-- 获取可见节点列表。
function M.get_visible_nodes()
  local items = {}
  local function add_children(parent_id, depth)
    if not (state.open[parent_id] and state.children[parent_id]) then
      return
    end
    for _, child_id in ipairs(state.children[parent_id]) do
      local child_node = state.nodes[child_id]
      local icon = "  "
      if is_expandable(child_node) then
        icon = state.open[child_id] and "" or ""
      end
      child_node.prefix = string.rep("  ", depth) .. icon
      table.insert(items, child_node)
      if is_expandable(child_node) then
        add_children(child_id, depth + 1)
      end
    end
  end

  for _, node_id in ipairs(state.children.root or {}) do
    local node = state.nodes[node_id]
    local icon = "  "
    if is_expandable(node) then
      icon = state.open[node_id] and "" or ""
    end
    node.prefix = icon
    table.insert(items, node)
    if is_expandable(node) then
      add_children(node_id, 1)
    end
  end
  return items
end

-- Get the ID of a node.
-- 获取节点的 ID。
function M.get_id(node)
  return get_id(node)
end

return M
