-- lua/java-deps/picker.lua

-- This module is responsible for all the logic of the snacks.nvim picker,
-- including custom finder and confirm actions.
-- 该模块负责 snacks.nvim picker 的所有逻辑，包括自定义的 finder 和 confirm 行为。

local tree = require("java-deps.tree")
local NodeKind = require("java-deps.node_kind").NodeKind
local ContainerEntryKind = require("java-deps.node_kind").ContainerEntryKind

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

-- Show the dependency tree picker.
-- 显示依赖树选择器。
function M.show(projects, bufnr)
  tree.init(projects, bufnr)

  local picker = require("snacks.picker")
  picker({
    title = "Java Dependencies",
    finder = finder,
    layout = "sidebar",
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
          p.list:set_target()
          tree.toggle(tree.get_id(node), function()
            if not p.closed then p:find() end
          end)
        else
          p:close()
          print(vim.inspect(node))
        end
      end,
      -- Expands a node only if it's collapsed.
      -- 仅在节点折叠时展开。
      expand = function(p, item)
        if not item then return end
        local node = item.value
        if is_toggleable(node) and not tree.is_open(tree.get_id(node)) then
          p.list:set_target()
          tree.toggle(tree.get_id(node), function()
            if not p.closed then p:find() end
          end)
        end
      end,
      -- Collapses a node. If already collapsed, collapses the parent.
      -- 折叠节点。如果已经折叠，则折叠父节点。
      collapse = function(p, item)
        if not item then return end
        local node = item.value
        if is_toggleable(node) and tree.is_open(tree.get_id(node)) then
          p.list:set_target()
          tree.toggle(tree.get_id(node), function()
            if not p.closed then p:find() end
          end)
        elseif node.parent then
          p.list:set_target()
          tree.toggle(tree.get_id(node.parent), function()
            if not p.closed then p:find() end
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
end

return M
