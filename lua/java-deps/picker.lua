-- lua/java-deps/picker.lua

-- This module is responsible for all the logic of the snacks.nvim picker,
-- including custom finder and confirm actions.
-- 该模块负责 snacks.nvim picker 的所有逻辑，包括自定义的 finder 和 confirm 行为。

local tree = require("java-deps.tree")
local NodeKind = require("java-deps.node_kind").NodeKind

local M = {}

-- The finder function for the picker.
-- picker 的 finder 函数。
local function finder(opts, ctx)
  return function(cb)
    local items = tree.get_visible_nodes()
    for _, item in ipairs(items) do
      cb({
        value = item,
        display = item.display,
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

  if not refresh and target_id then
    return reveal(p, target_id)
  end

  if opts.target ~= false then
    p.list:set_target()
  end

  p:find({
    on_done = function()
      if target_id then
        reveal(p, target_id)
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

-- Show the dependency tree picker.
-- 显示依赖树选择器。
function M.show(projects, bufnr)
  tree.init(projects, bufnr, function()
    local picker = require("snacks.picker")
    picker({
      title = "Java Dependencies",
      finder = finder,
      layout = { preset = "sidebar", preview = false }, -- preview 设置为默认值可以 debug node 节点数据。
      focus = "list",
      format = function(entry)
        return { { entry.display } }
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
  end)
end

return M
