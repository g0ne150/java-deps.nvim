-- lua/java-deps/tree.lua

local jdtls = require("java-deps.jdtls")
local NodeKind = require("java-deps.node_kind").NodeKind

local M = {}

local state = {}

local function get_id(node)
  return node.handlerIdentifier or node.uri or node.name
end

function M.reset()
  state = {
    nodes = {},
    children = {},
    open = {},
    bufnr = nil,
  }
end

function M.init(projects, bufnr)
  M.reset()
  state.bufnr = bufnr
  state.children.root = {}
  for _, project in ipairs(projects) do
    local id = get_id(project)
    project.project_uri = project.uri -- Store project_uri for later use
    state.nodes[id] = project
    table.insert(state.children.root, id)
  end
end

function M.toggle(node_id, callback)
  state.open[node_id] = not state.open[node_id]
  local node = state.nodes[node_id]

  if state.open[node_id] and not state.children[node_id] then
    jdtls.get_children(state.bufnr, node.project_uri, node, function(children)
      if children then
        state.children[node_id] = {}
        for _, child in ipairs(children) do
          if node.kind == NodeKind.Project then
            if child.kind == NodeKind.PackageRoot or child.kind == NodeKind.Container then
              local child_id = get_id(child)
              child.project_uri = node.project_uri -- Propagate project_uri to children
              child.parent = node
              state.nodes[child_id] = child
              table.insert(state.children[node_id], child_id)
            end
          else
            local child_id = get_id(child)
            child.project_uri = node.project_uri -- Propagate project_uri to children
            child.parent = node
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

function M.is_open(node_id)
  return state.open[node_id]
end

function M.get_visible_nodes()
  local items = {}
  local function add_children(parent_id, depth)
    if not (state.open[parent_id] and state.children[parent_id]) then
      return
    end
    for _, child_id in ipairs(state.children[parent_id]) do
      local child_node = state.nodes[child_id]
      local icon = "  "
      if child_node.kind == NodeKind.Container or child_node.kind == NodeKind.PackageRoot then
        icon = state.open[child_id] and "" or ""
      end
      child_node.display = string.rep("  ", depth) .. icon .. " " .. (child_node.displayName or child_node.name)
      table.insert(items, child_node)
      if child_node.kind == NodeKind.Container or child_node.kind == NodeKind.PackageRoot then
        add_children(child_id, depth + 1)
      end
    end
  end

  for _, project_id in ipairs(state.children.root or {}) do
    local project_node = state.nodes[project_id]
    local icon = state.open[project_id] and "" or ""
    project_node.display = icon .. " " .. project_node.name
    table.insert(items, project_node)
    if state.open[project_id] then
      add_children(project_id, 1)
    end
  end
  return items
end

function M.get_id(node)
  return get_id(node)
end

return M