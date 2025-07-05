-- lua/java-deps/picker.lua

local tree = require("java-deps.tree")
local NodeKind = require("java-deps.node_kind").NodeKind
local ContainerEntryKind = require("java-deps.node_kind").ContainerEntryKind

local M = {}

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
      toggle = function(p, item)
        if not item then return end
        local node = item.value
        if node.kind == NodeKind.Container or node.kind == NodeKind.Project then
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
      expand = function(p, item)
        if not item then return end
        local node = item.value
        if (node.kind == NodeKind.Container or node.kind == NodeKind.Project) and not tree.is_open(tree.get_id(node)) then
          p.list:set_target()
          tree.toggle(tree.get_id(node), function()
            if not p.closed then p:find() end
          end)
        end
      end,
      -- Collapses a node. If already collapsed, collapses the parent.
      collapse = function(p, item)
        if not item then return end
        local node = item.value
        if (node.kind == NodeKind.Container or node.kind == NodeKind.Project) and tree.is_open(tree.get_id(node)) then
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
    confirm = "toggle",
  })
end

return M