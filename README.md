# java-deps.nvim

A Neovim plugin for viewing Java project dependencies, inspired by [vscode-java-dependency](https://github.com/microsoft/vscode-java-dependency).

## Features

- View project dependencies in a tree structure.
- Expand and collapse dependency nodes.
- Uses `jdtls` to get dependency information.
- Uses `snacks.nvim` to build the UI.

## Installation

### nvim-jdtls

Ensure that the `com.microsoft.jdtls.ext.core` extension jar from `vscode-java-dependency` is loaded into your `jdtls`.

- If you have `vscode-java-dependency` installed in VS Code, it is located at `.vscode/extensions/vscjava.vscode-java-dependency-{{version}}-universal/server/com.microsoft.jdtls.ext.core-0.24.1.jar`.
- I recently opened a [pull request](https://github.com/mason-org/mason-registry/pull/10719) to add `vscode-java-dependency` as a dependency in `mason-registry`.

Example `nvim-jdtls` configuration:

```lua
  {
    "mfussenegger/nvim-jdtls",
    opts = function()
          -- ...
    end,
    config = function(_, opts)
      -- Find the extra bundles that should be passed on the jdtls command-line
      local bundles = {} ---@type string[]
      if LazyVim.has("mason.nvim") then
        local mason_registry = require("mason-registry")
          if mason_registry.is_installed("vscode-java-dependency") then
            local java_deps_pkg = mason_registry.get_package("vscode-java-dependency")
            local java_deps_path = java_deps_pkg:get_install_path()
            vim.list_extend(jar_patterns, {
              java_deps_path .. "/extension/server/com.microsoft.jdtls.ext.core-*.jar",
            })
          end

          for _, jar_pattern in ipairs(jar_patterns) do
            for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), "\n")) do
              table.insert(bundles, bundle)
            end
          end
      end
      local function attach_jdtls()

        local config = extend_or_override({
          init_options = {
            bundles = bundles,
          },
        }, opts.jdtls)

        require("jdtls").start_or_attach(config)
      end

      -- ...

      attach_jdtls()
    end,
  },
```

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "g0ne150/java-deps.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = function()
    -- No setup needed, the plugin is loaded when the command is called
  end,
}
```

## Usage

- Run `:JavaDepsView` to open the dependency view.

### Keymaps

- `h`: Collapse the current node. If the node is already collapsed or cannot be expanded, collapse the parent node.
- `l`/`o`/`<CR>`: Expand the current node.

## Acknowledgements

- [vscode-java-dependency](https://github.com/microsoft/vscode-java-dependency): Provided the initial idea and the `jdtls` extension.
- [snacks.nvim](https://github.com/folke/snacks.nvim): Provided the powerful picker UI framework.

## License

[MIT](./LICENSE)