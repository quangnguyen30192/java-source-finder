local is_symbol = require("java-source-finder.finder_strategies.helpers").is_symbol
local try_to_jump = require("java-source-finder.finder_strategies.helpers").try_to_jump

local M = {}

local function toJavaFile(package, symbol)
  return package .. "/" .. symbol .. ".java"
end

M.run = function(open_cmd, symbol)
  local native_packages = {
    toJavaFile(vim.g.java_source_finder_config.local_library .. "/java.base/java/lang", symbol),
  }

  return try_to_jump(open_cmd, native_packages, symbol)
end

return M

