# Decision Memo — protocol-creator

## What I want
A skill that takes a brainstorm decision memo and produces a production-ready protocol `.md` file — a behavioral contract that LLM agents follow at specific interaction points. Think AXI4 protocol for LLMs: imperative rules (MUST/NEVER/BEFORE/AFTER) injected at point-of-action, not vague guidelines loaded at session start.

## Why Claude needs it
Without protocol-creator, protocols are written ad hoc with inconsistent structure, vague trigger wording, and missing failure handling. Three specific failure modes in hand-written protocols:
1. **Competing priority** — weak wording ("consider doing X") loses to task pressure. Needs commitment language (MUST, NEVER, STOP).
2. **Vague trigger** — "when appropriate" means the LLM never fires. Needs named trigger moments ("BEFORE returning any response that modifies a file listed in README.md").
3. **Distance decay** — protocol loaded at session start, forgotten by the time it matters. Solved by point-of-action injection design, not content.

The problem is ACTIVATION not COMPLIANCE — LLMs follow protocols when told, but never fire on their own. Protocol-creator must produce protocols with trigger clarity and imperative precision that eliminate these failure modes.

## Injection shape
Workflow + policy. Protocol-creator is a multi-phase workflow (elicit → draft → review → register) with strong policy judgment on wording precision and signal strength. The core policy: every protocol instruction must be imperative, point-of-action, and unambiguous — if you need an example to understand it, rewrite the instruction.

## What it produces
1. A single `.md` file with YAML frontmatter under `src/protocols/<concern>/`
2. Entry in PROTOCOL_REGISTRY.md (flat discovery table — name, description, consumers)
3. New domain in PROTOCOL_TAXONOMY.md if needed (domain-level only, not per-protocol)
4. The `> Read` injection snippet for the consuming skill/agent to paste

## Protocol anatomy (the .md file structure)

Every protocol follows this universal anatomy (protocol = function):

| Section | Analogy | Required | Purpose |
|---------|---------|----------|---------|
| **Frontmatter** | Module metadata | Yes | name, description (trigger/routing contract), domain, type, tags |
| **Mental model** | Docstring | Yes | One paragraph. WHY this protocol exists. |
| **Contract** | Function body | Yes | The actual rules: MUST/NEVER/BEFORE/AFTER/THEN. If protocol produces output, it's an instruction here ("AFTER X, APPEND this block"). |
| **Failure Assertion** | try/except | Yes | "If [precondition] not met, STOP and output: `PROTOCOL FAILURE: [name] — [reason]`." Hardware assertion-fail equivalent. |
| **Configuration** | **kwargs | No | Mode selection (e.g., shallow/deep). Most protocols don't need this. |

What's explicitly NOT in the protocol:
- No Injection Instructions — consumer knows how to import (`> Read` or prompt injection)
- No Examples — if the contract needs one, it's too vague; rewrite the instruction
- No Consumers section — discovery info belongs in PROTOCOL_REGISTRY.md
- No Trigger section — trigger lives in frontmatter `description` field

## Workflow phases

### Phase 1: Elicit precision anchors
Takes the brainstorm decision memo and extracts four anchors (same as skill-creator Phase 1 but protocol-tuned):
- What behavior are you enforcing?
- When exactly must it fire? (trigger moment — named, not vague)
- What does compliance look like? (observable output)
- What does violation look like? (how to detect the LLM skipped it)

Any ambiguity in the memo gets flagged explicitly, not guessed through. Single-concern rule enforced here — if the intent spans multiple concerns, split into multiple protocols.

### Phase 2: Draft the protocol
Write the `.md` file following the universal anatomy. All contract instructions use imperative, point-of-action language. No weak signals (consider, may want to, appropriate).

