import assert from "node:assert/strict";
import { test } from "node:test";

import { greeting } from "./index.js";

test("returns the greeting", () => {
  assert.equal(greeting(), "Hello, TypeScript!");
});
