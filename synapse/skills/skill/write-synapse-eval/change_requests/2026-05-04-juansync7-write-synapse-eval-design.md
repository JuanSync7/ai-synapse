# Design Document — write-synapse-eval

> Brainstorm slug: `2026-05-04-write-synapse-eval`
> Status: **complete** | Artifact: skill (creation) | Target: `synapse/skills/skill/write-synapse-eval/`

---

## 1. Problem Statement

The synapse framework has four artifact classes — skill, protocol, agent, tool — but eval-generation is only available for one of them. `/write-skill-eval` exists; `write-{protocol,agent,tool}-eval` do not. This creates three gaps:

1. Protocol, agent, and tool artifacts have no eval-generation path, making them ungradeable by `/synapse-gatekeeper` without manual EVAL.md authoring.
2. `synapse-creator`'s `flow-agent.md` references a dead `/write-agent-eval` handoff (logged as T3.6 FAIL), breaking the post-scaffold pipeline for agent artifacts.
3. `/improve-skill` references `/write-skill-eval` directly — a standalone skill that is not extensible to other artifact types.

**What changes:** A single router-based skill, `write-synapse-eval`, consolidates eval-generation for all four artifact types under one entry point, superseding `/write-skill-eval` and filling the missing type gaps.

---

## 2. Design Principles

### Mirror synapse-creator's architecture exactly

The `synapse-creator` router (SKILL.md + `flow-{type}.md` + `shared-steps.md` + `type-config.md` + `templates/{type}/`) has been proven across four artifact types. Reinventing the structure for a skill with the same routing problem would produce an inconsistent meta-layer. Eval generation has the same type-dispatch problem as artifact creation: one entry point, type-specific logic, shared utility procedures.

**Implication:** All structural decisions (token-budget invariant, atomic write, EXACTLY ONE flow file per session, `type-config.md` as the canonical per-type field map) are inherited without modification. Pressure-testing during brainstorm focused on per-type tier shape, not the router architecture.

### Single-source-of-truth for tier checklists

Each flow file could define its own tier criteria inline, but this would create drift risk: the criteria in EVAL.md templates would diverge from what `/synapse-gatekeeper` uses to grade. The canonical source of grading criteria is `synapse-gatekeeper/references/{agent,protocol,tool}-checklist.md`.

**Implication:** Flow files reference the gatekeeper checklists directly. Templates derive tier IDs from those checklists. When a checklist changes, the eval output changes automatically — no dual maintenance.

### v1 ships skill-flow complete; other types ship as scaffolds

All four flows must exist in v1 to satisfy the routing contract and the "no dead handoffs" goal. However, the dispatch agents for protocol/agent/tool eval (analogous to `skill-eval-{prompter,judge,auditor}`) do not exist yet. Blocking the router on agent availability would delay the T3.6 FAIL fix and the `/write-skill-eval` sunset unnecessarily.

**Implication:** `flow-skill.md` is a near-mechanical port of the existing `write-skill-eval` logic. `flow-{protocol,agent,tool}.md` ship with template scaffolds and clear "needs dispatch agents" markers. Subsequent CRs add the missing dispatch agents; the router itself does not need to change.

### Explicit args only — no natural-language inference

`synapse-creator` requires explicit `$TYPE` and `$ARTIFACT_PATH` arguments and rejects NL inference. `write-synapse-eval` has the same failure mode: ambiguous type inference produces the wrong EVAL.md tier shape. Consistency with the sibling skill also reduces cognitive load for callers who use both.

**Implication:** CLI is `/write-synapse-eval <type> <path>`. No argument guessing. Wrong or missing `$TYPE` fails at `[ROUTE]` with a valid-list error before any file load.

### One artifact per invocation

Generating evals for multiple artifacts in a single session would require holding multiple flow files in context simultaneously, violating the token-budget invariant and the "EXACTLY ONE flow file per session" rule.

**Implication:** Multi-artifact requests are rejected at `[NEW]` with a redirect to parallel subagent dispatch. This mirrors `synapse-creator`'s concurrency contract.

---

## 3. Architecture

### 3.1 Flow Graph

<!-- VERBATIM -->
```
[NEW]   wrong-tool detection / ambiguity guard
   ↓
[ROUTE] validate $TYPE + $ARTIFACT_PATH; load EXACTLY ONE references/flow-<TYPE>.md
   ↓
flow-<TYPE>:[START]
   ↓ (each flow owns its lifecycle: read artifact → dispatch agents → assemble → write EVAL.md)
flow-<TYPE>:[END]
```

### 3.2 Node Specifications

**`[NEW]` — Wrong-tool detection and ambiguity guard**

Load: none (pre-load gate)
Do:
1. Check if user intent matches one of the wrong-tool redirects below.
2. Check if multiple artifacts are implied — reject with parallel-dispatch redirect.
3. Extract `$TYPE` and `$ARTIFACT_PATH` from invocation.

