---
name: tdd
description: Write tests first, then implement. Use when adding features or fixing bugs with test-first discipline.
---

## TDD workflow

When asked to implement a feature or fix a bug, follow the Red-Green-Refactor cycle:

### 1. Red — Write a failing test
- Write the test that describes the desired behaviour *before* writing the implementation
- The test defines the interface — let it drive the design
- Run the test to confirm it fails (this proves the test is valid)

### 2. Green — Make the test pass
- Write the *minimum* implementation code needed to pass the test
- Do not add extras, optimise prematurely, or refactor yet
- Run the test again — it should pass

### 3. Refactor — Clean up while green
- Improve the implementation without changing behaviour
- Keep the test passing at all times
- Remove duplication, improve naming, simplify

### Rules
- Never write implementation before the test exists for that behaviour
- If the test won't compile, fix the test-contract mismatch before writing implementation code
- The test suite must be runnable: show the command needed to run it
- At the end, report: `Test: <path> — Red (failing as expected) → Green (passing) → Refactored`

### When to use this skill
Load this skill when the task involves:
- Adding a new feature that needs test coverage
- Fixing a bug where a regression test would prevent reoccurrence
- Adding edge-case tests to existing code