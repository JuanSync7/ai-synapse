# Decision Memo — synapse-creator

> Artifact type: skill | Memo type: creation | Design doc: `../../../../.brainstorms/2026-05-03-synapse-creator-consolidation/design.md`

---

## What I want

A single `synapse-creator` skill that replaces three existing fragmented creators (`skill-creator`, `protocol-creator`, `agent-creator`) and adds a missing fourth (`tool-creator`). The user invokes it once per artifact creation. The skill detects artifact type first, then loads only the matching type-specific flow — no other flow ever loads in the same session. Token cost stays low because only one flow and its references are active at a time.

The skill has a top SKILL.md that is a router only (~60–80 LOC), single `[ROUTE]` node. Four per-type flow files (`flow-{skill,protocol,agent,tool}.md`) live under `references/`. Shared scaffolding procedures (frontmatter validation, registry write, README row update, eval handoff, placement decision, draft-status marking) live in a single `references/shared-steps.md`, parametric on `$TYPE` via a `references/type-config.md` lookup. Design-principles files and templates are per-type and load only within their flow.

---

## Why Claude needs it

Without this skill, users invoke four separate creator skills with inconsistent interfaces and overlapping logic. `skill-creator` and `protocol-creator` each inline their own frontmatter validation, registry writes, and README row updates — both perform the same structural work with no shared source of truth. `agent-creator` is a 23-LOC stub that produces no usable output. `tool-creator` does not exist. Any improvement to a shared step (e.g., registry row format changes) must be made in multiple places or silently diverges.

Additionally, users must know which creator to call, and wrong-tool failures are silent (they just use the wrong skill). A router-first design with a single entry point eliminates that surface.

---

## Injection shape

- **Workflow:** Phase descriptions, flow graphs, and node specs for all four artifact types. The router node and all four type-specific flows are multi-phase workflows.
- **Policy:** Judgment rules for placement (`src/` vs `synapse/`), atomic-creation discipline (pre-flight before scaffolding), partial-state recovery (re-run detection), and eval handoff routing.
- **Domain knowledge:** Per-type config (taxonomy files, registry files, frontmatter required fields, eval conventions, README column schemas) loaded via `type-config.md` at `[ROUTE]` time. Design principles per artifact type loaded at design-injection nodes within the active flow.

---

## What it produces

| Output | Count | Mutable? | Purpose |
|---|---|---|---|
| Artifact spec file (SKILL.md / PROTOCOL.md / agent .md / TOOL.md) | 1 | yes | Primary artifact definition |
| Companion scaffold (references/, templates/, rules/, test/) | 1 set | yes | Type-specific companion directories and stubs |
| Registry row | 1 | yes | Adds artifact to type-specific registry file |
| Domain README row | 1 | yes | Adds artifact to domain README catalog table |
| EVAL.md or test/ scaffold | 1 | yes | Evaluation scaffold (EVAL.md for skill/agent/protocol; test/ for tools by default) |

---

## Flow graph

<!-- VERBATIM -->

```
# Loading discipline (key invariant)
SKILL.md                       always-on
type-config.md                 [ROUTE] (one time)
flow-<type>.md                 after [ROUTE], EXACTLY ONE
shared-steps.md                first parametric step in active flow
design-principles-<type>.md    design-injection node in active flow
templates/<type>/              scaffold node in active flow
# Other 3 types' flow/principles/templates: NEVER LOAD.
```

---

## Node specifications

**[ROUTE] — router/SKILL.md**
Load: `references/type-config.md`. Do: (1) If `$TYPE` missing → prompt "What type? [skill|protocol|agent|tool]". (2) Validate `$TYPE` against type-config valid-values list. (3) Load `references/flow-<TYPE>.md`. (4) Jump to that flow's `[START]`. Don't: proceed without confirmed `$TYPE`; inline any creation logic; load more than one flow file. Exit: → `flow-<TYPE>:[START]`. Hard-gate: `$TYPE` must be one of `{skill, protocol, agent, tool}` before `[ROUTE]` exits. Name argument must match `[a-z0-9-]+` regex.