Don't: load any flow file; proceed with implicit or inferred arguments.

Exit: pass to `[ROUTE]` with validated `$TYPE` and `$ARTIFACT_PATH` in scope.

Wrong-tool redirects:
- User wants to improve a skill against existing EVAL → `/improve-skill`
- User wants to certify for promotion → `/synapse-gatekeeper`
- User wants to brainstorm what eval to write → `/synapse-brainstorm`
- Multi-artifact in one session → reject; dispatch parallel agents

---

**`[ROUTE]` — Validation and flow dispatch**

Load: `references/type-config.md` (for path-shape validation)
Do:
1. Confirm `$TYPE ∈ {skill, protocol, agent, tool}` — fail loudly with valid list if not.
2. Confirm `$ARTIFACT_PATH` exists and is readable — fail loudly if not.
3. Validate path shape against type-config: `skill`/`tool` expect a directory; `agent`/`protocol` expect a flat `.md` file — fail with "type/path mismatch" if wrong.
4. Check if EVAL.md already exists at the target path — if yes, fail loudly: "EVAL.md exists; use `--force` to overwrite or `/improve-skill` to refine via measurement".
5. Load EXACTLY ONE `references/flow-<TYPE>.md`.

Don't: load more than one flow file; proceed past this node with any validation failure.

Exit: transfer control to `flow-<TYPE>:[START]`.

---

**`flow-<TYPE>:[START → END]`** — Type-specific eval lifecycle

Each flow file owns its full lifecycle: read artifact → dispatch subagents → assemble → atomic write.

Do (every flow):
1. Read the artifact (SKILL.md, agent.md, protocol.md, or tool directory).
2. Dispatch type-appropriate eval agents (or scaffold placeholders for protocol/agent/tool in v1).
3. Assemble full EVAL.md in memory using `templates/<type>/eval.md` as the skeleton.
4. Write EVAL.md atomically — one write, no partial output.
5. Emit exit signal: file path + tier-count summary.

Don't: branch on `$TYPE` inside flow files (type is already resolved); modify the artifact being evaluated; apply grading (that is `/synapse-gatekeeper`'s job).

### 3.3 Entry Gates

| Transition | Gate conditions |
|---|---|
| `[NEW] → [ROUTE]` | Single artifact implied; `$TYPE` and `$ARTIFACT_PATH` extractable from invocation |
| `[ROUTE] → flow-<TYPE>:[START]` | `$TYPE ∈ {skill, protocol, agent, tool}`; `$ARTIFACT_PATH` exists and is readable; path shape matches type-config; no existing EVAL.md (or `--force` flag present) |

---

## 4. Directory Layout

<!-- VERBATIM -->

```
synapse/skills/skill/write-synapse-eval/
├── SKILL.md                          # Router (<100 LOC)
├── EVAL.md                           # Self-eval (mirrors synapse-creator's EVAL.md structure)
├── references/
│   ├── flow-skill.md                 # Skill EVAL flow (port from existing write-skill-eval)
│   ├── flow-protocol.md              # Protocol EVAL flow (new)
│   ├── flow-agent.md                 # Agent EVAL flow (new)
│   ├── flow-tool.md                  # Tool EVAL flow (new)
│   ├── shared-steps.md               # Parameterized procedures
│   └── type-config.md                # Per-type field/path map
└── templates/
    ├── skill/eval.md                 # EVAL-S/E/F/O + Test Prompts skeleton
    ├── protocol/eval.md              # EVAL-S + EVAL-C (conformance) skeleton
    ├── agent/eval.md                 # EVAL-S + EVAL-D (dispatch/output) skeleton
    └── tool/eval.md                  # EVAL-S + EVAL-X (exit-codes/side-effects) skeleton
```

---

## 5. SKILL.md Frontmatter

<!-- VERBATIM -->

```yaml
---
name: write-synapse-eval
description: Use when generating an EVAL.md for a skill, protocol, agent, or tool. Routes to the type-specific eval-generation flow.
domain: skill
intent: write
tags: [eval-md, criteria, test-prompts, multi-artifact, router]
user-invocable: true
argument-hint: "<skill|protocol|agent|tool> <path-to-artifact>"
---
```

---

## 6. Per-Type EVAL Tier Shape

<!-- VERBATIM -->

| Type     | Tiers                                                          | Test mechanism                                                |
|----------|----------------------------------------------------------------|---------------------------------------------------------------|
| skill    | EVAL-S (structural), EVAL-E (orchestration, opt), EVAL-F (flow-graph, opt), EVAL-O (output) + Test Prompts | Run skill on prompts via subagent, judge outputs              |
| protocol | EVAL-S (structural), EVAL-C (conformance assertions)           | Apply protocol to fixture artifacts, assert compliance        |
| agent    | EVAL-S (structural), EVAL-D (dispatch contract + output grade) | Dispatch agent with test inputs, judge outputs against role   |
| tool     | EVAL-S (structural), EVAL-X (exit-codes + side-effects)        | Invoke tool script with fixtures, assert exit codes + state   |

