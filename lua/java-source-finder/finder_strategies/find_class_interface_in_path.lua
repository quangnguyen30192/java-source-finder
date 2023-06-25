local find_import_line = require('java-source-finder.finder_strategies.helpers').find_import_line
local convert_import_line_to_folder_path = require('java-source-finder.finder_strategies.helpers').convert_import_line_to_folder_path

local M = {}
-- Find class or interface in the folder by name, ripgrep search, open the file and jump to correct line
M.run = function(open_cmd)
  -- print "jump_to_class_interface_in_path"
  local cur_word = vim.fn.expand("<cword>")

  local line = find_import_line(cur_word)
  local paths

  if line == nil then
    paths = {vim.fn.expand("%:p:h")}
  else
    paths = convert_import_line_to_folder_path(line)
  end

  for _, path in ipairs(paths) do
    if vim.fn.isdirectory(path) == 0 then
      goto skip_to_next
    end

    local response = vim.fn.system('rg -n "(class|interface) ' .. cur_word .. '[<( {]" ' .. path)

    if response ~= "" then
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
