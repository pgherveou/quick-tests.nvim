# quick-tests.nvim

A simple Neovim plugin that mimics the `Hover action` from [rustaceanvim](https://github.com/mrcjkb/rustaceanvim). It lets you run tests by hovering over them using your preferred keybinding.

Supports **Rust** (tests, benchmarks, and main functions) and **Deno** (TypeScript/JavaScript tests).

This plugin uses `Treesitter` for parsing the tests instead of LSP. While less accurate, this approach provides instantaneous responses compared to using language servers, which can be a time saver in large projects.

## Supported Languages

- **Rust**: Run tests (including doc tests), benchmarks, and main functions using `cargo`
- **TypeScript/JavaScript**: Run Deno.test() tests using `deno test`

![Screenshot 2024-02-01 at 15 04 51](https://github.com/pgherveou/quick-tests.nvim/assets/521091/fd7f28b3-03f3-40f5-bb08-fdd08dfe76c0)

# Installation

Example using [`lazy.nvim`](https://github.com/folke/lazy.nvim):

## For Rust only

```lua
return {
  'pgherveou/quick-tests.nvim',
  ft = { 'rust' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = true,
  keys = {
    {
      'K',
      function()
        require('quick-tests').hover_actions()
      end,
      desc = 'Rust tests Hover actions',
    },
    {
      '<leader>l',
      function()
        require('quick-tests').replay_last()
      end,
      desc = 'Replay last test',
    },
  },
}
```

## For both Rust and TypeScript/Deno

```lua
return {
  'pgherveou/quick-tests.nvim',
  ft = { 'rust', 'typescript', 'typescriptreact' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = true,
  keys = {
    {
      'K',
      function()
        require('quick-tests').hover_actions()
      end,
      desc = 'Quick tests Hover actions',
    },
    {
      '<leader>l',
      function()
        require('quick-tests').replay_last()
      end,
      desc = 'Replay last test',
    },
  },
}
```

# Usage

## Rust

Place your cursor on a test function, main function, or doc test, then use your configured keybinding (e.g., `K`) to show available actions. You can then run or debug the test/function.

Supported Rust test patterns:
- `#[test]` functions
- `#[tokio::test]` async tests
- `#[bench]` benchmarks
- Doc tests (/// ```)
- `fn main()` functions

## TypeScript/Deno

Place your cursor anywhere within a `Deno.test()` call and use your configured keybinding to run the test.

Supported Deno.test patterns:
```typescript
// String name pattern
Deno.test("test name", () => {
  // test code
});

// Object pattern
Deno.test({
  name: "test name",
  fn: () => {
    // test code
  },
});

// Named function pattern
Deno.test(function testName() {
  // test code
});
```

# Commands

## RustQuick

Set quick test options (Rust-specific).

Usage:

- RustQuick args <args> - Set extra args to pass to cargo run
- RustQuick release - Run tests in release mode
- RustQuick dev - Run tests in dev mode
- RustQuick env <args> - Set the environment variable
