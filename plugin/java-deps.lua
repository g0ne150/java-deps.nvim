vim.api.nvim_create_user_command("JavaDepsView", function()
  require("java-deps").view()
end, {})

vim.api.nvim_create_user_command("JavaDepsViewRefresh", function()
  require("java-deps.picker").close()
  require("java-deps.tree").clear_cache()
end, {})
