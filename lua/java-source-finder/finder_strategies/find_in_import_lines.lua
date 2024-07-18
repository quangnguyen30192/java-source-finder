local find_import_line = require("java-source-finder.finder_strategies.helpers").find_import_line
local convert_import_line_to_file_path =
  require("java-source-finder.finder_strategies.helpers").convert_import_line_to_file_path
local try_to_jump = require("java-source-finder.finder_strategies.helpers").try_to_jump

local M = {}

-- Find the file in possible paths, if file exists, open the file and jump the correct line
M.run = function(open_cmd, symbol)
  local import_line = find_import_line(symbol)
  if import_line == nil then
    return false
  end

  local paths = convert_import_line_to_file_path(line)
  return try_to_jump(open_cmd, paths, symbol)
end

return M
