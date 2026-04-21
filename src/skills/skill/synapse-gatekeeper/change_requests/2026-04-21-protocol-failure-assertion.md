# Protocol Failure Assertion Requirement

**Source:** protocol-creator brainstorm (2026-04-21)
**Decision:** R7 — every protocol MUST have a precondition check with structured failure output

## What Changes

Add to `references/protocol-checklist.md`:

**Tier 1 (Structural) — new check:**
- [ ] Failure assertion present — protocol contains an explicit "If [precondition] is not met, STOP and output: `PROTOCOL FAILURE: [protocol-name] — [reason]`" instruction

**Tier 2 (Conformance) — new check:**
- [ ] Failure assertion is imperative — the assertion is an instruction the agent follows (produces output), not a separate section the agent must "parse"

## Why

Protocols are consumed by agents. When a protocol's trigger fires but the precondition isn't met (e.g., README-first protocol fires but no README.md exists), the protocol must fail loudly — not skip silently. The failure becomes part of the agent's output because it's just another imperative instruction: "If X is not met, STOP and output PROTOCOL FAILURE."

This is the equivalent of an assertion failure in hardware — a non-negotiable structural guarantee that every protocol must provide. Without it, silent failures propagate through the agent's execution and the consuming skill/user never knows the protocol didn't apply.

## Scope

- `references/protocol-checklist.md` — add both checks
- Protocol-creator (when built) will generate this assertion as part of every protocol it creates
- Protocol-review-agent (when built) will validate assertion quality as part of signal-strength review
