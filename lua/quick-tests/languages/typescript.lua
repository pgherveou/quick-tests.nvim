-- TypeScript/Deno language support for quick tests
local M = {}

local Path = require('plenary.path')
local config = require('quick-tests.config')
local Command = require('quick-tests.command')

-- Tree-sitter query to find Deno.test() calls
local query_str = [[
  ; Match Deno.test("name", fn) pattern
  (call_expression
    function: (member_expression
      object: (identifier) @deno_obj
      property: (property_identifier) @test_method
    )
    arguments: (arguments
      .
      [
        (string
          (string_fragment) @test.name
        )
        (template_string) @test.name
      ]
    ) @test.args
    (#eq? @deno_obj "Deno")
    (#eq? @test_method "test")
  ) @test.call

  ; Match Deno.test({ name: "...", fn: ... }) pattern
  (call_expression
    function: (member_expression
      object: (identifier) @deno_obj2
      property: (property_identifier) @test_method2
    )
    arguments: (arguments
      (object
        (pair
          key: (property_identifier) @name_key
          value: [
            (string
              (string_fragment) @test.name2
            )
            (template_string) @test.name2
          ]
        )
      )
    ) @test.args2
    (#eq? @deno_obj2 "Deno")
    (#eq? @test_method2 "test")
    (#eq? @name_key "name")
  ) @test.call2

  ; Match Deno.test(function testName() {}) pattern
  (call_expression
    function: (member_expression
      object: (identifier) @deno_obj3
      property: (property_identifier) @test_method3
    )
    arguments: (arguments
      (function_expression
        name: (identifier) @test.name3
      )
    ) @test.args3
    (#eq? @deno_obj3 "Deno")
    (#eq? @test_method3 "test")
  ) @test.call3
]]

-- Find deno.json or deno.jsonc in the project
---@param file Path
---@return Path | nil
local function find_deno_json(file)
  local deno_json = file:find_upwards('deno.json')
  if deno_json ~= '' then
    return deno_json
  end

  local deno_jsonc = file:find_upwards('deno.jsonc')
  if deno_jsonc ~= '' then
    return deno_jsonc
  end

  return nil
end

-- Get project root (directory containing deno.json or fallback to file directory)
---@param file Path
---@return Path
local function get_project_root(file)
  local deno_json = find_deno_json(file)
  if deno_json then
    return deno_json:parent()
  end
  return file:parent()
end

-- Create test runnable for Deno.test
---@param bufnr number
---@param test_name string
---@param file_path string
---@return table
local function make_test_runnable(bufnr, test_name, file_path)
  local file = Path:new(file_path)
  local project_root = get_project_root(file)
  local relative_file = file:make_relative(project_root:absolute())

  -- Build the filter pattern for the specific test
  -- Escape regex special characters in test name
  local escaped_name = test_name:gsub('[%.%*%+%?%^%$%(%)%[%]%{%}%|%\\]', '%%%1')
  local filter_pattern = string.format('/%s/', escaped_name)

  local cfg = config.cwd_config()
  local runCommand = {
    command = Command:new({
      file = file:absolute(),
      cursor = vim.api.nvim_win_get_cursor(0),
      command = 'deno',
      manifest_path = project_root:absolute(),
      env = cfg:getEnv(),
      args = {
        'test',
        '-P',
        '--filter',
        filter_pattern,
        relative_file,
      },
    }),
    type = 'run',
    title = '▶︎ Run Test',
    tooltip = 'test ' .. test_name,
  }

  return {
    actions = {
      {
        commands = {
          runCommand,
        },
      },
    },
    contents = {
      kind = 'markdown',
      value = string.format(
        '# Deno Test\n```typescript\nDeno.test("%s", ...)\n```',
        test_name
      ),
    },
  }
end

-- check if cursor is in the same row as `node`
---@param node TSNode
---@param cursor integer[]
---@return boolean
local function is_cursor_in_row(node, cursor)
  local start_row, _, end_row, _ = node:range()
  local cursor_row = cursor[1] - 1
  return cursor_row >= start_row and cursor_row <= end_row
end

-- Get TypeScript/Deno runnable for the buffer and cursor position
---@param bufnr number
---@param cursor table
---@return table | nil
function M.find_runnable(bufnr, cursor)
  local file_path = vim.api.nvim_buf_get_name(bufnr)

  local parser = vim.treesitter.get_parser(bufnr, 'typescript')
  local tree = parser:parse()[1]
  local query = vim.treesitter.query.parse('typescript', query_str)

  for id, node, _ in query:iter_captures(tree:root(), bufnr, 0, -1) do
    local capture_name = query.captures[id]

    -- Check if cursor is on this test call
    if capture_name:match('^test%.call') then
      if is_cursor_in_row(node, cursor) then
        -- Find the corresponding test name
        local test_name = nil

        -- Re-iterate to find the test name within this call
        for inner_id, inner_node, _ in query:iter_captures(node, bufnr, 0, -1) do
          local inner_capture = query.captures[inner_id]
          if inner_capture == 'test.name' or inner_capture == 'test.name2' or inner_capture == 'test.name3' then
            test_name = vim.treesitter.get_node_text(inner_node, bufnr)
            break
          end
        end

        if test_name then
          return make_test_runnable(bufnr, test_name, file_path)
        end
      end
    end
  end

  return nil
end

return M
