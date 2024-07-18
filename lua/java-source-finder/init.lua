local find_in_same_package = require("java-source-finder.finder_strategies.find_in_same_package").run
local find_in_import_lines = require("java-source-finder.finder_strategies.find_in_import_lines").run
local find_class_interface_in_path = require("java-source-finder.finder_strategies.find_class_interface_in_path").run
local find_constant_definition = require("java-source-finder.finder_strategies.find_constant_definition").run
local find_function_definition = require("java-source-finder.finder_strategies.find_function_definition").run
local find_property_definition = require("java-source-finder.finder_strategies.find_property_definition").run
local find_in_native_lib_packages = require("java-source-finder.finder_strategies.find_in_native_lib_packages").run
local is_symbol = require("java-source-finder.finder_strategies.helpers").is_symbol

local M = {}

function M.setup(config)
  -- for plugin dev
  vim.g.debug_enable = false

  if vim.fn.isdirectory(config.local_library) == 0 then
    error("[JavaSourceFinder] local_library is misconfigured " .. config.local_library)
  end

  if vim.fn.isdirectory(config.package_manager_repository) == 0 then
    error("[JavaSourceFinder] package_manager_repository is misconfigured " .. config.package_manager_repository)
  end

  if vim.fn.isdirectory(config.java_runtime) == 0 then
    error("[JavaSourceFinder] java_runtime is misconfigured " .. config.java_runtime)
  end

  if vim.fn.filereadable(config.java_runtime .. "/lib/src.zip") == 0 then
    error("[JavaSourceFinder] java_runtime is misconfigured " .. config.java_runtime .. " could not find lib/src.zip")
  end

  if vim.fn.isdirectory(config.local_library .. "/java.base") == 0 then
    error("[JavaSourceFinder] Please run JavaSyncSources that java.base is missing from local_library ")
  end

  if vim.fn.isdirectory(config.plugin_path) == 0 then
    error("[JavaSourceFinder] plugin_path is misconfigured " .. config.plugin_path)
  end

  vim.g.java_source_finder_config = config

  vim.api.nvim_create_user_command("JavaFindSources", function()
    require("java-source-finder").run("edit")
  end, { nargs = 0 })

  vim.api.nvim_create_user_command("JavaSyncSources", function()
    vim.cmd(
      "terminal "
        .. config.plugin_path
        .. "/bin/sync_sources.sh "
        .. config.local_library
        .. " "
        .. config.package_manager_repository
        .. " "
        .. config.java_runtime
        .. "/lib/src.zip"
    )
  end, { nargs = 0 })
end

function M.run(...)
  local args = { ... }
  local open_cmd = args[0] or "e"

  local cur_word = vim.fn.expand("<cword>")

  if is_symbol(cur_word) then
    return find_in_same_package(open_cmd, cur_word, cur_word)
      or find_in_native_lib_packages(open_cmd, cur_word)
      or find_in_import_lines(open_cmd, cur_word)
      or find_class_interface_in_path(open_cmd, cur_word)
      or find_constant_definition(open_cmd)
  end

  local isFound = find_function_definition(open_cmd)
    or find_property_definition(open_cmd)
    or vim.fn["sourcer#OpenTheSourceUnderCursor"]() == 1

  if not isFound then
    vim.cmd("AnyJump")
  end
end

return M
