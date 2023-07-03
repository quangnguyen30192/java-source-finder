local find_import_line = require("java-source-finder.finder_strategies.helpers").find_import_line
local jump_file_same_package = require("java-source-finder.finder_strategies.find_in_same_package").run
local try_to_jump = require("java-source-finder.finder_strategies.helpers").try_to_jump
local convert_import_line_to_file_path =
  require("java-source-finder.finder_strategies.helpers").convert_import_line_to_file_path
local try_to_jump_current_file = require("java-source-finder.finder_strategies.helpers").try_to_jump_current_file
local find_function_same_package = require("java-source-finder.finder_strategies.helpers").find_function_same_package

local M = {}

local function find_by_import_line(open_cmd, class_name, method_name)
  local import_line = find_import_line(class_name)
  if import_line == nil then
    return jump_file_same_package(open_cmd, class_name, method_name)
  end

  local file_paths = convert_import_line_to_file_path(import_line)
  return try_to_jump(open_cmd, file_paths, method_name)
end

-- covers for a line of function call merely function.call(a)
M.run = function(open_cmd)
  local method_name = vim.fn.expand("<cword>")
  local function_call_line = vim.fn.expand("<cWORD>")

  if not string.find(function_call_line, ".") then
    return false
  end
  local pieces = vim.fn.split(function_call_line, [[\.]])

  -- assume class_name is the first part of pieces with first capitalize letter
  local class_name = string.gsub(string.gsub(pieces[1], ".*[!();]", ""), "^%l", string.upper)
  if not class_name or vim.fn.empty(class_name) == 1 then
    return try_to_jump_current_file(method_name) or find_function_same_package(open_cmd)
  end

  if not string.find(function_call_line, method_name .. "(", nil, true) then
    return false
  end

  return find_by_import_line(open_cmd, class_name, method_name)
    or try_to_jump_current_file(method_name)
    or find_function_same_package(open_cmd)
end

return M
