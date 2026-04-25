# Protocol Brainstorm Absorption

**Source:** protocol-creator brainstorm (2026-04-21)
**Decision:** T4 — skill-brainstorm absorbs agent and protocol brainstorms

## What Changes

skill-brainstorm currently only produces decision memos that route to `/skill-creator`. It needs to:

1. **Detect artifact type early in Phase A** — is this a skill, agent, or protocol? The "is this skill-worthy?" question becomes "is this artifact-worthy?" with three possible outcomes routing to `/skill-creator`, `/agent-creator`, or `/protocol-creator`.

2. **Add protocol-specific evaluation lenses** — the existing lenses (usability, robustness, maintenance, boundary) apply to all artifact types. Protocols need additional lenses:
   - **Trigger clarity** — does the protocol name the exact moment it fires? Not "when appropriate" but "before returning any response that modifies X."
   - **Signal strength** — does every instruction use commitment language (MUST, NEVER, STOP)? No weak signals (consider, may want to, appropriate).
   - **Precision anchors** — four questions that must be answered for every protocol:
     - What behavior are you enforcing?
     - When exactly must it fire? (trigger moment)
     - What does compliance look like? (observable output)
     - What does violation look like? (how to detect the LLM skipped it)

3. **Update `references/evaluation-lenses.md`** — add the protocol-specific lenses with routing: "apply these lenses when artifact type is protocol."

4. **Update decision memo template** — the memo must indicate artifact type so the receiving creator knows what it's getting.

## Why

90% of coaching logic is shared across artifact types. Only the exit routing and the "is this artifact-worthy?" gate question differ. Maintaining three separate brainstorm skills would duplicate the coaching personality, lens rotation, and notepad mechanics. One skill, three artifact routes.

## Mental Model

Think of it like AXI4 vs. a software design pattern — both benefit from brainstorming whether they're needed, but the pressure-test lenses differ. Skills are workflows (usability, progressive disclosure). Protocols are contracts (trigger precision, signal strength, single-concern).
