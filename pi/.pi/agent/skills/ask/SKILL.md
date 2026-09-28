---
name: ask
description: Ask the user a bounded decision question with options. Use when you need the user to choose between alternatives, answer a clarifying question, or make a preference call. Not for open-ended exploration — use ask only when the user's choice drives your next action.
---

# ask tool — usage guide

The `ask` tool presents the user with a question and a set of options. It supports single-select, multi-select, and custom text input ("Type something."). This skill tells you when and how to use it effectively.

## When to use ask

Use the `ask` tool when:

- You need the user to **choose between concrete alternatives** (e.g. "REST or GraphQL?", "Module A or Module B?")
- A **clarifying question** has 2-4 well-defined answers (e.g. "Should this handle auth? Yes/No/Only for admins")
- You need a **preference or decision** before proceeding (e.g. "Which colour scheme?")
- The user's choice **changes what you do next** (e.g. "Should I implement this now or propose a plan first?")

Do NOT use `ask` when:

- The question is open-ended with no bounded set of answers — just ask directly instead
- You can figure out the answer from the repository (read files, grep, check configs)
- You're gathering requirements in an unstructured way (just have a conversation)
- The options are obvious from context and the user already stated their preference

## Provide self-contained context

**This is the most important rule.** The `ask` tool's overlay replaces the main terminal content area. The user cannot see the conversation transcript while answering. You MUST include enough context in the `context` field for the user to make the decision without scrolling back.

### Good context

| Do this | Don't do this |
|---------|---------------|
| "We're choosing an API protocol. The service handles user auth and profile management. Expected peak: 10k req/s." | "Same protocol question we discussed earlier" |
| "The test suite takes 45s. Options: run on every push (slow CI) or only on PR merge (faster but riskier)." | "You know the test timing problem" |
| "Three files need the new interface: `auth.ts`, `profile.ts`, `admin.ts`. Each has ~200 lines." | "As I mentioned before..." |

### How to write good context

1. **State the decision** first: "We need to decide X because Y."
2. **Include the essential facts** the user needs: numbers, trade-offs, constraints, affected files.
3. **Be concise**: enough to decide, no more. If it takes more than 3-4 sentences, the question might need splitting.
4. **Assume no memory of earlier turns**: the user sees *only* what you put in `context` and `question`.

```json
{
  "name": "ask",
  "arguments": {
    "context": "Refactoring the auth module. Two approaches:\n- Option A: simpler code but couples auth to the HTTP layer\n- Option B: more abstract (interface + adapter) but 3x more boilerplate\nNo deadline pressure — take whichever is easier to maintain.",
    "question": "Which abstraction level should we use?",
    "options": [
      { "label": "Simple (HTTP-coupled)", "description": "Less code, harder to swap transports" },
      { "label": "Abstract (interface + adapter)", "description": "More boilerplate, cleaner boundaries" }
    ]
  }
}
```

## Tool capabilities

- **Single-select** — ↑↓ navigate, Enter to confirm
- **Multi-select** — ↑↓ navigate, Space to toggle, Enter to confirm all selections
- **Custom input** — Arrow to "Type something." and Enter opens an inline editor
- **Context scroll** — Use Tab to switch focus between the context area (↑↓ scrolls) and the options panel

## Parameter reference

```
ask({
  question:  string,              // required — self-contained question
  options:   [{label, value?, description?}],  // required — 2-4 options
  context:   string,              // optional — self-contained decision context
  multiSelect: boolean,           // optional — defaults to false
})
```

- `label` is displayed to the user.
- `value` is what the tool returns (defaults to `label` if omitted). Use when the programmatic value differs from the display text.
- `description` is shown below the option in muted text. Use for brief trade-off notes, not essays.