local find_in_same_package = require("java-source-finder.finder_strategies.find_in_same_package").run
local find_in_import_lines = require("java-source-finder.finder_strategies.find_in_import_lines").run
local find_class_interface_in_path = require("java-source-finder.finder_strategies.find_class_interface_in_path").run
local find_constant_definition = require("java-source-finder.finder_strategies.find_constant_definition").run
local find_function_definition = require("java-source-finder.finder_strategies.find_function_definition").run
local find_property_definition = require("java-source-finder.finder_strategies.find_property_definition").run
local find_in_native_lib_packages = require('java-source-finder.finder_strategies.find_in_native_lib_packages').run
vim.g.debug_enable = false

local M = {}

function M.run(...)
  local args = { ... }
  local open_cmd = args[0] or "e"
  local isFound = find_in_same_package(open_cmd)
    or find_in_native_lib_packages(open_cmd)
    or find_in_import_lines(open_cmd)
    or find_class_interface_in_path(open_cmd)
    or find_constant_definition(open_cmd)
    or find_function_definition(open_cmd)
    or find_property_definition(open_cmd)
    or vim.fn["sourcer#OpenTheSourceUnderCursor"]() == 1

  if not isFound then
    vim.cmd("AnyJump")
  end
end

return M
