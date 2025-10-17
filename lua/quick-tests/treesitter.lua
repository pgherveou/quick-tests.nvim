-- Treesitter dispatcher module
-- This module detects the file language and dispatches to the appropriate language module
local M = {}

--- Find runnable for the buffer and cursor position
--- Dispatches to language-specific modules based on filetype
---@param bufnr number
---@param cursor table
---@return table | nil
M.find_runnable = function(bufnr, cursor)
  local language = require('quick-tests.language')
  local lang_module = language.get_language_module(bufnr)

  if lang_module == nil then
    return nil
  end

  return lang_module.find_runnable(bufnr, cursor)
end

return M
