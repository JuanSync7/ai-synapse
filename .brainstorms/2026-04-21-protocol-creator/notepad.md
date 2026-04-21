# Brainstorm Notes — protocol-creator

## Status
Phase: B
Outcome: skill

## Resolved

### R1: What is a protocol?
A set of contracts and instructions that COULD live in CLAUDE.md but are separated out so you can pick them on-demand per project. Not always-on — loaded when needed. This is the key differentiator from config: protocols are opt-in behavioral contracts.

### R2: README-first is a real protocol, not just config
User already has the rule in CLAUDE.md but the LLM doesn't follow it reliably — especially for README updates. A single line isn't enough. The protocol needs to be more than "read README first" — it needs the enforcement mechanism (what to do when you don't, how to update, when it applies).

### R3: AXI4 as mental model for protocols
AXI4 (AMBA bus protocol) maps cleanly to our protocol concept. AXI4 = behavioral contracts between master/slave with imperative rules ("AWREADY MUST be asserted only after AWVALID"). Our protocols = behavioral contracts injected into LLM agents at specific interaction points. Same imperative, point-of-action, no-ambiguity pattern. Validates the design direction and the "MUST/NEVER/THEN" wording approach.

### R4: Protocol-review-agent is shared across protocol suite
Lives in `src/agents/`, consumed by protocol-creator, write-protocol-eval, and future improve-protocol via symlinks. Same sharing pattern as skill-eval-judge across the skill suite.

### R5: Precision anchors are brainstorm lenses for protocols
The four anchors (behavior, trigger moment, compliance signal, violation signal) become protocol-specific evaluation lenses in skill-brainstorm when it absorbs protocol brainstorms. Not a separate mechanism — integrated into the existing lens rotation.

### R6: Protocols scale to thousands
Thin, single-concern, cheap to create. Single-concern is a hard rule — never pack multiple behavioral contracts into one protocol. This is the protocol equivalent of single-responsibility principle.

### R7: Fail loudly with assertion instruction
When a protocol's trigger fires but preconditions aren't met, the protocol contains an imperative instruction: "If [precondition] is not met, STOP and output: `PROTOCOL FAILURE: [protocol-name] — [reason]`." The agent follows this like any other instruction — failure becomes part of the agent's output naturally. No separate parsing needed. This is the equivalent of an assertion failure in hardware. **Every protocol MUST have this.** Enforced by both protocol-creator (generation) and protocol-review-agent (validation).

### R8: How to make protocols LLM-compliant (was T2)
Primary failure modes (confirmed by user):
1. **Competing priority** — instruction conflicts with task and loses
2. **Vague trigger** — LLM doesn't know WHEN to apply it
3. **Distance decay** — loaded at top, forgotten by the time it matters

NOT a problem: rationalization — when explicitly asked, the LLM does follow. The issue is it never fires, not that it refuses.

Solution: protocol-creator solves trigger clarity and injection timing, not persuasion. Protocols fire at the RIGHT MOMENT via point-of-action injection. Imperative wording (MUST/NEVER/STOP) solves competing priority. Named trigger moments solve vague triggers. Injection at point-of-action solves distance decay.

### R9: Protocol-creator output shape (was T3)
Protocol-creator produces:
1. A single `.md` file with frontmatter under `src/protocols/<concern>/`
2. Registers in PROTOCOL_REGISTRY.md (flat table, parallel to AGENTS_REGISTRY.md — needs to be created)
3. Registers domain in PROTOCOL_TAXONOMY.md if new (domain-level only, not per-protocol)
4. Outputs the `> Read` injection snippet for the consuming skill/agent to paste

### R10: Brainstorm absorption (was T4)
**YES.** One brainstorm skill (skill-brainstorm), detect artifact type early, route memo to the right creator (skill-creator / agent-creator / protocol-creator). 90% of coaching logic is shared. Only the exit routing and Phase A "is this artifact-worthy?" question changes. Protocol-specific lenses added to the lens catalog.

### R11: Memo → protocol translation (was T5)
Mirrors skill-creator Phase 1. Takes brainstorm memo and extracts four precision anchors:
- What behavior are you enforcing?
- When exactly must it fire? (trigger moment — named, not vague)
- What does compliance look like? (observable output)
- What does violation look like? (how to detect the LLM skipped it)
Any ambiguity in the memo gets flagged explicitly, not guessed through.

### R12: Protocol anatomy (was T1)
Protocol = function. Universal anatomy:

1. **Frontmatter** — module metadata (name, description as trigger/routing, domain, type, tags)
2. **Mental model** — docstring. One paragraph. WHY this exists.
3. **Contract** — function body. The actual rules: MUST/NEVER/BEFORE/AFTER/THEN. If protocol produces output (like execution-trace's YAML block), it's an instruction in the contract ("AFTER completing X, APPEND this block"), not a separate section.
4. **Failure Assertion** — try/except. "If [precondition] not met, STOP and output: `PROTOCOL FAILURE: [protocol-name] — [reason]`." Every protocol MUST have this.
5. **Configuration** — optional. Mode selection (**kwargs). Only when protocol has modes (e.g., shallow/deep). Most protocols don't need this.

What's NOT in the protocol:
- **No Injection Instructions** — the consumer knows how to import. Universal mechanism (`> Read` or prompt injection). Protocol doesn't explain how to be imported.
- **No Examples** — if you need an example to understand the contract, the contract is too vague. Rewrite the instruction. Examples belong in the eval.
- **No Consumers** — discovery info belongs in PROTOCOL_REGISTRY.md, not the protocol file.
- **No Trigger section** — trigger lives in frontmatter `description` field (same as skill routing contract).

Mental model: protocol = stdlib function. `import protocol` → consuming skill/agent loads it. Protocol defines behavior, not how to be called.

## Open Threads
(none)

## Key Insights
- User has 3 concrete protocol ideas: notepad pattern, README-first exploration, claim verification
- Execution-trace protocol is ~119 lines — thin, precise, structured
- Protocol = CLAUDE.md rule that didn't stick, extracted and made injectable
- Two injection modes: (1) skill/agent embeds the protocol via `> Read` reference, (2) deterministic orchestrator (LangGraph) injects at a specific node
- Protocol-creator must solve BOTH content (Problem A) AND injection design (Problem B)

## Tensions
- Precision vs. flexibility: too rigid = protocol breaks on edge cases; too loose = LLM ignores it

## Problems the creator must solve
- **A: Content** — translate intent into precise, trigger-clear instructions
- **B: Injection design** — who injects, when, via what mechanism (skill reference, agent embed, orchestrator node)
- **C: Conciseness** — hard cap on protocol length; protocol-review-agent validates signal strength
- **D: Composability** — protocols don't normally compete (different concerns), but flag duplicates
- **E: Testing** — deferred to write-protocol-eval (from the skill-* lifecycle series)

## Discarded
- Brittleness as a separate lens — it's the inverse of Robustness, same concern

## Lens Notes

### Usability
**Resolved.**
1. **Input** — takes decision memo from skill-brainstorm (protocol path). User doesn't need to know protocol anatomy; creator elicits through four precision anchors.
2. **Output clarity** — produces protocol .md file + registry entries + injection snippet. User knows exactly what was created and what to do next.
3. **Injection guidance** — outputs the exact `> Read` line the consuming skill/agent should paste. Not just "add it to your skill" but the literal markdown snippet.

### Robustness
**Resolved.**
1. **Single-concern rule (hard)** — one protocol, one behavioral contract. If intent spans multiple concerns, split. Protocols scale to thousands; they're cheap.
2. **Edge case handling** — protocol MUST contain assertion instruction for when trigger fires but preconditions aren't met. Fail loudly. Never skip silently.
3. **Versioning/staleness** — out of scope for protocol-creator. Maintenance concern.

### Maintenance
**Resolved.**
1. Protocol-review-agent shared across protocol suite (R4) — one agent, not duplicated
2. Single-concern rule (R6) — protocols don't grow into multi-concern monsters
3. PROTOCOL_REGISTRY.md — central discovery, flat table
4. Staleness — out of scope

### Preciseness
**Resolved.** Three precision mechanisms:
1. **Trigger wording precision** — imperative, point-of-action. MUST, NEVER, "before returning", "after modifying". No weak signals. Solves vague trigger + distance decay.
2. **Signal-strength review agent** — separate `protocol-review-agent` dispatched after drafting. Checks for weak signals, vague triggers, bloat, missing trigger moments.
3. **Memo → protocol translation** — four precision anchors (R11). Flags ambiguity.

### Boundary
**Resolved.** Boundary map:
- **skill-brainstorm** → decides if something should be a protocol
- **protocol-creator** → creates .md file, frontmatter, injection design, registers in PROTOCOL_REGISTRY.md + PROTOCOL_TAXONOMY.md
- **write-protocol-eval** → conformance tests
- **synapse-gatekeeper** → certifies for promotion
- **consuming skill/agent author** → embeds the `> Read` injection reference

Protocol-creator writes injection instructions section but does NOT perform actual injection.

New artifacts needed:
- **PROTOCOL_REGISTRY.md** — flat table (name, description, consumers, injection mode)
- **protocol-review-agent** — shared agent in `src/agents/`

## Lens Routing (for skill-brainstorm absorption)

| Lens | Skills | Protocols | Both |
|------|--------|-----------|------|
| Usability | x | | x |
| Robustness | x | | x |
| Maintenance | x | | x |
| Boundary | | | x |
| Trigger clarity | | x | |
| Signal strength | | x | |
| Preciseness | | x | |

## Change Requests Filed
- `src/skills/skill/skill-brainstorm/change_requests/2026-04-21-protocol-brainstorm-absorption.md` — absorb protocol brainstorms + protocol-specific lenses
- `src/skills/skill/synapse-gatekeeper/change_requests/2026-04-21-protocol-failure-assertion.md` — mandatory PROTOCOL FAILURE assertion
- `src/skills/skill/synapse-gatekeeper/change_requests/2026-04-21-protocol-checklist-anatomy-update.md` — align checklist to universal anatomy (remove injection/example checks, add contract/assertion checks)
- `src/protocols/traces/change_requests/2026-04-21-anatomy-alignment.md` — align execution-trace to universal anatomy (remove injection/consumers/persistence, add failure assertion)

## Companion Files Anticipated
### references/ — domain knowledge to load on-demand
### templates/ — output format skeletons (protocol .md skeleton)
### rules/ — hard constraints (wording rules, signal strength checklist)
### examples/ — worked examples of good protocol output
