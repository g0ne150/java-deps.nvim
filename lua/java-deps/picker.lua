-- lua/java-deps/picker.lua

-- This module is responsible for all the logic of the snacks.nvim picker,
-- including custom finder and confirm actions.
-- 该模块负责 snacks.nvim picker 的所有逻辑，包括自定义的 finder 和 confirm 行为。

local tree = require("java-deps.tree")
local jdtls = require("java-deps.jdtls")
local NodeKind = require("java-deps.node_kind").NodeKind

local M = {}

local icons = {
  [NodeKind.Workspace] = "󰅨 ",
  [NodeKind.Project] = " ",
  [NodeKind.PackageRoot] = " ",
  [NodeKind.Package] = "󰏖 ",
  [NodeKind.PrimaryType] = " ",
  [NodeKind.CompilationUnit] = " ",
  [NodeKind.ClassFile] = "󰈔 ",
  [NodeKind.Container] = "󰆼 ",
  [NodeKind.Folder] = "󰉋 ",
  [NodeKind.File] = "󰈔 ",
}

local icon_hl_groups = {
  [NodeKind.Workspace] = "SnacksPickerIconNamespace",
  [NodeKind.Project] = "SnacksPickerIconModule",
  [NodeKind.PackageRoot] = "SnacksPickerIconPackage",
  [NodeKind.Package] = "SnacksPickerIconPackage",
  [NodeKind.PrimaryType] = "SnacksPickerIconClass",
  [NodeKind.CompilationUnit] = "SnacksPickerIconFile",
  [NodeKind.ClassFile] = "SnacksPickerIconFile",
  [NodeKind.Container] = "SnacksPickerIconStruct",
  [NodeKind.Folder] = "SnacksPickerDirectory",
  [NodeKind.File] = "SnacksPickerIconFile",
}

local function get_icon(node)
  local icon = icons[node.kind]
  if not icon then return "" end
  return icon
end

local function get_icon_hl_group(node)
  return icon_hl_groups[node.kind] or "SnacksPickerIcon"
end

-- The finder function for the picker.
-- picker 的 finder 函数。
local function finder(opts, ctx)
  return function(cb)
    local items = tree.get_visible_nodes()
    for _, item in ipairs(items) do
      cb({
        value = item,
        text = item.displayName or item.name,
      })
    end
  end
end

-- Check if a node can be toggled.
-- 检查节点是否可以切换。
local function is_toggleable(node)
  return node.kind == NodeKind.Container
    or node.kind == NodeKind.Project
    or node.kind == NodeKind.PackageRoot
    or node.kind == NodeKind.Package
end

-- Helper function to toggle a node and refresh the picker.
-- 辅助函数，用于切换节点并刷新选择器。
local function toggle_node(p, node_to_toggle, on_done)
  p.list:set_target()
  tree.toggle(tree.get_id(node_to_toggle), function()
    if not p.closed then p:find({ on_done = on_done }) end
  end)
end

local function reveal(p, node_id)
  local visible_nodes = tree.get_visible_nodes()
  for i, n in ipairs(visible_nodes) do
    if tree.get_id(n) == node_id then
      p.list:view(i, nil, true)
      return true
    end
  end
  return false
end

local function update(p, opts)
  opts = opts or {}
  local target_id = opts.target_id
  local refresh = opts.refresh
  local on_done_callback = opts.on_done

  if not refresh and target_id then
    local revealed = reveal(p, target_id)
    if on_done_callback then on_done_callback(revealed) end
    return
  end

  if opts.target ~= false then
    p.list:set_target()
  end

  p:find({
    on_done = function()
      if target_id then
        reveal(p, target_id)
      end
      if on_done_callback then
        on_done_callback()
      end
    end,
  })
end

local function open_node(bufnr, location)
  local clients = vim.lsp.get_clients({ name = "jdtls", bufnr })
  if #clients == 0 then
    vim.notify("No active LSP client found for the current buffer.", vim.log.levels.WARN)
    return
  end

  -- Assuming the first client is the one we want to use.
  -- 假设第一个客户端是我们要使用的客户端。
  local client = clients[1]
  local position_encoding = client.offset_encoding

  vim.lsp.util.show_document(location, position_encoding, {})
end