**[START] (per-flow) — type detection complete, pre-flight begins**
Load: `references/shared-steps.md`. Do: run `validate-frontmatter($TYPE, $artifact_dir)` then `placement-decision($TYPE)`. All validations complete before any file is written. Don't: scaffold any files if pre-flight fails. Exit: → `[W]` (write/scaffold node) on pre-flight pass; → fail loudly on pre-flight failure.

**[W] (per-flow) — scaffold artifact**
Load: `references/design-principles-<TYPE>.md`, `templates/<TYPE>/`. Do: scaffold all artifact files in one operation. Call `shared-steps:write-registry-row`, `shared-steps:update-domain-readme`, `shared-steps:status-draft-mark`. Don't: partially scaffold (all-or-nothing within the write phase). Exit: → `[EVAL]`.

**[EVAL] (per-flow) — eval handoff**
Load: none (uses type-config). Do: call `shared-steps:handoff-eval($TYPE)` which dispatches `write-{type}-eval` per type-config. Tools' `write-tool-eval` internally decides `test/` vs `EVAL.md` based on tool nature. Don't: grade the produced artifact's body quality (that is downstream via `write-{type}-eval` + `synapse-gatekeeper`). Exit: → `[END]`.

**[END] — report**
Do: print verbatim what was created (file list), registry row added, README row added, eval/test scaffold generated, status: draft. Remind user to run `/synapse-gatekeeper` before promoting.

---

## Entry gates

| Transition | Gate |
|---|---|
| `[ROUTE]` → `flow-<TYPE>:[START]` | `$TYPE` confirmed + validated; name matches `[a-z0-9-]+` |
| `[START]` → `[W]` | All pre-flight validations pass; no existing artifact at target path (or user selects "complete partial creation") |
| `[W]` → `[EVAL]` | All scaffold files written successfully |
| `[EVAL]` → `[END]` | `handoff-eval` dispatched (does not block on downstream eval completion) |

---

## Notepad architecture

Not applicable — synapse-creator does not use a notepad. It is a single-session, single-artifact workflow.

---

## Naming conventions

**Artifact name:** `synapse-creator` (confirmed in brainstorm turn 5).

**Directory placement:** `synapse/skills/synapse/synapse-creator/` — path subdomain must equal frontmatter `domain`. Earlier consideration of `synapse/skills/meta/` dropped because the path subdomain must match `domain: synapse` per repo convention.

**Per-type reference files:** `flow-{skill,protocol,agent,tool}.md`, `design-principles-{skill,protocol,agent,tool}.md`. Consistent `<role>-<type>.md` pattern.

**Frontmatter (final, verbatim):**

<!-- VERBATIM -->
```yaml
---
name: synapse-creator
description: Use when creating a new skill, protocol, agent, or tool in ai-synapse. Routes to type-specific creation flow.
domain: synapse
intent: write
tags: [creator, scaffold, multi-artifact, router]
user-invocable: true
argument-hint: "<skill|protocol|agent|tool> [name]"
---
```

---

## Companion files anticipated

<!-- VERBATIM -->
```
synapse-creator/
├── SKILL.md                                # Top router (~60–80 LOC)
├── EVAL.md                                 # Gatekeeper EVAL for synapse-creator itself
├── references/
│   ├── type-config.md                      # Per-type config lookup
│   ├── shared-steps.md                     # Parametric-shared step procedures
│   ├── flow-skill.md                       # Skill creation flow (port from skill-creator)
│   ├── flow-protocol.md                    # Protocol creation flow (port from protocol-creator)
│   ├── flow-agent.md                       # Agent creation flow (clean-room)
│   ├── flow-tool.md                        # Tool creation flow (clean-room)
│   ├── design-principles-skill.md          # Port verbatim from skill-creator
│   ├── design-principles-protocol.md       # Extract from protocol-creator
│   ├── design-principles-agent.md          # Clean-room
│   └── design-principles-tool.md           # Clean-room
└── templates/
    ├── skill/                              # SKILL.md + references/ + EVAL.md skeletons
    ├── protocol/                           # PROTOCOL.md + rules/ + examples/ skeletons
    ├── agent/                              # agent .md skeleton
    └── tool/                              # TOOL.md + script + test/ skeletons
```

