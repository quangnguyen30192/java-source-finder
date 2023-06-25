local find_import_line = require('java-source-finder.finder_strategies.helpers').find_import_line
local try_to_jump = require('java-source-finder.finder_strategies.helpers').try_to_jump
local fzf_pick_from_rg_response = require('java-source-finder.finder_strategies.helpers').fzf_pick_from_rg_response
local convert_import_line_to_constant_file = require('java-source-finder.finder_strategies.helpers').convert_import_line_to_constant_file
local convert_import_line_to_file_path = require('java-source-finder.finder_strategies.helpers').convert_import_line_to_file_path
local M = {}

local function filter_existing_folders(folders)
  local result = {}

  for _, folder in ipairs(folders) do
    if vim.fn.isdirectory(folder) == 1 then
      table.insert(result,folder)
    end
  end

  return result
end

M.run = function(open_cmd)
  -- print "jump_to_constant"
  local cur_word = vim.fn.expand("<cword>")
  local full_word = vim.fn.expand("<cWORD>")

  -- Check contants pattern, return if not
  if string.match(cur_word, "[%u_]+") ~= cur_word then
    return
  end

  local prev_i = string.find(full_word, cur_word) - 1
  local prev_char = string.sub(full_word, prev_i, prev_i)

  if prev_char ~= "." then
    -- the case when import the constant
    -- ex: import.domain.imports.models.ImportStatus.PENDING
    -- const: PENDING
    local line = find_import_line(cur_word)

    if line == nil then
      local path = vim.fn.expand("%:p:h")

      local response = vim.fn.system('rg -n "val ' .. cur_word .. '" ' .. path)

      return fzf_pick_from_rg_response(open_cmd, response)
    else
      local file_paths = convert_import_line_to_constant_file(line)

      local found = try_to_jump(open_cmd, file_paths, cur_word)

      if not found then
        local package_paths = convert_import_line_to_package_paths(line)
        local existing_folders = filter_existing_folders(package_paths)
        local search_folders = table.concat(existing_folders, " ")

        local response = vim.fn.system('rg -n "val ' .. cur_word .. '" ' .. search_folders)

        return fzf_pick_from_rg_response(open_cmd, response)
      end
    end
  else
    -- the case when import the class of constant
    -- ex: import.domain.imports.models.ImportStatus
    -- const: ImportStatus.PENDING

    -- full_word in form of "TestClass.ABC_DEF," or "Abc(TestClass.ABC_DEF)"
    local kw = vim.fn.split(full_word, [[\.]])
    local class_name = string.gsub(kw[1], ".*[(]", "")
    local constant = string.match(kw[2], "[%u_]+")

    local line = find_import_line(class_name)

    if line == nil then
      local path = vim.fn.expand("%:p:h")

      local response = vim.fn.system('rg -n "val ' .. cur_word .. '" ' .. path)

      return fzf_pick_from_rg_response(open_cmd, response)
    else
      local file_paths = convert_import_line_to_file_path(line)

      return try_to_jump(open_cmd, file_paths, constant)
    end
  end
end

return M
