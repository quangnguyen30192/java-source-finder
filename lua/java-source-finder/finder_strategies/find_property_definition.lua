local try_to_jump = require("java-source-finder.finder_strategies.helpers").try_to_jump
local M = {}

-- find the property with the pattern: var a = b;
M.run = function(open_cmd)
  local property = vim.fn.expand("<cword>")
  local pattern = ' ' .. property .. ' = '

  local search_property_definition_cmd = 'rg -U -t java --files-with-matches -n "' .. pattern .. '"'
  local files_matched = vim.fn.systemlist(search_property_definition_cmd)

  return try_to_jump(open_cmd, files_matched, pattern)
end

return M