### Phase 3: Signal-strength review
Dispatch `protocol-review-agent` (shared agent in `src/agents/`) to validate:
- Every instruction uses commitment language (MUST/NEVER/STOP)
- No weak signal words (consider, may want to, appropriate, ideally)
- Every instruction names a specific trigger moment
- No bloat — every sentence either defines a trigger, states a constraint, or specifies output format
- Failure assertion is present and imperative
- Single-concern rule holds — protocol doesn't pack multiple behavioral contracts

Fix issues, re-review if needed.

### Phase 4: Register
- Add entry to PROTOCOL_REGISTRY.md
- Add domain to PROTOCOL_TAXONOMY.md if new
- Output the `> Read` injection snippet

## Edge cases considered

| Edge case | Handling |
|-----------|---------|
| Protocol spans multiple concerns | Split into multiple protocols. Single-concern is a hard rule. Protocols scale to thousands — they're cheap. |
| Trigger fires but precondition not met | Failure assertion: agent outputs `PROTOCOL FAILURE: [name] — [reason]`. Fail loudly, never skip silently. |
| Contract instruction is ambiguous | Protocol-review-agent flags it. Rewrite until self-evident — no examples to patch vague instructions. |
| Protocol domain doesn't exist in taxonomy | Protocol-creator proposes addition to PROTOCOL_TAXONOMY.md (domain-level only). |
| Duplicate protocol exists | Check PROTOCOL_REGISTRY.md during Phase 1. Surface overlap, let user decide: differentiate, merge, or abandon. |
| Precision vs. flexibility tension | Imperative wording with named trigger moments. If too rigid for edge cases, the trigger moment needs refinement, not weaker wording. |

## Companion files anticipated

- **references/**: protocol design principles (wording rules, signal-strength patterns, the AXI4 mental model), protocol anatomy reference
- **templates/**: protocol `.md` skeleton with the 4 mandatory + 1 optional sections pre-structured
- **rules/**: banned word list (consider, may want to, appropriate, ideally, when possible), single-concern enforcement rule
- **examples/**: worked example of a well-written protocol (e.g., a cleaned-up execution-trace or a new README-first protocol)

## New artifacts needed (outside protocol-creator)

| Artifact | Type | Purpose |
|----------|------|---------|
| `PROTOCOL_REGISTRY.md` | Root file | Flat discovery table (parallel to AGENTS_REGISTRY.md) |
| `protocol-review-agent` | Agent (`src/agents/`) | Signal-strength validation, shared across protocol suite via symlinks |

## Boundary map

| Skill/artifact | Responsibility |
|----------------|---------------|
| skill-brainstorm | Decides if something should be a protocol (vs. config, vs. not needed) |
| **protocol-creator** | Creates .md file, frontmatter, reviews signal strength, registers |
| write-protocol-eval | Conformance tests (deferred — stub exists) |
| synapse-gatekeeper | Certifies for promotion (protocol flow already implemented) |
| Consuming skill/agent author | Embeds the `> Read` injection reference |

## Open questions
- What's the hard line cap for protocols? Execution-trace is ~119 lines including schema. Behavioral protocols should be shorter — maybe 50-80 lines? Needs real usage data.
- Does protocol-review-agent need its own EVAL.md, or is it tested indirectly through protocol-creator's eval? (Same open question as skill-eval-judge.)
- How does the Configuration section interact with injection — does the consumer pass config at injection time, or is it baked into the protocol? Execution-trace uses observer-specified nesting, suggesting injection-time config.

## Change requests filed during brainstorm
- `skill-brainstorm/change_requests/2026-04-21-protocol-brainstorm-absorption.md` — absorb protocol brainstorms + protocol-specific lenses
- `synapse-gatekeeper/change_requests/2026-04-21-protocol-failure-assertion.md` — mandatory PROTOCOL FAILURE assertion check
- `synapse-gatekeeper/change_requests/2026-04-21-protocol-checklist-anatomy-update.md` — align checklist to universal anatomy
- `protocols/traces/change_requests/2026-04-21-anatomy-alignment.md` — align execution-trace to universal anatomy
