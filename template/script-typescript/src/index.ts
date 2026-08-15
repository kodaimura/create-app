import { pathToFileURL } from "node:url";

export function greeting(): string {
  return "Hello, TypeScript!";
}

const entrypoint = process.argv[1];
if (entrypoint && import.meta.url === pathToFileURL(entrypoint).href) {
  console.log(greeting());
}
