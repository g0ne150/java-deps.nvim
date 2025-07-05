vim.api.nvim_create_user_command("JavaDepsView", function()
  require("java-deps").view()
end, {})