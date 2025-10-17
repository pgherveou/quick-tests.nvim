-- Language detection and dispatcher module
local M = {}

--- Get the language module for a given buffer
---@param bufnr number
---@return table | nil
function M.get_language_module(bufnr)
  local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')

  if filetype == 'rust' then
    return require('quick-tests.languages.rust')
  elseif filetype == 'typescript' or filetype == 'typescriptreact' then
    return require('quick-tests.languages.typescript')
  end

  return nil
end

--- Check if a buffer's language is supported
---@param bufnr number
---@return boolean
function M.is_supported(bufnr)
  return M.get_language_module(bufnr) ~= nil
end

return M
