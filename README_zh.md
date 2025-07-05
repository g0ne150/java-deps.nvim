# java-deps.nvim

一个用于查看 Java 项目依赖的 Neovim 插件，灵感来源于 [vscode-java-dependency](https://github.com/microsoft/vscode-java-dependency)。

## 功能

- 以树状结构查看项目依赖。
- 展开和折叠依赖节点。
- 使用 `jdtls` 获取依赖信息。
- 使用 `snacks.nvim` 构建 UI。

## 安装

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "zapan/java-deps.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = function()
    -- 无需设置，插件在命令调用时加载
  end,
}
```

## 使用

- 运行 `:JavaDepsView` 打开依赖视图。

### 快捷键

- `h`: 折叠当前节点。如果当前节点已经折叠或无法展开，则折叠父节点。
- `l`/`o`/`<CR>`: 展开当前节点。

## 致谢

- [vscode-java-dependency](https://github.com/microsoft/vscode-java-dependency): 提供了最初的想法和 `jdtls` 扩展。
- [snacks.nvim](https://github.com/folke/snacks.nvim): 提供了强大的选择器 UI 框架。
