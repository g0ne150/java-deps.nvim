# Gemini.md

## 项目描述

- 参考 [vscode-java-dependency](https://github.com/microsoft/vscode-java-dependency) vscode 插件， 实现一个 neovim 的功能类似的插件，即展示 java 项目中的依赖项。
- 插件的实现依赖 jdtls 扩展 com.microsoft.jdtls.ext.core，坚持使用和 vscode-java-dependency 一致的 jdtls 命令，如果命令不存在，先确定 vscode-java-dependency 是不是用了这个命令，如果 vscode-java-dependency 也用了，那么督促用户解决命令不存在的问题。
- 使用 snacks 的 picker 模块，并使用 sidebar layout 的窗口在展示 java 项目依赖项，具体可以参考 snacks 的 explorer 模块，它也是使用 picker 实现的，使用 context7 mcp server。

## 代码结构

- lua/java-deps/jdtls.lua: 封装所有与 jdtls 的通信。
- lua/java-deps/tree.lua: 管理依赖树的数据结构和状态（如节点的展开/折叠）。
- lua/java-deps/picker.lua: 负责 snacks.nvim picker 的所有逻辑，包括自定义的 finder 和 confirm 行为。
- lua/java-deps/init.lua: 作为插件主入口，调用 picker 模块来显示视图。
- lua/java-deps/node_kind.lua: 定义 NodeKind 枚举。

## 快捷键

- `h`: 折叠当前节点，如果当前节点已经折叠或无法展开，则折叠父节点。
- `l`/`o`/`<CR>`: 展开当前节点。

## 补充说明

1. 当前目录下 snacks.nvim 目录仅作为代码参考，当你调用 snacks.nvim 的 api 时，可以参考他的实现，来精准使用它的 API；如果报错发生在 snacks 代码中，也可以通过这个目录下找到对应文件，查看源码排查问题。
1. 当前目录下 vscode-java-dependency 目录仅作为代码参考，可以它的代码实现来，例如它调用了哪些 jdtls 命令实现的相关功能等等。
1. vscode-java-dependency 通过 vscode-java-dependency/jdtls.ext/pom.xml 扩展了 jdtls，现在我通过 mason 添加了 vscode-java-dependency 模块，假设 jdtls.ext 的 jar 包有已经正确进入 jdtls runtime。
1. 使用英语编写 README.md，使用中文编写 README_zh.md
1. 鼓励使用 context7 mcp server，避免瞎猜 API 接口。

## TODO

> 不要上来就写代码，相关实现和 vscode-java-dependency 保持一致，建议先查看它代码明确需求。
> TODO 项目一个一个来，完成一个就结束，让用户确认是否达到预期，收到明确开始下一项的指令后，再开始。

- [x] 实现 Package Node 的展开功能。
- [x] review 所有代码，为代码添加合适的注释，需要英语中文双语，英语在前中文在后。
