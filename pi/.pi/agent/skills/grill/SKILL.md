---
name: grill
description: Relentlessly stress-test a plan, architecture decision, problem framing, or idea. Use when the user asks to be grilled, challenged, or wants to stress-test their thinking.
---

# Grilling

Stress-test a proposal by mapping it as a **decision tree**: foundational constraints branch into dependent trade-offs.

Work in **rounds**. The **frontier** is the set of unblocked questions whose prerequisites are already settled.

## Rules of engagement

1. **Find facts first**: Check the codebase, configs, and docs before asking. Never ask the user something a search or file read can answer.
2. **One level at a time**: Never ask downstream questions before foundational decisions are settled.
3. **Be opinionated and concise**: For every question on the frontier:
   - State the core trade-off or risk in one or two sentences.
   - Give a concrete recommendation.
   - If options are bounded (2–4 distinct choices), use `ask_user_question`.
4. **Push back on weak assumptions**: Challenge vague requirements, unhandled failure modes, and premature optimization directly.
5. **Exit condition**: The session ends when the frontier is empty (all branches explored, no unstated assumptions remain).

## Output

Conclude with a concise settled summary:
- **Core decisions**: What was chosen and why.
- **Accepted trade-offs**: What risks or compromises were consciously taken.
- **Ruled out**: What alternatives were discarded.
- **Next steps**: What becomes unblocked (e.g. implementation, RFC, or dropping the idea).