local function reveal_by_path(p, bufnr, buf_path)
  if not buf_path or buf_path == "" then return end

  local uri
  if vim.startswith(buf_path, "jdt://") then
    uri = buf_path
  else
    uri = vim.uri_from_fname(buf_path)
  end

  jdtls.resolve_path(bufnr, uri, function(path_nodes)
    if not path_nodes or #path_nodes == 0 then return end

    local initial_visible_nodes = tree.get_visible_nodes()
    local start_index = 1

    -- Handle the case where there is only one project and the project node is not displayed.
    -- 处理只有一个项目且不显示项目节点的情况。
    if #path_nodes > 1 and path_nodes[1].kind == NodeKind.Project then
      local project_node_visible = false
      for _, node in ipairs(initial_visible_nodes) do
        if node.kind == NodeKind.Project then
          project_node_visible = true
          break
        end
      end
      if not project_node_visible then
        start_index = 2
      end
    end

    local function expand_and_find(nodes_to_find, current_node_list, index)
      if index > #nodes_to_find then
        local last_node_info = nodes_to_find[#nodes_to_find]
        for _, visible_node in ipairs(current_node_list) do
          if visible_node.name == last_node_info.name and visible_node.kind == last_node_info.kind then
            reveal(p, tree.get_id(visible_node))
            break
          end
        end
        return
      end

      local node_to_find = nodes_to_find[index]
      local found_node = nil
      for _, visible_node in ipairs(current_node_list) do
        if visible_node.name == node_to_find.name and visible_node.kind == node_to_find.kind then
          found_node = visible_node
          break
        end
      end

      if found_node then
        local node_id = tree.get_id(found_node)
        if not tree.is_open(node_id) and is_toggleable(found_node) then
          tree.toggle(node_id, function()
            update(p, {
              on_done = function()
                expand_and_find(nodes_to_find, tree.get_visible_nodes(), index + 1)
              end,
            })
          end)
        else
          expand_and_find(nodes_to_find, tree.get_visible_nodes(), index + 1)
        end
      else
        -- Node not found, do nothing.
      end
    end

    expand_and_find(path_nodes, initial_visible_nodes, start_index)
  end)
end

-- Show the dependency tree picker.
-- 显示依赖树选择器。
function M.show(projects, bufnr)
  tree.init(projects, bufnr, function()
    local picker = require("snacks.picker")
    local p = picker({
      title = "Java Dependencies",
      finder = finder,
      layout = { preset = "sidebar", preview = false }, -- preview 设置为默认值可以 debug node 节点数据。
      focus = "list",
      format = function(entry)
        local node = entry.value
        local node_icon = get_icon(node)
        local node_icon_hl = get_icon_hl_group(node)
        local name = node.displayName or node.name
        local prefix = node.prefix or ""

        return {
          { prefix .. " " },
          { node_icon, node_icon_hl },
          { name },
        }
      end,
      actions = {
        -- Toggles a node. Expands if collapsed, collapses if expanded.
        -- 切换节点。如果折叠则展开，如果展开则折叠。
        toggle = function(p, item)
          if not item then return end
          local node = item.value
          if is_toggleable(node) then
            toggle_node(p, node)
          else
            p:close()
            if node.uri then
              open_node(bufnr, { uri = node.uri, range = node.range })
            end
          end
        end,
        -- Expands a node only if it's collapsed.
        -- 仅在节点折叠时展开。
        expand = function(p, item)
          if not item then return end
          local node = item.value
          if is_toggleable(node) and not tree.is_open(tree.get_id(node)) then
            toggle_node(p, node)
          elseif not is_toggleable(node) then
            p:close()
            if node.uri then
              open_node(bufnr, { uri = node.uri, range = node.range })
            end
          end
        end,
        -- Collapses a node. If already collapsed, collapses the parent.
        -- 折叠节点。如果已经折叠，则折叠父节点。
        collapse = function(p, item)
          if not item then return end
          local node = item.value
          if is_toggleable(node) and tree.is_open(tree.get_id(node)) then
            toggle_node(p, node)
          elseif node.parent then
            local parent_node = node.parent
            local parent_id = tree.get_id(parent_node)

            if not tree.is_open(parent_id) then return end

            tree.toggle(parent_id, function()
              if p.closed then return end
              update(p, { target_id = parent_id, refresh = true })
            end)
          end
        end,
      },
      win = {
        list = {
          keys = {
            ["h"] = "collapse",
            ["l"] = "expand",
            ["o"] = "expand",
            ["<CR>"] = "toggle",
          },
        },
      },
      -- The default confirm action is now 'toggle'
      -- 默认的确认操作现在是“toggle”
      confirm = "toggle",
    })

    local current_buf_path = vim.api.nvim_buf_get_name(0)
    reveal_by_path(p, bufnr, current_buf_path)
  end)
end

return M
