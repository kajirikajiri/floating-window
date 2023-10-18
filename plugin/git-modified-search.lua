vim.api.nvim_command(
  "command! -nargs=* GitModifiedSearch lua require('git-modified-search').modified_lines_to_quick_fix(<q-args>)"
)
