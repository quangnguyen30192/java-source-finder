local fzf_pick_from_rg_response = require('java-source-finder.finder_strategies.helpers').fzf_pick_from_rg_response
local M = {}

M.run = function(open_cmd)
  -- print("jump_to_function_definition")
  local cur_word = vim.fn.expand("<cword>")
  local full_word = vim.fn.expand("<cWORD>")

  if not string.find(full_word, ".") then
    return false
  end
  local kw = vim.fn.split(full_word, [[\.]])

  -- assume class_name is the first part of kw with first capitalize letter
  local class_name = string.gsub(string.gsub(kw[1], ".*[(]", ""), "^%l", string.upper)
  if not class_name then
    return false
  end

  -- make sure it has ( which means the function call
  if not string.find(full_word, cur_word .. '(', nil, true) then
    return false
  end
  -- print "is function call"
  local response = vim.fn.system('rg -n "fun ' .. cur_word .. '\\(" -g "!tags"')

  return fzf_pick_from_rg_response(open_cmd, response, class_name)
  -- local line = find_import_line(class_name)
  -- if line == nil then
    -- print "assume file in the same package"
    -- return jump_file_same_package(open_cmd, class_name)
  -- local fzf_pick_from_rg_response = require('java-source-finder.finder_strategies.helpers').fzf_pick_from_rg_response
  -- local convert_import_line_to_constant_file = require('java-source-finder.finder_strategies.helpers').convert_import_line_to_constant_file
  -- else
    -- local file_paths = convert_import_line_to_file_path(line)

    -- print "Try to jump"
    -- return try_to_jump(open_cmd, file_paths, class_name)
  -- end
end

return M