**Load points:**

| File | Loaded at | Purpose |
|---|---|---|
| `SKILL.md` | always-on | Router only; single `[ROUTE]` node |
| `references/type-config.md` | `[ROUTE]` | Per-type config lookup (taxonomy/registry/README paths, frontmatter fields, eval convention) |
| `references/shared-steps.md` | first parametric step in active flow | Procedures: `validate-frontmatter`, `write-registry-row`, `update-domain-readme`, `handoff-eval`, `placement-decision`, `status-draft-mark` |
| `references/flow-skill.md` | after `[ROUTE]` when `$TYPE=skill` | Full skill creation flow (ported from skill-creator) |
| `references/flow-protocol.md` | after `[ROUTE]` when `$TYPE=protocol` | Full protocol creation flow (ported from protocol-creator) |
| `references/flow-agent.md` | after `[ROUTE]` when `$TYPE=agent` | Agent creation flow (clean-room) |
| `references/flow-tool.md` | after `[ROUTE]` when `$TYPE=tool` | Tool creation flow (clean-room) |
| `references/design-principles-skill.md` | design-injection node in `flow-skill` | Ported/moved from `skill-creator/references/skill-design-principles.md` |
| `references/design-principles-protocol.md` | design-injection node in `flow-protocol` | Extracted from `protocol-creator/references/` |
| `references/design-principles-agent.md` | design-injection node in `flow-agent` | Clean-room |
| `references/design-principles-tool.md` | design-injection node in `flow-tool` | Clean-room |
| `templates/skill/` | scaffold node in `flow-skill` | SKILL.md + references/ + EVAL.md skeletons |
| `templates/protocol/` | scaffold node in `flow-protocol` | PROTOCOL.md + rules/ + examples/ skeletons |
| `templates/agent/` | scaffold node in `flow-agent` | Agent .md skeleton with frontmatter |
| `templates/tool/` | scaffold node in `flow-tool` | TOOL.md + script template (.sh or .py) + test/ scaffold |

**agents/ (per-flow subdirectory per turn-6 decision B):**

| File | Flow | Purpose |
|---|---|---|
| `agents/skill/` | `flow-skill` | Companion agent symlinks for skill creation (from skill-creator/agents/) |
| `agents/protocol/protocol-eval-reviewer.md` | `flow-protocol` | Moved from `protocol-creator/agents/protocol-eval-reviewer.md` |
| `agents/agent/` | `flow-agent` | Agent creation companion agents (if any) |
| `agents/tool/` | `flow-tool` | Tool creation companion agents (if any) |

---

## Edge cases considered

| Edge case | Handling |
|---|---|
| `$TYPE` missing from invocation | Interactive prompt: "What type? [skill\|protocol\|agent\|tool]" |
| `$TYPE` invalid value | Fail at `[ROUTE]` before loading any flow; print valid values |
| Name argument contains uppercase or special chars | Hard-gate regex `[a-z0-9-]+` at `[ROUTE]`; fail with pattern hint |
| Artifact name already exists at target path | Pre-flight `validate-frontmatter` detects collision; fail loudly before scaffolding |
| Target registry/README/taxonomy file missing | Fail loudly, no auto-creation — hides infrastructure problems |
| Post-scaffold failure (e.g., registry write fails after files written) | Leave partial state; report verbatim what succeeded + what failed + what to clean up; no auto-rollback |
| Re-run after partial creation | `shared-steps` detects existing files; offer "complete partial creation?" or "abort and clean up?" |
| User invokes `/synapse-creator` to modify an existing artifact | Wrong-tool detection → redirect to `/improve-skill` |
| User invokes `/synapse-creator` without a specific idea yet | Wrong-tool detection → redirect to `/synapse-brainstorm` |
| Multiple artifacts in one session | Not supported — concurrency contract: ONE artifact per invocation; multi-artifact sessions use parallel synapse-creator agents |
| NL type inference (e.g., "make me a skill that does X") | Rejected; always prompt for explicit type confirmation |
| Aliases ("skills" → "skill") and case-insensitivity | Creator decides at build time |

---

## Dependencies

