---
name: domain-glossary
description: Build and maintain a repo-owned glossary of clear, consistent domain terms through an evidence-led interview. Use when defining ubiquitous language, resolving domain-language ambiguity, or creating a bounded-context glossary.
---

# Domain glossary

Build a durable glossary for the project's bounded context. The glossary defines the language people use to reason about the product. It does not document implementation-only names, internal helpers, or every technical noun in the repository.

Use `docs/domain-glossary.md` as the default source of truth. If the project already has an established glossary elsewhere, use that instead.

## Find facts before questions

1. Read the existing glossary first.
2. Read the public model before asking questions. Start with the README, architecture or design docs, public API, examples, and user-facing commands.
3. Find the terms that carry the most meaning across those sources. Prioritise terms that define boundaries, ownership, lifecycle, or the relationship between other concepts.
4. Exclude names that only live in code unless they represent a domain concept people must use outside that code.

Do not ask the user to supply facts that the repository can answer.

## Map the terms

Create a small candidate map before defining anything. Order it by dependency:

- Define foundational concepts before terms that depend on them.
- Prefer terms with the highest semantic blast radius.
- Defer a term when its definition depends on an unsettled term.
- Do not force a complete dictionary. A term belongs only when it supports the bounded context's ubiquitous language.

Briefly show the proposed order and why the first term is foundational. Do not present dependent questions in the same round.

## Interview in rounds

Settle one unblocked term at a time.

For the current term:

1. State the evidence from code and documentation.
2. State the ambiguity or decision that needs resolving.
3. Propose a definition and its boundaries.
4. Give a concise recommendation with the product consequence.
5. Ask only the question needed to settle that term. Use `ask_user_question` when the choices are bounded.

Use the glossary's existing terms as constraints. Do not silently redefine an established term to make a new term convenient.

## Handle conflicts explicitly

If current code, docs, or glossary entries disagree:

1. Show the specific conflicting evidence.
2. Explain the effect of each interpretation on the product model.
3. Stop and ask for an explicit decision before recording the definition.

Neither code nor documentation is automatically authoritative. A glossary entry records the decision after the conflict is settled.

## Write entries consistently

After agreement, record each term in this form:

```markdown
## Canonical term

A concise definition written in the project's present tense.

**Includes:** What belongs to this concept.
**Excludes:** Adjacent concepts that do not belong to it.
**Relationships:** How this concept connects to other defined terms.
```

Rules:

- Use one canonical spelling and casing for each term.
- Keep the definition independent of its examples and current implementation details.
- Use includes and excludes to distinguish easily-confused terms.
- Name relationships precisely. Do not use vague links such as "relates to".
- Do not add an entry until its dependencies are settled.
- Do not add a decision-history, evidence, or implementation section unless the project explicitly needs one.

When the user has asked to create or update the glossary, write agreed entries to the source-of-truth file. Otherwise, present the proposed entry without modifying files.

## Finish and maintain

The session ends when every candidate on the current frontier is either settled or deliberately deferred. Conclude with:

- settled terms and their decisions
- deferred terms and their prerequisite
- unresolved conflicts, if any
- glossary changes made

Run this skill when someone requests it, especially after a language disagreement or documentation problem. Do not turn it into a mandatory feature-planning step or automated check unless the project explicitly adopts that policy.
