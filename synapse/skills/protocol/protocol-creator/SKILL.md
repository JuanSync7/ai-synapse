---
name: protocol-creator
description: "Use when asked to create a new protocol, build a protocol for X, or define an inter-agent behavioral contract."
domain: protocol.create
intent: write
tags: [protocol, creation, scaffolding, behavioral-contract]
user-invocable: true
argument-hint: "<protocol-name> [--domain <domain>]"
---

# Protocol Creator

Creates behavioral contracts that LLM agents follow at specific interaction points. A protocol is a function: frontmatter is metadata, mental model is the docstring, contract is the function body, failure assertion is try/except. Think AXI4 bus protocols — imperative rules ("AWREADY MUST be asserted only after AWVALID") injected at the exact moment they matter. Protocol-creator translates brainstorm decisions into precise, trigger-clear instructions that agents follow without rationalization.

Protocols are not skills. Skills are long-running workflows with phases and progressive disclosure. Protocols are short imperative contracts (30–120 lines) loaded at a single interaction point. If the behavioral rule needs multiple phases, it's a skill. If it's one focused contract, it's a protocol.

> **Execution scope:** Ignore `research/`, `EVAL.md`, `PROGRAM.md`, `SCOPE.md`, and `test-inputs/` during execution — these are used only by improvement and migration workflows.

## Wrong-Tool Detection

- **User wants to create a skill** → redirect to `/skill-creator`
- **User wants to create an agent** → redirect to `/agent-creator`
- **User wants to improve an existing protocol** → redirect to `/improve-skill` (adapt for protocols until `/improve-protocol` exists)
- **User wants to evaluate a protocol** → redirect to `/write-protocol-eval`
- **User wants to brainstorm whether something should be a protocol** → redirect to `/synapse-brainstorm`
- **User wants to certify a protocol for promotion** → redirect to `/synapse-gatekeeper`

## Progress Tracking

At the start, create a task list for each phase:

```
TaskCreate: "Phase 1: Elicit precision anchors"
TaskCreate: "Phase 2: Draft protocol"
TaskCreate: "Phase 3: Signal-strength review"
TaskCreate: "Phase 4: Register and output injection snippet"
```

Mark each task `in_progress` when starting, `completed` when done.

---

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `<protocol-name>` | Yes | Name for the protocol (lowercase, hyphenated) |
| `--domain <domain>` | No | Domain from PROTOCOL_TAXONOMY.md (prompted if not provided) |
| Decision memo path | No | From `/synapse-brainstorm` — if provided, read it first and extract anchors |

---

## Phase 1: Elicit Precision Anchors

**Decision memo check:** If the user provides a decision memo from `/synapse-brainstorm`, read it first. Evaluate the memo against the gate conditions below. Fill any gaps the memo doesn't cover. If all gate conditions are already met, proceed directly to Phase 2. If the memo is incomplete, use it as a starting point and complete the remaining anchors.

Extract these four precision anchors — each MUST have a concrete, unambiguous answer:

| Anchor | Question | What a bad answer looks like |
|--------|----------|------------------------------|
| **Behavior** | What behavior are you enforcing? | "Better code quality" — too vague, not one behavior |
| **Trigger moment** | When exactly must it fire? | "When appropriate" — unnamed moment, will never fire |
| **Compliance signal** | What does compliance look like? | "Good output" — not observable, not verifiable |
| **Violation signal** | How do you detect the LLM skipped it? | "The output is wrong" — too vague to check |

**Single-concern check:** If the user's intent spans multiple independent behaviors, split into multiple protocols. Ask: "If I removed behavior A, would behavior B still make sense on its own?" If yes, they are independent concerns — create separate protocols.

**Duplicate check:** Read `PROTOCOL_REGISTRY.md` (if it exists) and check for overlapping protocols. Surface any overlap and let the user decide: differentiate, merge, or abandon.

> **Read [`../../../../taxonomy/PROTOCOL_TAXONOMY.md`](../../../../taxonomy/PROTOCOL_TAXONOMY.md)** to pick `domain` and `type` values. If nothing fits, propose an addition — do not invent ad hoc values.

**Phase 1 gate — all must be true before proceeding:**
- [ ] All 4 precision anchors have concrete, unambiguous answers
- [ ] Single-concern confirmed (one behavior, one contract)
- [ ] No duplicate in PROTOCOL_REGISTRY.md — or boundary is stated
- [ ] Domain and type selected from PROTOCOL_TAXONOMY.md
- [ ] All ambiguity flagged and resolved (not guessed through)

If any are false, ask a specific question. Do not proceed with an underspecified protocol — vague anchors produce vague contracts.

---

## Phase 2: Draft the Protocol

> **Read [`references/protocol-design-principles.md`](references/protocol-design-principles.md)** before drafting — full reasoning for each principle.
> **Read [`templates/protocol-skeleton.md`](templates/protocol-skeleton.md)** for the output structure.
> **Read [`rules/banned-words.md`](rules/banned-words.md)** for words that MUST NOT appear in the contract.

Write the protocol `.md` file under `src/protocols/<concern>/` following the universal anatomy:

### Section 1: Frontmatter

