local try_to_jump = require("java-source-finder.finder_strategies.helpers").try_to_jump

local M = {}
-- Try to find the file which is on the same package, because java file doesn't need to import that file
M.run = function(open_cmd, filename)
  -- print "jump_file_same_package"
  local cur_dir = vim.fn.expand("%:p:h")
  local cur_word = filename or vim.fn.expand("<cword>")

  local paths = {}

  table.insert(paths, cur_dir .. "/" .. cur_word .. ".java")
  table.insert(paths, string.gsub(cur_dir, "main", "test") .. "/" .. cur_word .. ".java")
  table.insert(paths, string.gsub(cur_dir, "test", "main") .. "/" .. cur_word .. ".java")

  return try_to_jump(open_cmd, paths, cur_word)
end

return M
