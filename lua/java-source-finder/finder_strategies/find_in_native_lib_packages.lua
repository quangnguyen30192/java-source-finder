local is_symbol = require("java-source-finder.finder_strategies.helpers").is_symbol
local try_to_jump = require("java-source-finder.finder_strategies.helpers").try_to_jump

local M = {}

local function toJavaFile(package, symbol)
  return package .. "/" .. symbol .. ".java"
end

-- 
M.run = function(open_cmd)
  local cur_word = vim.fn.expand("<cword>")
  if not is_symbol(cur_word) then
    return false
  end

  local native_packages = {
    toJavaFile(vim.g.libPath .. "/java.base/java/lang", cur_word),
  }

  return try_to_jump(open_cmd, native_packages, cur_word)
end

return M

