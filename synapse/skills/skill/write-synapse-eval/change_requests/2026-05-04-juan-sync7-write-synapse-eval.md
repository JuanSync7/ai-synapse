# Decision Memo — write-synapse-eval

> Artifact type: skill | Memo type: creation | Design doc: `../../../.brainstorms/2026-05-04-write-synapse-eval/design.md`

---

## What I want

A single router-based skill (`/write-synapse-eval`) that generates EVAL.md files for any of the four artifact classes — skill, protocol, agent, tool. It replaces the standalone `/write-skill-eval` and fills the missing `write-{protocol,agent,tool}-eval` gap, consolidating four separate type-flows under one entry point. Architecture mirrors `synapse-creator` exactly: a thin routing `SKILL.md` plus per-type flow files, shared steps, a type-config map, and per-type EVAL.md templates.

---

## Why Claude needs it

Without this skill, three artifact classes (protocol, agent, tool) have no eval-generation path at all. The existing `/write-skill-eval` only handles skills. `synapse-creator`'s `flow-agent.md` hands off to `/write-agent-eval` — a dead reference (T3.6 FAIL). Adding separate write-protocol-eval / write-agent-eval / write-tool-eval skills would produce redundant routing logic across four artifacts and make maintenance drift likely. A single consolidating router resolves all four gaps in one artifact, with extension cost of "add one flow file + one template" for future types.

---

## Injection shape

- **Workflow:** Phase descriptions, flow graph, node specs. Router SKILL.md owns the `[NEW] → [ROUTE] → flow-<TYPE>:[START]` lifecycle; each flow file owns its full type-specific lifecycle from artifact read through EVAL.md write.
- **Policy:** Hard gates (type validation, path existence check, single-flow-load invariant, atomic write, EVAL.md clobber guard). Wrong-tool detection block redirecting to `/improve-skill`, `/synapse-gatekeeper`, `/synapse-brainstorm`.
- **Domain knowledge:** Per-type tier shapes and tier-ID prefixes, loaded on-demand from `type-config.md`; canonical tier checklists referenced from `synapse-gatekeeper/references/{agent,protocol,tool}-checklist.md`.

---

## What it produces

| Output | Count | Mutable? | Purpose |
|---|---|---|---|
| EVAL.md (inside artifact dir) | 1 per invocation | No (atomic, then closed) | Evaluation criteria + test prompts for the target artifact |

Output path semantics vary by type (encoded in `type-config.md`):
- skill / tool: `<artifact-dir>/EVAL.md`
- agent / protocol: `<artifact-name>.eval.md` adjacent to the flat `.md` file

Exit signal: file path + tier-count summary (e.g., "Wrote EVAL.md with 12 EVAL-S, 7 EVAL-O, 4 test prompts").

---

## Flow graph

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

---

## Node specifications

**[NEW]** — Load: SKILL.md only. Do: wrong-tool detection (see Edge Cases); surface `argument-hint` if args are missing. Don't: load any flow file. Exit: → `[ROUTE]` once intent confirmed as eval generation.

**[ROUTE]** — Load: `references/type-config.md`. Do: validate `$TYPE ∈ {skill, protocol, agent, tool}`; validate `$ARTIFACT_PATH` exists and matches type expectations (dir vs flat file); check for existing EVAL.md and apply clobber guard; load exactly one `references/flow-<TYPE>.md`. Don't: inline any eval-generation logic; branch on `$TYPE` in `shared-steps.md`. Exit: → `flow-<TYPE>:[START]` on all-gates-pass; loud failure on any gate miss.

**flow-\<TYPE\>:[START … END]** — Load: the single loaded flow file + `references/shared-steps.md` as needed. Do: read artifact, dispatch type-specific agents (or scaffold for v1 non-skill flows), assemble EVAL.md fully in memory, write atomically. Don't: modify the artifact being evaluated; apply grades (that's gatekeeper's job). Exit: file path + tier-count summary.

---

## Entry gates

| Transition | Gate |
|---|---|
| [NEW] → [ROUTE] | Intent confirmed as EVAL.md generation (not improvement, grading, or brainstorm) |
| [ROUTE] → flow-\<TYPE\>:[START] | `$TYPE ∈ {skill, protocol, agent, tool}` AND `$ARTIFACT_PATH` exists AND type/path contract matches AND no existing EVAL.md (or `--force` passed) |
| flow-\<TYPE\>:[END] → done | EVAL.md written successfully; exit signal emitted |

---

## Companion files anticipated

**Always-loaded (at SKILL.md):**
- `SKILL.md` — router, <100 LOC

**Loaded at [ROUTE]:**
- `references/type-config.md` — per-type field/path map and tier-ID prefix table

**Loaded at flow dispatch (one per session):**
- `references/flow-skill.md` — skill EVAL flow (port from existing write-skill-eval)
- `references/flow-protocol.md` — protocol EVAL flow (new; v1 ships with scaffold + "needs dispatch agents" markers)
- `references/flow-agent.md` — agent EVAL flow (new; v1 ships with scaffold)
- `references/flow-tool.md` — tool EVAL flow (new; v1 ships with scaffold)

