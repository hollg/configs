---
description: Review code or staged changes with structured output
argument-hint: "[focus]"
---

Review the code. Use this structured checklist:

## Correctness
Logic errors, race conditions, off-by-one, edge cases

## Type Safety
Missing generics, implicit any, narrowable types, assertion safety

## Error Handling
Unhandled rejections, swallowed errors, missing error boundaries

## Testing
Missing coverage for the changed paths, testing the right things

## Maintainability
Dead code, duplicated logic, unclear naming, overly complex functions

Focus: ${1:-all areas}

Output format:

## Files Reviewed
- path (lines X-Y) - purpose

## Critical (must fix)
- file.ts:42 - description with why

## Warnings (should fix)
- file.ts:100 - description

## Suggestions (consider)
- file.ts:150 - improvement idea

## Summary
2-3 sentence overall assessment