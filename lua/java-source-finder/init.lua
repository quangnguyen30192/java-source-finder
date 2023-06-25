local find_in_same_package = require('java-source-finder.finder_strategies.find_in_same_package').run
local find_exact_match_path = require('java-source-finder.finder_strategies.find_exact_match_path').run
local find_class_interface_in_path = require('java-source-finder.finder_strategies.find_class_interface_in_path').run
local find_constant_definition = require('java-source-finder.finder_strategies.find_constant_definition').run
local find_function_definition = require('java-source-finder.finder_strategies.find_function_definition').run
local find_property_definition = require('java-source-finder.finder_strategies.find_property_definition').run
local M = {}

function M.run(...)
  local args = {...}
  local open_cmd = args[0] or "e"
  local isFound = false

  isFound = isFound or find_in_same_package(open_cmd)
  isFound = isFound or find_exact_match_path(open_cmd)
  isFound = isFound or find_class_interface_in_path(open_cmd)
  isFound = isFound or find_constant_definition(open_cmd)
  isFound = isFound or find_function_definition(open_cmd)
  isFound = isFound or find_property_definition(open_cmd)
end

return M
