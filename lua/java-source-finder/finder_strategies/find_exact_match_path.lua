local find_import_line = require("java-source-finder.finder_strategies.helpers").find_import_line
local try_to_jump = require("java-source-finder.finder_strategies.helpers").try_to_jump
local convert_import_line_to_file_path =
  require("java-source-finder.finder_strategies.helpers").convert_import_line_to_file_path

local M = {}

-- Find the file in possible paths, if file exists, open the file and jump the correct line
M.run = function(open_cmd)
  -- print "jump_to_exact_match_path"
  local cur_word = vim.fn.expand("<cword>")

  local line = find_import_line(cur_word)

  if line == nil then
    return false
  end

  local paths = convert_import_line_to_file_path(line)

  return try_to_jump(open_cmd, paths, cur_word)
end

return M
