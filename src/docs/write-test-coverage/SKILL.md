---
name: write-test-coverage
description: "Use when you need a living test coverage register that maps acceptance criteria to test scenarios and tracks what is covered vs. not. Triggered by 'write test coverage', 'test coverage register', 'what is tested', 'coverage gaps'."
domain: docs.post-build
intent: write
tags: [test-coverage, coverage-register, traceability]
user-invocable: true
argument-hint: "[spec-path] [test-dir]"
---

# Write Test Coverage

Generates and maintains a **test coverage register** — a living document that maps spec acceptance criteria to test scenarios and tracks coverage status.

## Why This Exists

`pytest --cov` gives line coverage — a number. It tells you nothing about which *behaviors* are tested, which are missing, or what the team should write next. A test coverage register provides scenario-level visibility: which acceptance criteria have test cases, which don't, and where the gaps are.

This is the missing layer between:
- **Spec** (requirements + acceptance criteria) — what must be true
- **Test-docs** (implementation test plan) — how to structure tests in code
- **Tests** (actual pytest code) — the implementation

The register maps: `acceptance criterion → test scenarios → covered / partial / not covered`

## When NOT to Use

- **Need a full implementation test plan** → `/write-test-docs`
- **Need to update existing docs after a small code change** → `/patch-docs`
- **Need to write actual test code** → `/write-module-tests`

## Inputs

1. **Spec** — reads acceptance criteria as the source of truth for what must be verified
2. **Test directory** — scans existing test files to determine current coverage
3. **Test-docs** (optional) — if an implementation plan exists, cross-references for completeness

## Output

`test-coverage.md` — a register with:

| Acceptance Criterion | Test Scenarios | Status | Test File |
|---------------------|---------------|--------|-----------|
| AC-1: Valid login returns token | happy path, expired creds, missing fields | Covered | tests/test_auth.py |
| AC-2: Rate limiting after 5 failures | burst detection, reset after window | Partial | tests/test_auth.py |
| AC-3: Token refresh flow | — | Not covered | — |

## Maintenance

This document is initialized by this skill and incrementally updated by `/patch-docs` as new tests are added or bugs are fixed. It should not require full regeneration on every change — that's the whole point.