| Artifact | Direction | Contract |
|---|---|---|
| `taxonomy/SKILL_TAXONOMY.md` | consumes | Validates `domain`+`intent` for skill artifacts; read by `validate-frontmatter` via type-config |
| `taxonomy/AGENT_TAXONOMY.md` | consumes | Validates `domain`+`role` for agent artifacts |
| `taxonomy/PROTOCOL_TAXONOMY.md` | consumes | Validates `domain`+`type` for protocol artifacts |
| `registry/SKILL_REGISTRY.md` | consumes + produces for | Reads to check name uniqueness; writes new row via `write-registry-row` |
| `registry/AGENTS_REGISTRY.md` | consumes + produces for | Same pattern for agent artifacts |
| `registry/PROTOCOL_REGISTRY.md` | consumes + produces for | Same pattern for protocol artifacts |
| `write-skill-eval` | produces for | `handoff-eval(skill)` dispatches this skill to generate EVAL.md |
| `write-agent-eval` | produces for | `handoff-eval(agent)` dispatches this |
| `write-protocol-eval` | produces for | `handoff-eval(protocol)` dispatches this |
| `write-tool-eval` (to be created) | produces for | `handoff-eval(tool)` dispatches this; write-tool-eval decides test/ vs EVAL.md |
| `/synapse-gatekeeper` | produces for | Every artifact synapse-creator produces must pass gatekeeper before promotion from `status: draft` |
| `skill-creator` | replaces | Source for flow-skill.md port (157 LOC); `design-principles-skill.md` MOVES here |
| `protocol-creator` | replaces | Source for flow-protocol.md port (216 LOC); design principles + rules/banned-words + agents/protocol-eval-reviewer MOVE here |
| `agent-creator` | replaces | 23-LOC stub; flow-agent is clean-room |

---

## Companion file specifications

### references/type-config.md — schema

<!-- VERBATIM -->
```yaml
skill:
  artifact_dir_prefix: "src/skills"   # synapse/skills if framework
  spec_file: "SKILL.md"
  taxonomy_file: "taxonomy/SKILL_TAXONOMY.md"
  registry_file: "registry/SKILL_REGISTRY.md"
  frontmatter_required: [name, description, domain, intent, tags, user-invocable]
  eval_convention: "EVAL.md"
  readme_columns: [name, description, domain, intent, status]
  flow_file: "references/flow-skill.md"
  design_principles_file: "references/design-principles-skill.md"
  templates_dir: "templates/skill/"
protocol: { ... }
agent: { ... }
tool:
  spec_file: "TOOL.md"
  eval_convention: "test/"   # not EVAL.md by default
  ...
```

### references/shared-steps.md — procedure list

Six parametric procedures. Each takes `$TYPE` and reads `type-config`. Hard rule: NO `if $TYPE == ...` conditionals inside any procedure body — all type variation comes from the type-config lookup.

1. `validate-frontmatter($TYPE, $artifact_dir)` — required fields present per type-config; domain/intent/role/type in correct taxonomy; name matches `[a-z0-9-]+`; name globally unique (no collision in target dir or registry)
2. `write-registry-row($TYPE, $meta)` — append row to type-specific registry file (path from type-config)
3. `update-domain-readme($TYPE, $domain, $meta)` — insert row in domain README table with type-specific columns (from type-config)
4. `handoff-eval($TYPE, $artifact_path)` — dispatch `write-{type}-eval` per type-config; tools' `write-tool-eval` decides test/ vs EVAL.md internally
5. `placement-decision($TYPE)` — `src/` default; prompt if `synapse/` requested (framework placement)
6. `status-draft-mark($TYPE, $meta)` — ensure `status: draft` in registry row until `/synapse-gatekeeper` approves

Callable from any flow file via `→ shared-steps:<step-name>`.

### flow-skill.md — source and shape

Port from `skill-creator/SKILL.md` (157 LOC). Preserve flow shape:

```
[NEW] (wrong-tool) → [U] (understand goal) → [B] (baseline test, "is this needed?")
    → [W] (write skill, calls shared-steps) → [V] (validate via /improve-skill) → [END]
```

