local find_import_line = require('java-source-finder.finder_strategies.helpers').find_import_line
local convert_import_line_to_folder_path = require('java-source-finder.finder_strategies.helpers').convert_import_line_to_folder_path

local M = {}
-- Find class or interface in the folder by name, ripgrep search, open the file and jump to correct line
M.run = function(open_cmd)
  local cur_word = vim.fn.expand("<cword>")

  local import_line = find_import_line(cur_word)
  local paths

  if import_line == nil then
    paths = {vim.fn.expand("%:p:h")}
  else
    paths = convert_import_line_to_folder_path(import_line)
  end

  for _, path in ipairs(paths) do
    if vim.fn.isdirectory(path) == 0 then
      goto skip_to_next
    end

    local response = vim.fn.systemlist('rg -n "(class|interface|enum) ' .. cur_word .. '" ' .. path)
    if vim.fn.empty(response) == 0 then
      local results = vim.fn.split(response, "\n")

      for _, result in ipairs(results) do
        local split = vim.fn.split(result, ":")
        local file_path = split[1]
        local line_no = split[2]

        vim.cmd(open_cmd .. " +" .. line_no .. " " .. file_path)

        return true
      end
    end

    ::skip_to_next::
  end

  return false
end

return M
