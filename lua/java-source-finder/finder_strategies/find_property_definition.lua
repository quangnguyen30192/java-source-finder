local fzf_pick_from_rg_response = require('java-source-finder.finder_strategies.helpers').fzf_pick_from_rg_response
local M = {}

M.run = function(open_cmd)
  -- print("jump_to_properties_definition")
  local cur_word = vim.fn.expand("<cword>")
  local full_word = vim.fn.expand("<cWORD>")

  if not string.find(full_word, ".") then
    return false
  end

  -- make sure it has ( which means the function call
  if string.find(full_word, cur_word .. '(', nil, true) then
    return false
  end
  -- print "is prop call"
  local kw = vim.fn.split(full_word, [[\.]])

  -- assume class_name is the first part of kw with first capitalize letter
  local class_name = string.gsub(string.gsub(kw[1], ".*[(]", ""), "^%l", string.upper)
  if not class_name then
    return false
  end

  local varResponse = vim.fn.system('rg -n "' .. cur_word .. ' ="')

  -- print "call here"
  local found = fzf_pick_from_rg_response(open_cmd, varResponse, class_name)
  if not found then
    local valResponse = vim.fn.system('rg -n "' .. cur_word .. ' ="')

    return fzf_pick_from_rg_response(open_cmd, valResponse, class_name)
  end

  return found
end

return M
