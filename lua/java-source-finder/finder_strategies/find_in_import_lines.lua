local find_import_line = require("java-source-finder.finder_strategies.helpers").find_import_line
local convert_import_line_to_file_path =
  require("java-source-finder.finder_strategies.helpers").convert_import_line_to_file_path
local try_to_jump = require("java-source-finder.finder_strategies.helpers").try_to_jump
local is_symbol = require("java-source-finder.finder_strategies.helpers").is_symbol

local M = {}

-- Find the file in possible paths, if file exists, open the file and jump the correct line
M.run = function(open_cmd)
  local cur_word = vim.fn.expand("<cword>")
  if not is_symbol(cur_word) then
    return false
  end

  local import_line = find_import_line(cur_word)
  if import_line == nil then
    return false
  end

  local paths = convert_import_line_to_file_path(line)
  return try_to_jump(open_cmd, paths, cur_word)
end

return M
