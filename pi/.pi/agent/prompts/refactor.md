---
description: Refactor code following a specific pattern or goal
argument-hint: "<description of refactor>"
---

Refactor the following. Do NOT change behaviour — only restructure.

$@

## Constraints
- Keep the same public API / exports
- Keep existing tests passing
- Do not add new functionality
- Do not introduce new dependencies unless specified

## Output
For each change, show:

### File
`path/to/file.ts`

### Before
```typescript
// existing code
```

### After
```typescript
// refactored code
```

### Rationale
Why this change improves the code