**Used within flows:**
- `references/shared-steps.md` — parameterized procedures (no `if $TYPE` branching; type variation via type-config lookup)

**Templates (loaded during assembly):**
- `templates/skill/eval.md` — EVAL-S/E/F/O + Test Prompts skeleton
- `templates/protocol/eval.md` — EVAL-S + EVAL-C (conformance) skeleton
- `templates/agent/eval.md` — EVAL-S + EVAL-D (dispatch/output) skeleton
- `templates/tool/eval.md` — EVAL-S + EVAL-X (exit-codes/side-effects) skeleton

---

## Directory layout

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

## SKILL.md frontmatter

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

## Per-type EVAL tier shape

<!-- VERBATIM -->
| Type     | Tiers                                                          | Test mechanism                                                |
|----------|----------------------------------------------------------------|---------------------------------------------------------------|
| skill    | EVAL-S (structural), EVAL-E (orchestration, opt), EVAL-F (flow-graph, opt), EVAL-O (output) + Test Prompts | Run skill on prompts via subagent, judge outputs              |
| protocol | EVAL-S (structural), EVAL-C (conformance assertions)           | Apply protocol to fixture artifacts, assert compliance        |
| agent    | EVAL-S (structural), EVAL-D (dispatch contract + output grade) | Dispatch agent with test inputs, judge outputs against role   |
| tool     | EVAL-S (structural), EVAL-X (exit-codes + side-effects)        | Invoke tool script with fixtures, assert exit codes + state   |

---

## MUST / MUST NOT

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

## Handoff contract

<!-- VERBATIM -->
- Callers: humans, `synapse-creator` (post-scaffold handoff), `improve-skill` (when EVAL.md missing)
- Inputs: `$TYPE`, `$ARTIFACT_PATH`
- Output: `EVAL.md` written into the artifact directory (or alongside the file for flat artifacts like agents/protocols)
- Exit signal: file path + tier-count summary (e.g., "Wrote EVAL.md with 12 EVAL-S, 7 EVAL-O, 4 test prompts")

---

## Edge cases considered

| Edge case | Handling |
|---|---|
| Existing EVAL.md at target path | Fail loudly: "EVAL.md exists; use `--force` to overwrite or `/improve-skill` to refine via measurement". No silent clobber. |
| Invalid `$TYPE` | Fail at `[ROUTE]` with valid-list message before any flow load |
| `$ARTIFACT_PATH` does not exist | Fail at `[ROUTE]` before flow load |
| Type/path mismatch (e.g., `$TYPE=skill` but path is a flat .md) | Fail loudly at `[ROUTE]` after type-config lookup |
| Subagent dispatch failure | No partial EVAL.md written; assembly stays in memory until all agents complete |
| User wants to improve against existing EVAL | Redirect to `/improve-skill` (wrong-tool detection at [NEW]) |
| User wants to certify/grade | Redirect to `/synapse-gatekeeper` (wrong-tool detection at [NEW]) |
| User wants to brainstorm what eval to write | Redirect to `/synapse-brainstorm` (wrong-tool detection at [NEW]) |
| Multi-artifact in one session | Reject; instruct caller to dispatch parallel agents (one invocation per artifact) |
| Pathway eval (5th type) | Out of v1 scope — additive extension, no design change needed when added |

---

## Dependencies

| Artifact | Direction | Contract |
|---|---|---|
| `synapse/skills/skill/write-skill-eval/` | consumes (porting) | flow-skill.md is a near-mechanical port of existing routing logic + agent dispatch |
| `synapse/agents/skill-eval/{prompter,judge,auditor}.md` | consumes | Existing dispatch agents stay in place; flow-skill.md dispatches them unchanged |
| `synapse/skills/synapse/synapse-creator/` | produces for | Post-scaffold handoff updated from dead `/write-agent-eval` to `/write-synapse-eval agent <path>` (resolves T3.6 FAIL) |
| `synapse/skills/skill/improve-skill/` | produces for | When EVAL.md missing, dispatch becomes `/write-synapse-eval skill <path>` (trivial 1-line edit) |
| `synapse-gatekeeper/references/{agent,protocol,tool}-checklist.md` | consumes | Canonical tier checklists; flow files derive tier IDs from these. Single-source-of-truth for drift prevention. |

---

## Sunset migration (post-merge)

<!-- VERBATIM -->
- Mark `synapse/skills/skill/write-skill-eval/` row in registry as `deprecated` with pointer to `write-synapse-eval`
- Keep the directory in place for one release cycle; update synapse-creator's `flow-skill.md` and any `/improve-skill` references to point to `/write-synapse-eval skill <path>`
- Update `flow-agent.md` (synapse-creator) — replace the dead `/write-agent-eval` handoff with `/write-synapse-eval agent <path>` (resolves T3.6 FAIL)

---

## Open questions

None. All 5 lenses applied and resolved during brainstorm. v1 ships with skill flow fully working (ported from write-skill-eval); protocol/agent/tool flows ship as scaffolds with "needs dispatch agents" markers — subsequent CRs add the missing dispatch agents per type.
