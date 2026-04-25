# Update protocol-checklist to match universal anatomy

**Source:** protocol-creator brainstorm (2026-04-21)
**Decision:** R12 — protocol anatomy is 4 mandatory + 1 optional sections

## What Changes in `references/protocol-checklist.md`

### Tier 1 (Structural) — update checks:
- **Remove** "Injection instructions present" — protocols don't explain how to be imported
- **Add** "Failure assertion present" — every protocol MUST have a PROTOCOL FAILURE instruction
- **Add** "Mental model paragraph present" — one paragraph explaining WHY
- **Keep** "Schema block present" → rename to "Contract section present" (behavioral protocols have MUST/NEVER instructions, not YAML schemas)

### Tier 2 (Conformance) — update checks:
- **Remove** "Injection instructions self-contained" — no injection section exists
- **Remove** "At least one filled-in example" — examples belong in eval, not protocol. If the contract needs an example to be understood, the contract is too vague.
- **Add** "Failure assertion is imperative" — agent follows it as an instruction, produces PROTOCOL FAILURE output
- **Add** "Contract uses imperative language" — MUST/NEVER/BEFORE/AFTER, no weak signals (consider, may want to, appropriate)
- **Keep** "Schema is machine-parseable" → rename to "Contract is unambiguous" (applies to both schema and behavioral protocols)
- **Keep** "Zero-overhead design"

## Why

The original checklist was written before the protocol anatomy was finalized. It assumed protocols have injection instructions and examples. The brainstorm determined: injection is universal (consumer knows how to import), examples are eval artifacts (if you need one, the contract is too vague).
