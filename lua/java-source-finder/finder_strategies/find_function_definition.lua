local find_import_line = require('java-source-finder.finder_strategies.helpers').find_import_line
local jump_file_same_package = require('java-source-finder.finder_strategies.find_in_same_package').run
local try_to_jump = require("java-source-finder.finder_strategies.helpers").try_to_jump
local convert_import_line_to_file_path =
  require("java-source-finder.finder_strategies.helpers").convert_import_line_to_file_path
local try_to_jump_current_file = require('java-source-finder.finder_strategies.helpers').try_to_jump_current_file
local fzf_rg = require('java-source-finder.finder_strategies.helpers').fzf_pick_from_rg_response

local M = {}

local function find_function_same_package(open_cmd)
    local cur_dir = vim.fn.expand("%:p:h")
    local fnName = vim.fn.expand("<cword>")
    local cmd = 'rg "public \\w+ ' .. fnName .. '" -t java --vimgrep ' .. cur_dir

    local filesMatched = vim.fn.systemlist(cmd)
    return fzf_rg(open_cmd, filesMatched, 'sda')
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
