-- main module file
local module = require("git-modified-search.module")

---@class Config
---@field opt string Your config option
local config = {
  opt = nil,
}

---@class MyModule
local M = {}

---@type Config
M.config = config

---@param args Config?
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

local function split_args(args)
  local my_args = vim.split(args, " ")
  local first_arg = table.remove(my_args, 1)
  local commit = first_arg
  local search_word = table.concat(my_args, " ")
  return commit, search_word
end

M.modified_lines_to_quick_fix = function(args)
  local commit, search_word = split_args(args)
  module.modified_lines_to_quick_fix(commit, search_word)
end

return M
