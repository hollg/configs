---
description: Debug an error, bug, or unexpected behaviour
argument-hint: "<error or symptom>"
---

Debug the following issue:

$@

## Approach
1. Understand the expected vs actual behaviour
2. Trace the code path involved
3. Identify the root cause
4. Propose a fix (but do NOT implement it unless told to)

Output format:

## Symptom
What's happening vs what should happen

## Investigation
Key files and code paths examined

## Root Cause
file.ts:42 - what's wrong and why

## Fix
Concrete change needed (file, line, before/after)

## Confirmation
How to verify the fix works (test to run, log to check)