```yaml
---
name: <protocol-name>
description: "<trigger/routing contract — when this protocol fires>"
domain: <from PROTOCOL_TAXONOMY.md>
type: <from PROTOCOL_TAXONOMY.md>
tags: [<lowercase, hyphenated>]
---
```

The `description` is a routing contract — it specifies WHEN the protocol fires, not WHAT it does. If the description could replace reading the protocol body, it's too broad.

### Section 2: Mental Model

One paragraph. Explains WHY this protocol exists — the behavioral gap it fills, what goes wrong without it. MUST NOT restate the contract rules. MUST NOT describe the workflow.

### Section 3: Contract

The imperative rules. Every instruction MUST:
- Use commitment language: MUST, NEVER, STOP, BEFORE, AFTER, THEN, DO NOT
- Name a specific trigger moment — NEVER "when appropriate"
- Contain zero banned words from `rules/banned-words.md`
- Define a trigger, state a constraint, or specify an output format — no other sentence type belongs here

If the contract produces structured output (like execution-trace's YAML block), define the output format here as an instruction: "AFTER completing X, APPEND this block."

### Section 4: Failure Assertion

Every protocol MUST have this. When the trigger fires but preconditions aren't met, instruct the agent to output:

```
PROTOCOL FAILURE: <protocol-name> — [specific reason]
```

This follows the tag format in `synapse/protocols/observability/failure-reporting.md`. The agent follows this like any other imperative instruction — the failure becomes part of the output naturally.

### Section 5: Configuration (optional)

Only if the protocol has modes (e.g., shallow/deep, strict/lenient). Each mode MUST have a default. Delete this section if the protocol has no modes.

### What NEVER to Include

- **NEVER include Injection Instructions** — a function does not explain how to be called. The consumer knows how to load protocols.
- **NEVER include an Examples section** — if the contract needs an example to be understood, the contract is too vague. Rewrite the instruction until it is self-evident.
- **NEVER include a Consumers section** — discovery info belongs in PROTOCOL_REGISTRY.md, not the protocol file.
- **NEVER include a Trigger section** — the trigger lives in the frontmatter `description` field.

### Line Budget

Protocols MUST be 30–120 lines including frontmatter. Over 120 lines means the protocol packs multiple concerns or includes explanatory prose in the contract — split or trim.

> **Read [`examples/good-protocol.md`](examples/good-protocol.md)** for an annotated worked example.

---

## Phase 3: Signal-Strength Review

> **Read [`agents/protocol-eval-reviewer.md`](agents/protocol-eval-reviewer.md)** and dispatch as an Agent (model: sonnet) with the drafted protocol file as input.

MUST dispatch the protocol-eval-reviewer as a separate Agent — DO NOT run the 8-check review inline. The agent produces an independent signal-strength verdict. Inline review substitutes your own judgment, which defeats the purpose of a separate reviewer.

**If any checks fail:** Fix the specific issues identified in the review. Re-dispatch the agent for a second review.

**Two review cycles maximum.** If the protocol still fails after two cycles, surface the remaining issues to the user — the protocol may need design changes, not just wording fixes.

---

## Phase 4: Register

After the protocol passes signal-strength review:

**4a. Register in PROTOCOL_REGISTRY.md**

Add a row to the registry table:

```markdown
| [<protocol-name>](src/protocols/<concern>/<protocol-name>.md) | <description> | <domain> | <type> | <consumers> |
```

If PROTOCOL_REGISTRY.md does not exist, create it following the format in the existing file at the project root.

**4b. Register domain in PROTOCOL_TAXONOMY.md (if new)**

If the protocol's domain doesn't exist in PROTOCOL_TAXONOMY.md, add it to the Domains table. Taxonomy entries are domain-level — one entry per domain, not per protocol.

If the protocol's type doesn't exist, add it to the Types table.

**4c. Output the injection snippet**

Tell the user the exact `> Read` line to paste into their consuming skill or agent:

```markdown
> **Read [`src/protocols/<concern>/<protocol-name>.md`](src/protocols/<concern>/<protocol-name>.md)** when <specific moment in the consuming skill>.
```

**4d. Suggest injection point**

If the user mentioned which skill or agent will consume this protocol, suggest where in that skill's workflow the `> Read` should be placed — at the specific phase or decision point where the protocol's trigger moment aligns.

---

## Quality Standards

A complete protocol has:

| Artifact | Purpose | Status |
|----------|---------|--------|
| Protocol `.md` file | The behavioral contract | Required |
| PROTOCOL_REGISTRY.md entry | Discovery | Required |
| PROTOCOL_TAXONOMY.md domain | Controlled vocabulary | Required (if new domain) |
| Signal-strength review pass | Quality gate | Required |
| `/synapse-gatekeeper` certification | Promotion gate | Required before merge |

---

## When to Hand Off

| Task | Route to |
|------|----------|
| Protocol needs improvement after creation | `/improve-skill <protocol-path>` |
| Protocol needs conformance tests | `/write-protocol-eval <protocol-path>` |
| Protocol needs promotion certification | `/synapse-gatekeeper <protocol-path>` |
| User wants to brainstorm whether something should be a protocol | `/synapse-brainstorm` |
| User wants to create a skill instead | `/skill-creator` |
