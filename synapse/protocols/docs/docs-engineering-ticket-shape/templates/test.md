# <Story Title> — Test Plan

> Companion to [story.md](story.md) and [design.md](design.md). Captures test plan and assertion intent. NEVER includes runtime CI results.

## Coverage Map

<Maps each acceptance criterion (from story.md frontmatter) to one or more test scenarios. Reference AC by index or short label.>

| AC | Scenario | Test Type |
|----|----------|-----------|
| AC-1 | <one-line scenario> | unit | integration | e2e |
| AC-2 | <scenario> | <type> |

## Test Scenarios

### Scenario: <name>

**Given** <preconditions>
**When** <action>
**Then** <expected observable outcome>

**Assertion intent:** <what the test is really checking — the underlying property, not just the literal assertion. e.g., "verifies that the retry budget exhausts before the deadline, not just that an exception fires.">

**Edge variations:**
- Empty / boundary input → <expected outcome>
- Failure mode <X> → <expected outcome>

### Scenario: <name>

<repeat structure>

## Test Data

<Fixtures, factories, or sample inputs needed. Reference by name; do not inline large blobs. If a shared fixture exists in the test harness, link to it.>

- <fixture-name> — <purpose>

## Out-of-Scope

<Tests that look applicable but belong to another FR or another test layer. Prevents duplicate coverage and ambiguous ownership.>

- <Scenario X> — owned by FR-NNN's test.md
- <Scenario Y> — covered by integration harness, not unit-level here

---

<!--
Template usage notes:

- Test PLAN and assertion INTENT only. The plan describes what gets tested and why those assertions matter.
- NEVER include runtime CI results (pass/fail counts, coverage percentages, last-run timestamps). Those belong in CI dashboards, not in the spec.
- NEVER include algorithm details or data-structure descriptions (those live in design.md).
- AC are AUTHORITATIVE in story.md frontmatter. Reference them by index here; do not re-list.
- Assertion intent is the load-bearing content. A test that asserts "result == expected" without an intent line is a fragile test — the intent line tells future maintainers what property the test is actually guarding.
- If a scenario covers multiple AC, that's fine. If a scenario covers zero AC, question whether it belongs here.
-->