Tier ID prefixes are type-scoped to avoid collision when the same criteria name appears across types (e.g., "structural" is EVAL-S for all types, but EVAL-C is protocol-only, EVAL-D is agent-only, EVAL-X is tool-only).

---

## 7. Behavioral Invariants

<!-- VERBATIM -->

**MUST (every turn)**
- Record position: `Position: [node-id] — <context>`
- Confirm `$TYPE ∈ {skill, protocol, agent, tool}` BEFORE loading any flow file
- Validate `$ARTIFACT_PATH` exists BEFORE flow load
- Load EXACTLY ONE `references/flow-<type>.md` per session
- Atomic write: assemble EVAL.md fully in memory, write once

**MUST NOT (global)**
- Inline eval-generation logic in SKILL.md — routing only
- Branch on `$TYPE` inside `references/shared-steps.md` — type variation comes from `type-config.md` lookup
- Modify the artifact being evaluated — read-only operation
- Grade the artifact (that's `/synapse-gatekeeper`'s job) — produce criteria, don't apply them

---

## 8. Handoff Contract

<!-- VERBATIM -->

- Callers: humans, `synapse-creator` (post-scaffold handoff), `improve-skill` (when EVAL.md missing)
- Inputs: `$TYPE`, `$ARTIFACT_PATH`
- Output: `EVAL.md` written into the artifact directory (or alongside the file for flat artifacts like agents/protocols)
- Exit signal: file path + tier-count summary (e.g., "Wrote EVAL.md with 12 EVAL-S, 7 EVAL-O, 4 test prompts")

**`$ARTIFACT_PATH` semantics per type (from `type-config.md`):**
- `skill`: directory → writes `<dir>/EVAL.md`
- `tool`: directory → writes `<dir>/EVAL.md`
- `agent`: flat `.md` file → writes `<agent-name>.eval.md` adjacent
- `protocol`: flat `.md` file → writes `<protocol-name>.eval.md` adjacent

---

## 9. Accepted Tensions

| Tension | Decision | Revisit when |
|---|---|---|
| v1 ships protocol/agent/tool flows as scaffolds without dispatch agents | Accept: unblocks T3.6 FAIL fix and `/write-skill-eval` sunset; dispatch agents added per type in subsequent CRs | When any flow-{protocol,agent,tool}.md scaffold is invoked in production and the "needs dispatch agents" marker triggers a user-facing failure |
| pathway eval (5th type) is out of scope | Defer: additive when ready — add type-config row + new flow file + new template; no design change required | When the first pathway artifact requires an EVAL.md |
| Existing `synapse/agents/skill-eval/{prompter,judge,auditor}.md` are skill-specific but informally the model for other types | Accept: new dispatch agents for other types modeled on skill-eval agents, added under `synapse/agents/` per type | When the agent/protocol/tool flows are fully implemented and agents need formal registry entries |

---

## 10. Dependencies

| Artifact | Direction | Contract |
|---|---|---|
| `synapse/skills/skill/write-skill-eval/` | supersedes | `write-synapse-eval` replaces this; `flow-skill.md` is a port of its logic; original deprecated post-merge |
| `synapse/skills/synapse/synapse-creator/references/flow-{skill,agent,protocol,tool}.md` | consumed by (caller) | Post-scaffold handoff: `synapse-creator` calls `/write-synapse-eval <type> <new-artifact-path>`; resolves T3.6 FAIL (dead `/write-agent-eval` reference) |
| `synapse/skills/skill/improve-skill/` | consumed by (caller) | When EVAL.md missing, `improve-skill` dispatches `/write-synapse-eval skill <path>` (replaces direct `/write-skill-eval` reference; 1-line edit) |
| `synapse/agents/skill-eval/{prompter,judge,auditor}.md` | consumes | `flow-skill.md` dispatches these existing agents; they stay in place |
| `synapse-gatekeeper/references/{agent,protocol,tool}-checklist.md` | consumes | Canonical source for tier criteria; flow files reference these rather than defining criteria inline |
| `taxonomy/SKILL_TAXONOMY.md` | consumes | `domain: skill`, `intent: write` validated against taxonomy on commit |

---

## 11. Sunset Migration

<!-- VERBATIM -->

- Mark `synapse/skills/skill/write-skill-eval/` row in registry as `deprecated` with pointer to `write-synapse-eval`
- Keep the directory in place for one release cycle; update synapse-creator's `flow-skill.md` and any `/improve-skill` references to point to `/write-synapse-eval skill <path>`
- Update `flow-agent.md` (synapse-creator) — replace the dead `/write-agent-eval` handoff with `/write-synapse-eval agent <path>` (resolves T3.6 FAIL)
