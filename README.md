# java-deps.nvim

A Neovim plugin to view Java project dependencies, inspired by [vscode-java-dependency](https://github.com/microsoft/vscode-java-dependency).

## Features

- View project dependencies in a tree structure.
- Expand and collapse dependency nodes.
- Uses `jdtls` to get dependency information.
- Built with `snacks.nvim` for the UI.

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "g0ne150/java-deps.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = function()
    -- No setup needed, the plugin is loaded on command
  end,
}
```

## Usage

- Run `:JavaDepsView` to open the dependency view.

### Keymaps

- `h`: Collapse the current node. If the node is already collapsed or cannot be expanded, collapse the parent node.
- `l`/`o`/`<CR>`: Expand the current node.

## Credits

- [vscode-java-dependency](https://github.com/microsoft/vscode-java-dependency): For the original idea and the `jdtls` extension.
- [snacks.nvim](https://github.com/folke/snacks.nvim): For the awesome picker UI framework.

## License

[MIT](./LICENSE)
