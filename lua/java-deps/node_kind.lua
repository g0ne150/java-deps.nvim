-- lua/java-deps/node_kind.lua

-- This module defines the enumerations for the different kinds of nodes in the dependency tree.
-- 该模块定义了依赖树中不同种类节点的枚举。

-- NodeKind an enumeration for the different kinds of nodes in the explorer.
-- NodeKind 是一个枚举类型，用于表示资源管理器中不同种类节点。
local NodeKind = {
  Workspace = 1,
  Project = 2,
  PackageRoot = 3,
  Package = 4,
  PrimaryType = 5,
  CompilationUnit = 6,
  ClassFile = 7,
  Container = 8,
  Folder = 9,
  File = 10,
}

-- TypeKind an enumeration for the different kinds of types.
-- TypeKind 是一个枚举类型，用于表示不同类型的 Java 类型。
local TypeKind = {
  Class = 1,
  Interface = 2,
  Enum = 3,
}

-- ContainerEntryKind an enumeration for the different kinds of container entries.
-- ContainerEntryKind 是一个枚举类型，用于表示不同类型的容器条目。
local ContainerEntryKind = {
  -- Entry kind constant describing a classpath entry identifying a
  -- library. A library is a folder or JAR containing package
  -- fragments consisting of pre-compiled binaries.
  -- 用于标识库的类路径条目。库是一个包含预编译二进制文件的包片段��文件夹或 JAR。
  CPE_LIBRARY = 1,

  -- Entry kind constant describing a classpath entry identifying a
  -- required project.
  -- 用于标识所需项目的类路径条目。
  CPE_PROJECT = 2,

  -- Entry kind constant describing a classpath entry identifying a
  -- folder containing package fragments with source code
  -- to be compiled.
  -- 用于标识包含要编译的源代码的包片段的文件夹的类路径条目。
  CPE_SOURCE = 3,

  -- Entry kind constant describing a classpath entry defined using
  -- a path that begins with a classpath variable reference.
  -- 用于标识使用类路径变量引用的路径定义的类路径条目。
  CPE_VARIABLE = 4,

  -- Entry kind constant describing a classpath entry representing
  -- a name classpath container.
  --
  -- @since 2.0
  -- 用于表示名称类路径容器的类路径条目。
  CPE_CONTAINER = 5,
}

-- PackageRootKind an enumeration for the different kinds of package roots.
-- PackageRootKind 是一个枚举类型，用于表示不同类型的包根。
local PackageRootKind = {
  -- Kind constant for a source path root. Indicates this root
  -- only contains source files.
  -- 源路径根的类型常量。表示此根仅包含源文件。
  K_SOURCE = 1,
  -- Kind constant for a binary path root. Indicates this
  -- root only contains binary files.
  -- 二进制路径根的类型常量。表示此根仅包含二进制文件。
  K_BINARY = 2,
}

return {
  NodeKind = NodeKind,
  TypeKind = TypeKind,
  ContainerEntryKind = ContainerEntryKind,
  PackageRootKind = PackageRootKind,
}