Drop skill-creator's self-improvement infrastructure: SCOPE.md, PROGRAM.md, research/ dir, test-inputs/ dir, "Execution scope: ignore" lines — those belong at synapse-creator root if wanted, not per-flow. Replace inline frontmatter/registry/README writes with `shared-steps:*` calls. Load `design-principles-skill.md` at `[W]`, `templates/skill/` at scaffold step.

`design-principles-skill.md` — **MOVE** (not copy) from `skill-creator/references/skill-design-principles.md`. Single source of truth.

### flow-protocol.md — source and shape

Port from `protocol-creator/SKILL.md` (216 LOC) + ancillary references. Target ~120–150 LOC after parametric work moves to shared-steps. Preserve protocol-specific shape (AXI4-style imperative-rules creation, rules/ + examples/ generation, single-interaction-point validation).

Protocol-creator subdir migration:
- `rules/banned-words.md` → `references/banned-words-protocol.md` (loaded at flow-protocol design node)
- `examples/good-protocol.md` → `templates/protocol/example.md`
- `references/protocol-design-principles.md` → `references/design-principles-protocol.md`
- `templates/protocol-skeleton.md` → `templates/protocol/skeleton.md`
- `agents/protocol-eval-reviewer.md` → `agents/protocol/protocol-eval-reviewer.md`

`design-principles-protocol.md` — extract from protocol-creator/references/ + rules/. Distinct: imperative trigger-clear rules, no rationalization escapes, single interaction point.

### flow-agent.md — shape (clean-room)

Source: clean-room (current agent-creator is 23-LOC stub). 6 framework agents confirmed to exist — `≥5` threshold met; full design (not stub-warning). Agents are flat `.md` files, NOT directories with companions — scaffolding is just one file + frontmatter. Target ~80 LOC. Load `design-principles-agent.md` at write node.

`design-principles-agent.md` — clean-room. Tentative principles: single-purpose, narrow tool scope, idempotent, explicit input/output contract in frontmatter, no hidden side effects.

### flow-tool.md — shape (clean-room)

Source: clean-room. Grounded in `synapse-cr-dispatcher` precedent (TOOL.md + script + test/ shape). Target ~80–100 LOC.

Distinct concerns:
- Mechanical not judgmental — replace "context injection" principle with "deterministic contract"
- Asks for language at `[W]` (.sh, .py, ...) — script template per language from `templates/tool/`
- Side-effect manifest in TOOL.md — explicit list of files/services touched
- `handoff-eval(tool)` dispatches `write-tool-eval`; that skill decides test/ vs EVAL.md based on tool nature (judgment-laden output? → EVAL.md; mechanical? → test/ only)

`design-principles-tool.md` — clean-room. Tentative: deterministic output, explicit side-effect manifest, fail loudly on bad input, exit codes are contracts, declare all integrations.

---

## EVAL scope

Structural + routing correctness + per-type mechanical correctness. Four fixed prompts (one per type) each assert:
1. Correct flow file loaded (and only that one)
2. Artifact directory created at expected path
3. Frontmatter valid (required fields present, taxonomy values correct)
4. Registry row added to correct registry file
5. Domain README row added
6. EVAL.md or test/ scaffold generated

EXCLUDES grading the produced artifact's body quality — that is handled downstream by `write-{type}-eval` + `/synapse-gatekeeper`.

---

## Cross-cutting items

### CC1 — Taxonomy migration (DONE, commit `166086a`)

ALL ai-synapse framework artifacts under `synapse/` migrated to `domain: synapse`. Applied to SKILL_TAXONOMY.md + 24 framework artifacts (16 skills, 5 agents, 3 protocols). Unification applies to AGENT_TAXONOMY, PROTOCOL_TAXONOMY, TOOL_TAXONOMY as well (per turn-6 decision). Adopter artifacts under `src/` retain per-class domains.

Side effect: pre-commit lifecycle hook auto-demoted 10 previously-stable skills to `draft` in `registry/SKILL_REGISTRY.md` (skill-router, autonomous-orchestrator, parallel-agents-dispatch, stakeholder-reviewer, protocol-creator, improve-skill, skill-creator, synapse-brainstorm, synapse-gatekeeper, write-skill-eval). Re-run `/synapse-gatekeeper` on these after synapse-creator lands.

