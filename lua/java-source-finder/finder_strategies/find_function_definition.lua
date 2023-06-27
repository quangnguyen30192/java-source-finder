local find_import_line = require('java-source-finder.finder_strategies.helpers').find_import_line
local jump_file_same_package = require('java-source-finder.finder_strategies.find_in_same_package').run
local try_to_jump = require("java-source-finder.finder_strategies.helpers").try_to_jump
local convert_import_line_to_file_path =
  require("java-source-finder.finder_strategies.helpers").convert_import_line_to_file_path

local M = {}

-- covers for a line of function call merely function.call(a)
M.run = function(open_cmd)
  local method_name = vim.fn.expand("<cword>")
  local function_call_line = vim.fn.expand("<cWORD>")

  if not string.find(function_call_line, ".") then
    return false
  end
  local pieces = vim.fn.split(function_call_line, [[\.]])

  -- assume class_name is the first part of pieces with first capitalize letter
  local class_name = string.gsub(string.gsub(pieces[1], ".*[(]", ""), "^%l", string.upper)
  if not class_name then
    return false
  end

  -- make sure it has ( which means the function call
  if not string.find(function_call_line, method_name .. "(", nil, true) then
    return false
  end

  local import_line = find_import_line(class_name)
  if import_line == nil then
    return jump_file_same_package(open_cmd, class_name, method_name)
  else
    local file_paths = convert_import_line_to_file_path(import_line)
    return try_to_jump(open_cmd, file_paths, method_name)
  end
end

return M
