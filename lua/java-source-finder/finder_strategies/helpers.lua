local fzf = require("fzf")
local M = {}

function file_exists(name)
  local f = io.open(name, "r")
  return f ~= nil and io.close(f)
end

function esc(x)
  return (
    x:gsub("%%", "%%%%")
      :gsub("^%^", "%%^")
      :gsub("%$$", "%%$")
      :gsub("%(", "%%(")
      :gsub("%)", "%%)")
      :gsub("%.", "%%.")
      :gsub("%[", "%%[")
      :gsub("%]", "%%]")
      :gsub("%*", "%%*")
      :gsub("%+", "%%+")
      :gsub("%-", "%%-")
      :gsub("%?", "%%?")
  )
end

-- Loop through every lines in current buffer
-- Find the first line contains the class or interface with given name
local function find_definitions_in_file(word)
  for i = 1, vim.fn.line("$"), 1 do
    local l = vim.fn.getbufline(vim.fn.bufnr(), i)[1]

    if string.find(l, "class " .. word) ~= nil
            or string.find(l, "interface " .. word) ~= nil
            or string.find(l, "enum " .. word) ~= nil
            or string.match(l, "public %w+ " .. word)
            or string.match(l, "public %w+ %w+ " .. word)
        then
      return i
    end
  end

  return nil
end

-- Loop through every lines in current buffer
-- Find the first line contains the word
local function find_word_in_file(word)
  for i = 1, vim.fn.line("$"), 1 do
    local l = vim.fn.getbufline(vim.fn.bufnr(), i)[1]

    if string.find(l, word) ~= nil then
      return i
    end
  end

  return nil
end

-- Jump to the file at exact line if the file is existed
M.try_to_jump = function(open_cmd, paths, word)
  -- vim.print(paths)
  for _, path in ipairs(paths) do
    if file_exists(path) then
      vim.cmd(open_cmd .. " " .. path)
      local found_line = find_definitions_in_file(word) or find_word_in_file(word)
      vim.cmd(tostring(found_line))

      return true
    end
  end

  return false
end

-- The file can be in library or project, try to build file path using all possible source location
M.build_paths = function(paths, file_path)
  local project_path = vim.fn.getcwd(0)

  table.insert(paths, vim.g.libPath .. "/" .. file_path)
  table.insert(paths, vim.g.libPath .. "/java.base/" .. file_path)

  for _, src_path in ipairs(vim.g.srcPath) do
    table.insert(paths, project_path .. src_path .. file_path)
  end
end

-- Loop through all lines in file, try to find the line with import pattern "import ... word$"
M.find_import_line = function(word)
  for i = 1, vim.fn.line("$"), 1 do
    local line = vim.fn.getbufline(vim.fn.bufnr(), i)[1]

    if string.find(line, "import") == 1 and string.match(line, "[.]" .. word .. ";$") ~= nil then
      return line
    end

  end

  return nil
end

M.convert_import_line_to_file_path = function(line)
  local words = vim.fn.split(line, [[\W\+]])
  table.remove(words, 1)
  local relative_path = table.concat(words, "/")

  local paths = {}

  M.build_paths(paths, relative_path .. ".java")
  -- vim.print(paths)

  return paths
end

M.convert_import_line_to_folder_path = function(line)
  local words = vim.fn.split(line, [[\W\+]])
  table.remove(words, #words)
  table.remove(words, 1)
  local relative_path = table.concat(words, "/")
  local paths = {}

  M.build_paths(paths, relative_path)

  return paths
end

M.fzf_pick_from_rg_response = function(open_cmd, response, class_name)
  if response ~= "" then
    local results = vim.fn.split(response, "\n")

    local pickable = {}
    local data = {}

    -- Build data and pickable options for fuzzy search
    for _, result in ipairs(results) do
      local sp = vim.fn.split(result, ":")
      table.insert(data, sp)
      local file = sp[1]
      -- file = string.gsub(file, esc(vim.fn.getcwd(0)), "")
      local sample_code = string.gsub(sp[3], "%s+ ", "")
      for _, src_path in ipairs(vim.g.srcPath) do
        -- file = string.gsub(file, esc(src_path), "")
        file = vim.fn.fnamemodify(file, ":p:t")
      end

      -- collect files matches with the given class_name the
      -- print(class_name)
      if class_name == nil then
        table.insert(pickable, sample_code .. " -> " .. file)
      else
        if string.find(file:lower(), class_name:lower() .. ".java") then
          table.insert(pickable, sample_code .. " -> " .. file)
        end

        if not pickable[1] then
          return M.fzf_pick_from_rg_response(open_cmd, response)
        end
      end
    end

    -- vim.print(data)
    if #data == 1 then
      -- Jump to file directly if there is only one result
      local line_no = data[1][2]
      local file_path = data[1][1]

      vim.cmd(open_cmd .. " +" .. line_no .. " " .. file_path)
      return true
    else
      -- vim.print(pickable)
      if next(pickable) then
        -- Use fuzzy search if there are many possible results
        coroutine.wrap(function()
          local selections = fzf.fzf(pickable, "--ansi", { width = 250, height = 60 })
          for _, select in ipairs(selections) do
            r = select
          end
          local i = tonumber(string.sub(r, 1, 1))
          local line_no = data[i][2]
          local file_path = data[i][1]

          vim.cmd(open_cmd .. " +" .. line_no .. " " .. file_path)
        end)()
        return true
      else
        return false
      end
    end
  end
end

M.convert_import_line_to_constant_file = function(line)
  local words = vim.fn.split(line, [[\W\+]])
  table.remove(words, #words)
  table.remove(words, 1)
  local file_path = table.concat(words, "/")
  local paths = {}

  M.build_paths(paths, file_path .. ".java")

  return paths
end

M.convert_import_line_to_package_paths = function(import_line)
  local words = vim.fn.split(import_line, [[\W\+]])
  table.remove(words, #words)
  table.remove(words, 1)
  local file_path = table.concat(words, "/")
  local paths = {}

  M.build_paths(paths, file_path)

  return paths
end

M.debug = function(...)
    if vim.g.debug_enable then
        vim.print(...)
    end
end

return M