### CC2 — Sunset migration (pending)

Actionable only after synapse-creator is built, all 4 type-flows pass EVAL, and cross-check passes (run synapse-creator on a known-good prior creation, compare output to original creator output).

Cross-check coexistence concern: during the cross-check window both old creators and synapse-creator coexist. Confirm pre-commit hook tolerates temporary duplicate registry rows and that name-uniqueness check does not fire on type-renamed skills.

Post-cross-check delete list:
- `synapse/skills/skill/skill-creator/` (full directory)
- `synapse/skills/protocol/protocol-creator/` (full directory)
- `synapse/skills/agent/agent-creator/` (full directory)

Post-delete update list:
- `synapse-brainstorm` wrong-tool refs: `/skill-creator` → `/synapse-creator skill`
- `improve-skill` references to old creator names
- `GOVERNANCE.md` if it references old creators
- `registry/SKILL_REGISTRY.md` rows for deleted skills

### CC3 — Knowledge transfer audit (pending, actionable now)

Before deleting old creators, produce an explicit inventory checklist comparing pre-deletion state vs post-migration state in synapse-creator references. Nothing may be lost.

Audit checklist to complete:

**skill-creator → flow-skill.md + design-principles-skill.md:**
- [ ] All flow nodes ported (names + sequencing)
- [ ] All hard-gates preserved
- [ ] All HITL checkpoints preserved
- [ ] All wrong-tool detection rules ported
- [ ] All `references/` content accounted for (moved/merged/dropped with reason)
- [ ] All `templates/` content accounted for
- [ ] `agents/` symlinks accounted for (moved to `agents/skill/`)
- [ ] PROGRAM.md / SCOPE.md: confirmed intentionally dropped (self-improvement infra)

**protocol-creator → flow-protocol.md + design-principles-protocol.md:**
- [ ] All flow nodes ported
- [ ] All hard-gates and HITL checkpoints preserved
- [ ] `rules/banned-words.md` → `references/banned-words-protocol.md` ✓ planned
- [ ] `examples/good-protocol.md` → `templates/protocol/example.md` ✓ planned
- [ ] `agents/protocol-eval-reviewer.md` → `agents/protocol/protocol-eval-reviewer.md` ✓ planned
- [ ] All other `references/` and `templates/` content accounted for

**agent-creator → flow-agent.md:**
- [ ] 23-LOC stub reviewed; any usable content extracted or confirmed replaced by clean-room design

---

## Open questions

- **`agents/` subdirectory inside synapse-creator:** per-flow `agents/{skill,protocol,agent,tool}/` subdirectories confirmed (turn-6 decision B). Creator confirms exact symlink targets at build time.
- **EVAL.md for synapse-creator itself:** routing correctness + per-type mechanical correctness (4 fixed prompts) confirmed scope. Creator decides exact metric thresholds.
- **Argument parsing strictness:** case-insensitive? Aliases ("skills" → "skill")? Creator decides.
- **Interactive prompt UX when type missing:** single-letter shortcut menu? Creator decides.
- **Tool's frontmatter handling:** TOOL.md has YAML frontmatter (per synapse-cr-dispatcher); script file itself does not. Creator confirms convention.
- **Agent count in flow-agent:** 6 framework agents confirmed, `≥5` threshold met — full flow design (not stub-warning). Creator verifies count at build time.
- **Cross-taxonomy migration for non-skill taxonomies:** confirmed YES (turn-6). Creator verifies AGENT_TAXONOMY, PROTOCOL_TAXONOMY, TOOL_TAXONOMY updated before landing.
- **`write-tool-eval` existence:** does not exist yet. flow-tool.md's `[EVAL]` node depends on it. Either create it as part of this build or document the fallback behavior (inline test/ scaffold generation without dispatching a separate skill).
- **Follow-on consolidations (NOT in scope):** `synapse-improver` (consolidate improve-skill + analogues), `synapse-eval-writer` (consolidate write-{skill,protocol,agent,tool}-eval). Same router pattern. Separate brainstorms after synapse-creator pattern lands.
