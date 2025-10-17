// Example Deno test file to demonstrate the plugin's TypeScript support

// String name pattern
Deno.test("addition test", () => {
  const result = 2 + 2;
  if (result !== 4) throw new Error("Math is broken!");
});

// Object pattern
Deno.test({
  name: "async test example",
  fn: async () => {
    const promise = Promise.resolve(42);
    const result = await promise;
    if (result !== 42) throw new Error("Promise failed!");
  },
});

// Named function pattern
Deno.test(function stringOperations() {
  const str = "hello";
  if (str.toUpperCase() !== "HELLO") {
    throw new Error("String operations failed!");
  }
});

// Object with permissions
Deno.test({
  name: "file system test",
  permissions: { read: true },
  fn: () => {
    // This would need actual file system operations
    console.log("Testing file system operations");
  },
});
