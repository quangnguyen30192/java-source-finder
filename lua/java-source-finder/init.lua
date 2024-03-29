local find_in_same_package = require("java-source-finder.finder_strategies.find_in_same_package").run
local find_exact_match_path = require("java-source-finder.finder_strategies.find_exact_match_path").run
local find_class_interface_in_path = require("java-source-finder.finder_strategies.find_class_interface_in_path").run
local find_constant_definition = require("java-source-finder.finder_strategies.find_constant_definition").run
local find_function_definition = require("java-source-finder.finder_strategies.find_function_definition").run
local find_property_definition = require("java-source-finder.finder_strategies.find_property_definition").run
local M = {}

function M.run(...)
  vim.g.debug_enable = true
  local args = { ... }
  local open_cmd = args[0] or "e"
  local isFound = find_in_same_package(open_cmd)
    or find_exact_match_path(open_cmd)
    or find_class_interface_in_path(open_cmd)
    or find_constant_definition(open_cmd)
    or find_function_definition(open_cmd)
    or find_property_definition(open_cmd)
    or vim.fn["sourcer#OpenTheSourceUnderCursor"]() == 1

  -- find function definition improvement: for search by the cm 'rg -n " public ' .. method_name .. '\\(\\w+ \\w+"' at src and local project
  -- find enum definition
  -- refactor helpers
  -- convert sourcer to lua
  if not isFound then
    vim.cmd("AnyJump")
  end
end

return M
