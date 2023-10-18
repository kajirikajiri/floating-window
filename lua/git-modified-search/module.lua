---@class CustomModule
local M = {}

local function get_filenames_between_head(commit)
  local filenames = vim.fn.systemlist("git diff --diff-filter=AM --name-only " .. commit .. " HEAD")
  return filenames
end

local function get_commit_hashes_between_head(commit)
  local commit_hashes = vim.fn.systemlist("git log --pretty=format:%h --abbrev=8 " .. commit .. "..HEAD")
  return commit_hashes
end

local function get_commit_hash_pattern_between_head(commit)
  local commit_hashes = get_commit_hashes_between_head(commit)
  local commit_hash_pattern = table.concat(commit_hashes, "|")
  return commit_hash_pattern
end

local function get_blame_with_pattern(filename, commit_hash_pattern)
  local blame = vim.fn.systemlist("git blame --date=short " .. filename .. "| grep -E '" .. commit_hash_pattern .. "'")
  return blame
end

local function valid_regex(str)
  local result = vim.fn.system('echo "" | grep -E "' .. str .. '" >/dev/null 2>&1 || echo "ng"')
  local is_valid = result == ""
  return is_valid
end

local function search_word_with_regex(str, word_to_search)
  -- 'をエスケープ
  str = string.gsub(str, "'", "'\\''")
  local result = vim.fn.system("echo '" .. str .. "' | grep -E '" .. word_to_search .. "'")
  local is_exists = result ~= ""
  return is_exists
end

local function search_word_with_str(str, word_to_search)
  -- 'をエスケープ
  str = string.gsub(str, "'", "'\\''")
  local word_to_searchs = vim.split(word_to_search, " ")
  for _, word in ipairs(word_to_searchs) do
    local result = vim.fn.system("echo '" .. str .. "' | grep '" .. word .. "'")
    local is_exists = result ~= ""
    if is_exists ~= true then
      return false
    end
  end
  return true
end

local function search_word(str, word_to_search)
  local is_valid = valid_regex(word_to_search)
  if is_valid then
    return search_word_with_regex(str, word_to_search)
  else
    return search_word_with_str(str, word_to_search)
  end
end

local function split_blame_line(blame_line)
  local line_number, source_code = blame_line:match("^%x+.*%d%d%d%d%-%d%d%-%d%d%s+(%d+)%) (.*)$")
  return line_number, source_code
end

M.get_modified_lines = function(commit, word_to_search)
  if commit == "" then
    commit = "HEAD~1"
  end
  local modified_lines = {}
  local filenames = get_filenames_between_head(commit)
  local commit_hash_pattern = get_commit_hash_pattern_between_head(commit)
  for _, filename in ipairs(filenames) do
    local blame = get_blame_with_pattern(filename, commit_hash_pattern)
    for _, blame_line in ipairs(blame) do
      local line_number, source_code = split_blame_line(blame_line)
      if word_to_search ~= nil then
        local is_exists = search_word(source_code, word_to_search)
        if is_exists ~= true then
          goto continue
        end
      end
      table.insert(modified_lines, { filename = filename, lnum = line_number, text = source_code })
      ::continue::
    end
  end
  return modified_lines
end

M.modified_lines_to_quick_fix = function(commit, word_to_search)
  local modified_lines = M.get_modified_lines(commit, word_to_search)
  vim.cmd("copen")
  vim.fn.setqflist(modified_lines)
end

return M
