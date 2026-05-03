# <Story Title> — Design

> Companion to [story.md](story.md). HOW this FR delivers the AC declared there. NEVER duplicate AC.

## Algorithm

<Step-by-step description of the core procedure. Pseudocode acceptable. Name the inputs, the transformations, and the outputs. If multiple algorithms apply (e.g., happy path + retry path), label each.>

```
function <name>(<inputs>):
  <step 1>
  <step 2>
  return <output>
```

## Data Structures

<Schemas, records, enums, in-memory layouts. Describe field-by-field where helpful. Use language-neutral notation (the test plan covers test-language specifics).>

```
<TypeName> {
  <field>: <type>  # <constraint or note>
  ...
}
```

## Internal Interfaces

<Function signatures, RPC shapes, event envelopes consumed or emitted by THIS FR's modules. Internal-to-the-system contracts. Externally-visible contracts live in epic.md `## Contracts`.>

| Name | Inputs | Outputs | Notes |
|------|--------|---------|-------|
| <fn> | <args> | <return> | <constraints> |

## Tradeoffs and Rationale

<Why this design over alternatives considered. Each tradeoff: option chosen, option(s) rejected, the criterion that decided. This is the load-bearing design content — without it, future readers cannot evaluate whether assumptions still hold.>

- **<Decision>** — Chose <option A> over <option B> because <criterion>.
- **<Decision>** — <rationale>

## Dependencies

<How this FR's design composes with depends_on FRs. Frontmatter-only — never describe a dependency's internals here. Reference by FR id and the contract surface you consume.>

- FR-NNN (<title>) — consumes <contract from its frontmatter>
- vocab term: <term> — see [vocab.md](../../../../vocab.md)

## Risks

<Design-level risks: assumptions that may not hold, performance unknowns, areas where prototyping is needed. NOT implementation defects (those land in impl.md after they happen).>

- <Risk> — mitigation: <approach>

---

<!--
Template usage notes:

- HOW only. Algorithm, data structures, internal interfaces, and tradeoff rationale.
- NEVER duplicate AC from story.md frontmatter. Reference by ID if needed.
- NEVER include test plans (test.md owns those).
- NEVER include runtime CI results (test.md and impl.md exclude those too).
- NEVER include mechanical change logs ("first added X, then Y") — those don't belong in any artifact; they live in git log.
- Externally-visible contracts (API surfaces, event envelopes consumed by other epics) belong in epic.md `## Contracts`. Internal interfaces (consumed only within this epic) belong here.
- If this design depends on a dependency FR, read its story.md FRONTMATTER ONLY. NEVER read a dependency's design.md or impl.md.
-->
