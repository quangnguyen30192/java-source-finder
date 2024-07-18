local try_to_jump = require("java-source-finder.finder_strategies.helpers").try_to_jump

local M = {}
M.run = function(open_cmd, symbol, keyword)
  local cur_dir = vim.fn.expand("%:p:h")
  local javaClassName = symbol or vim.fn.expand("<cword>")
  local searchKeyword = keyword or javaClassName

  local paths = {}
  table.insert(paths, cur_dir .. "/" .. javaClassName .. ".java")
  table.insert(paths, string.gsub(cur_dir, "main", "test") .. "/" .. javaClassName .. ".java")
  table.insert(paths, string.gsub(cur_dir, "test", "main") .. "/" .. javaClassName .. ".java")

  return try_to_jump(open_cmd, paths, searchKeyword)
end

return M
