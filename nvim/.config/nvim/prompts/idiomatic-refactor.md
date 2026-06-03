---
name: Idiomatic Refactor
interaction: chat
description: Refactor the current buffer to idiomatic style for its language
tools:
  - insert_edit_into_file
opts:
  auto_submit: true
---

## system

You are an expert in writing idiomatic, production-quality code.
You refactor code to follow the conventions and best practices of the language it's written in.
You do not change behaviour — only style, structure, and idioms.

## user

Please refactor the file `${context.filename}` to be more idiomatic ${context.filetype}.

Use `insert_edit_into_file` to apply your changes directly.

Apply the following language-specific guidance:

**Rust:**
- Prefer iterators and combinators over manual loops
- Replace `unwrap()`/`expect()` with proper error propagation using `?`
- Use `thiserror` or `anyhow` patterns for error types where appropriate
- Prefer `if let` / `match` over nested conditionals
- Use guard clauses (early returns) to reduce nesting
- Avoid unnecessary clones; prefer borrowing

**Go:**
- Use guard clauses — handle errors and edge cases early, return early
- Prefer table-driven tests
- Keep functions small and focused
- Use named return values only when they genuinely aid clarity
- Prefer explicit over clever

**TypeScript / JavaScript:**
- Prefer `const` over `let`; avoid `var`
- Use optional chaining (`?.`) and nullish coalescing (`??`) where appropriate
- Prefer `async`/`await` over raw promise chains
- Use destructuring where it aids readability
- Avoid `any`; use proper types or `unknown`
- Prefer early returns over deeply nested if/else

**Lua:**
- Use `local` for all variables
- Prefer idiomatic Neovim API patterns
- Keep functions small and purposeful
- Avoid global state

Focus on the issues that matter most for `${context.filetype}`. If the code is already idiomatic, say so briefly and make no changes.
