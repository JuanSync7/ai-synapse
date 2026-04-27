# Align execution-trace to universal protocol anatomy

**Source:** protocol-creator brainstorm (2026-04-21)
**Decision:** R12 — protocol anatomy defined as 4 mandatory + 1 optional sections

## What Changes

execution-trace.md currently has sections that don't belong in the protocol file per the universal anatomy:

1. **Remove "Injection Instructions"** — the consumer knows how to load the protocol (`> Read` or prompt injection). The injection section is a redundant summary of the contract. If the contract is precise enough, no summary is needed.

2. **Remove "Consumers"** — this is discovery metadata. Move to PROTOCOL_REGISTRY.md (to be created).

3. **Remove "Persistence"** — this is observer-side concern. The observer decides where to save, not the protocol.

4. **Keep "Nesting Configuration"** — this is the optional Configuration section (protocol has modes: shallow/deep).

5. **Keep "When This Protocol Is Used"** — rename to match anatomy. This is the mental model paragraph. Merge with the opening paragraph.

6. **Add Failure Assertion** — execution-trace has no `PROTOCOL FAILURE` instruction. Add: "If the skill produces no observable execution phases, STOP and output: `PROTOCOL FAILURE: execution-trace — no phases executed, trace cannot be constructed.`"

## Resulting structure

```
1. Frontmatter (already present)
2. Mental model (merge opening paragraph + "When This Protocol Is Used")
3. Contract (Trace Schema + Field Definitions — these ARE the contract)
4. Failure Assertion (new)
5. Configuration (Nesting Configuration — already present)
```
