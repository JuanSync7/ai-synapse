# Change Request: Auto-record certification verdict

## Problem

Gatekeeper verdicts are ephemeral — they exist only in conversation context. There's no way to tell which skills have been certified vs. which just never got flagged as draft. The `status: draft` flag is opt-in, and its absence means "unknown," not "approved."

## Proposed Change

On APPROVE verdict, gatekeeper MUST update the skill's entry in `SKILLS_REGISTRY.yaml`:

1. Add `status: certified` to the skill's entry
2. If `status: draft` exists, replace it with `status: certified`

On REVISE or REJECT, no status change — the skill keeps its current status.

## Lifecycle

```
skill-creator creates skill → status: draft
gatekeeper APPROVE          → status: certified
```

Skills without a `status` field are uncertified (legacy — predates this workflow).

## Scope

- Gatekeeper Phase 5 gains a write step after issuing APPROVE
- skill-creator Phase 2 MUST set `status: draft` on new entries
- Pre-commit hook: no changes needed (status field is not validated)

## Additional: Score check precondition

Separate from the status change — gatekeeper Phase 1 should check for `--score` upfront. If missing, ask before running all 5 phases rather than running everything and reporting REVISE at the end. This is a principle 9 (loud failure on preconditions) violation.
