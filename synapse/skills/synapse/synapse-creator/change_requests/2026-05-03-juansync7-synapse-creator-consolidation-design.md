# Design Document — synapse-creator Consolidation

> Brainstorm slug: `2026-05-03-synapse-creator-consolidation`
> Status: **complete** | Artifact: skill (creation) | Target: `synapse/skills/synapse/synapse-creator/`

---

## 1. Problem Statement

The ai-synapse framework has four artifact-creation workflows that share 70%+ of their mechanics: frontmatter validation, registry write, domain README row insertion, EVAL handoff, placement decision, and status-draft marking. Today these live in three separate skills (`skill-creator`, `protocol-creator`, a 23-LOC stub `agent-creator`) and one that does not exist at all (`tool-creator`). This creates three concrete problems:

1. **Divergence cost.** Any change to shared mechanics must be applied to every creator separately — or it gets missed, causing inconsistent creation behavior across artifact types.
2. **Incomplete coverage.** `agent-creator` is a stub; `tool-creator` does not exist. Users building agents or tools have no guided creation workflow.
3. **Discovery friction.** Four separate entry points for the same conceptual action (create a new artifact) require the user to know which creator applies to which type, rather than naming the action and the type.

What changes: a single `synapse-creator` skill replaces all existing creators, using router-based progressive disclosure so each session loads only the flow relevant to the requested type.

---

## 2. Design Principles

### P1: Route First, Load Second

The router commits to a single artifact type before any type-specific content loads. This is not merely an organizational choice — it is what makes the token budget viable. If type determination were deferred until mid-flow, references from multiple flows would already be resident. By making `$TYPE` a hard gate at `[ROUTE]`, the three unselected flows, their design-principles files, and their templates are guaranteed never to load in a given session.

**Implication:** SKILL.md does nothing but routing. No validation logic, no scaffolding, no HITL. Any behavior added to SKILL.md that is not routing creates pressure toward type-specific branching, which violates the invariant.

### P2: Parameterization, Not Conditionals

The shared mechanics (validate-frontmatter, write-registry-row, update-domain-readme, handoff-eval, placement-decision, status-draft-mark) run for every artifact type, but with different inputs: different taxonomy files, different registry files, different README schemas, different frontmatter required-fields. This variation lives entirely in `type-config.md` — a static lookup table. `shared-steps.md` contains zero `if $TYPE == ...` branching; it reads type-config and acts on whatever it finds.

**Implication:** Adding a new artifact type (e.g., `pathway`) costs exactly one new type-config entry, one new flow file, and one new templates directory — no changes to shared-steps logic. The extension cost is bounded and predictable.

### P3: Atomic Creation via Pre-flight

All validations run before any files are written. If any pre-flight check fails, nothing is scaffolded. This is the rollback-by-construction approach: because no files exist yet when validation fails, there is nothing to roll back. Post-scaffold failures (disk full, permissions) are environmental and unrecoverable by retry — shared-steps reports verbatim what succeeded and what failed, and the user re-runs with resume detection.

**Implication:** Flow files must fail at the pre-flight node before reaching `[W]`, never after. Any validation that runs after scaffolding begins breaks the atomic guarantee.

### P4: Move, Don't Copy

`design-principles-skill.md` is moved from `skill-creator/references/` into `synapse-creator/references/`, not copied. Same for `design-principles-protocol.md` from `protocol-creator/references/`. During the cross-check window both old creators and synapse-creator coexist, but the moved files are the single source. No duplication.

**Implication:** Old creators become unreliable during the cross-check window (their design-principles refs are gone). This is acceptable — cross-check is the signal to delete them, and deliberate fragility accelerates the transition.

### P5: EVAL Scope Stops at the Boundary

synapse-creator's own EVAL covers: structural conformance, routing correctness (correct flow loaded for each type), and mechanical correctness (four fixed prompts assert artifact directory created, frontmatter valid, registry row added, README row added, EVAL/test scaffold generated). It does NOT grade the body quality of produced artifacts — that is the downstream job of `write-{type}-eval` + `synapse-gatekeeper`.

**Implication:** synapse-creator is accountable for the scaffold, not the content. This keeps synapse-creator's EVAL deterministic and automation-friendly, while pushing subjective quality judgment to the tools that already handle it.

---

## 3. Architecture

### 3.1 Flow Graph

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

### 3.2 Node Specifications

#### [ROUTE] — type determination and flow load

Load: `references/type-config.md`

Do:
1. If `$TYPE` argument missing → prompt "What type? [skill|protocol|agent|tool]"
2. Validate `$TYPE` against type-config valid values
3. Validate `$NAME` matches `[a-z0-9-]+` regex; prompt if missing or invalid
4. Load `references/flow-<TYPE>.md`
5. Jump to flow's `[START]`

Don't: Continue without confirmed, valid `$TYPE`. Don't inline any creation logic — routing only.

Exit: → `flow-<TYPE>:[START]`

#### shared-steps procedures (loaded by any flow at parametric nodes)

Each procedure takes `$TYPE` and reads from type-config. No `if $TYPE == ...` branching inside shared-steps.

1. `validate-frontmatter($TYPE, $artifact_dir)` — required fields present, domain/intent in taxonomy, name globally unique; fails loudly if registry/taxonomy files missing (no auto-creation)
2. `write-registry-row($TYPE, $meta)` — append row to type-specific registry file
3. `update-domain-readme($TYPE, $domain, $meta)` — insert row in domain README table
4. `handoff-eval($TYPE, $artifact_path)` — dispatch `write-{type}-eval`; for tools, `write-tool-eval` decides internally whether to generate `test/` scaffold or EVAL.md based on tool nature
5. `placement-decision($TYPE)` — `src/` default; prompt only if user requests `synapse/`
6. `status-draft-mark($TYPE, $meta)` — ensure `status: draft` until `/synapse-gatekeeper` approves

#### flow-skill (loaded when `$TYPE=skill`)

Source: port from `skill-creator/SKILL.md` (157 LOC). Preserve flow shape: `[NEW]` (wrong-tool) → `[U]` (understand goal) → `[B]` (baseline test, "is this needed?") → `[W]` (write skill) → `[V]` (validate via `/improve-skill`) → `[END]`. At `[W]` sub-steps, replace inline frontmatter/registry/README writes with `shared-steps:*` calls. Drop self-improvement infrastructure (SCOPE.md, PROGRAM.md, research/, test-inputs/). Load `design-principles-skill.md` at `[W]`; load `templates/skill/` at scaffold step.

#### flow-protocol (loaded when `$TYPE=protocol`)

Source: port from `protocol-creator/SKILL.md` (216 LOC) + ancillary references. Target ~120–150 LOC after parametric work moves to shared-steps. Preserve protocol-specific shape: AXI4-style imperative-rules creation, `rules/` + `examples/` generation, single-interaction-point validation. Companion file migrations: `rules/banned-words.md` → `references/banned-words-protocol.md`; `examples/good-protocol.md` → `templates/protocol/example.md`; `agents/protocol-eval-reviewer.md` → `agents/protocol/protocol-eval-reviewer.md`.

#### flow-agent (loaded when `$TYPE=agent`)

Source: clean-room (current agent-creator is 23-LOC stub; 6 framework agents exist, meeting the ≥5 threshold). Agents are single-file `.md`, not directories with companions — scaffolding is one file + frontmatter. Flow is shorter than skill flow (~80 LOC target). Load `design-principles-agent.md` at design node; load `templates/agent/` at scaffold step.

#### flow-tool (loaded when `$TYPE=tool`)

Source: clean-room, grounded in `synapse-cr-dispatcher` precedent (TOOL.md + script + `test/`). Generates three outputs together: TOOL.md + script template (language choice at `[W]`, `.sh` or `.py`) + `test/` scaffold. Distinct from other flows: replace "context injection" design principle with "deterministic contract"; explicit side-effect manifest required in TOOL.md; `write-tool-eval` decides test/ vs EVAL.md per tool nature. Load `design-principles-tool.md` at design node; load `templates/tool/` at scaffold step.

### 3.3 Entry Gates

| Transition | Gate conditions |
|---|---|
| `[ROUTE] → flow-<TYPE>:[START]` | `$TYPE` is one of {skill, protocol, agent, tool}; `$NAME` matches `[a-z0-9-]+` |
| pre-flight → `[W]` (in any flow) | All shared-steps pre-flight validations pass: frontmatter fields valid, taxonomy exists, registry file exists, domain README exists, name is globally unique |
| `[W]` → `[V]` / `[END]` (in any flow) | All required scaffold files created; registry row appended; domain README row inserted |

---

## 4. Directory Structure

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
│   └── design-principles-tool.md          # Clean-room
└── templates/
    ├── skill/                              # SKILL.md + references/ + EVAL.md skeletons
    ├── protocol/                           # PROTOCOL.md + rules/ + examples/ skeletons
    ├── agent/                              # agent .md skeleton
    └── tool/                               # TOOL.md + script + test/ skeletons
```

---

## 5. Canonical Frontmatter

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

## 6. type-config Schema

The `type-config.md` file is data-only — no prose, no branching logic. It is the single source of truth for all type-specific configuration consumed by shared-steps. Representative schema:

```yaml
skill:
  artifact_dir_prefix: "src/skills"       # synapse/skills if framework placement
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
  eval_convention: "test/"                # default; write-tool-eval may upgrade to EVAL.md
  ...
```

---

## 7. Migration and Sunset Plan

The consolidation happens in three phases, tracked as cross-cutting deliverables (CC1–CC3).

**(CC1) Taxonomy migration — DONE.** Committed at `166086a` on `develop`. 24 framework artifacts migrated to `domain: synapse` (16 skills, 5 agents, 3 protocols). Pre-commit lifecycle hook auto-demoted 10 previously-stable skills to `draft` in `registry/SKILL_REGISTRY.md` — these require `/synapse-gatekeeper` re-runs downstream of this brainstorm.

**(CC2) Sunset migration — pending.** Blocked on: synapse-creator build + EVAL pass + cross-check against a known-good prior creation. Cross-check is the go/no-go gate. After cross-check passes:
- Delete `skill-creator/`, `protocol-creator/`, `agent-creator/`
- Update `synapse-brainstorm` wrong-tool refs: `/skill-creator` → `/synapse-creator skill`
- Update `improve-skill` references to old creators
- Update `GOVERNANCE.md` if it references old creators
- Update `registry/SKILL_REGISTRY.md` rows

During the cross-check window, old creators and synapse-creator coexist. Pre-commit hook name-uniqueness check may fire — confirm tolerance before committing cross-check window state.

**(CC3) Knowledge transfer audit — pending.** Before deleting old creators, produce an explicit inventory checklist: sub-flows, design principles, hard-gates, HITL checkpoints, wrong-tool rules, templates, companion agents, per-node references, and EVAL criteria from each existing creator — compared against synapse-creator references to confirm nothing is lost.

**Design-principles MOVE (not copy).** `skill-creator/references/skill-design-principles.md` is moved (not copied) to `synapse-creator/references/design-principles-skill.md`. Same for protocol. During the cross-check window, old creators lose their design-principles refs — this is deliberate fragility that accelerates the transition.

---

## 8. Concurrency and Invocation Contract

synapse-creator handles exactly ONE artifact per invocation. Multi-artifact sessions use parallel synapse-creator agents, one per artifact. A single invocation MUST NOT create multiple artifacts — this is the concurrency contract enforced by the `[ROUTE]` hard-gate.

Input: `/synapse-creator <type> [name]`
- `type` ∈ {skill, protocol, agent, tool} — required; interactive menu fallback if missing
- `name` — optional at invocation; interactive prompt fallback; validated as `[a-z0-9-]+`

Output (for any type): artifact directory created under `src/<artifact-class>/<domain>/<name>/` (default) or `synapse/...` (explicit framework placement); all required scaffold files present; frontmatter validated; registry row added; domain README row added; EVAL/test scaffold generated; `status: draft`.

---

## 9. Follow-on Candidates (Out of Scope)

Two sibling consolidations follow the same router pattern and become straightforward once synapse-creator lands:

- **synapse-improver** — consolidates `improve-skill` + future protocol/agent/tool improvers
- **synapse-eval-writer** — consolidates `write-skill-eval`, `write-protocol-eval`, `write-agent-eval`, and a future `write-tool-eval`

These are deferred to separate brainstorms. They are mentioned here as a record of the recognized pattern, not as commitments.

---

## 10. Accepted Tensions

| Tension | Decision | Revisit when |
|---|---|---|
| Monolith-with-router vs thin-entrance + 4 separate creators | Monolith-with-router: one SKILL.md routes to per-type flows. Separate creator shells rejected (duplicates discovery problem, doesn't fix divergence cost). | If a fifth artifact type requires fundamentally incompatible routing logic |
| Design-principles files: move vs copy during cross-check window | Move — single source, deliberate fragility on old creators to accelerate sunset | If cross-check window unexpectedly extends; revert to copy if blocking |
| `handoff-eval` unified vs split into `handoff-eval-writer` + `scaffold-test-dir` | Unified: single `handoff-eval($TYPE)` dispatches `write-{type}-eval`; type-config lookup keeps shared-steps parametric | If tool EVAL semantics diverge significantly from write-tool-eval's current plan |
| tool-creator: requires upstream governance work (TOOL_TAXONOMY, TOOL_REGISTRY, frontmatter convention) | Proceed with clean-room design in flow-tool.md; upstream work tracked as flow-tool Open items | Before flow-tool ships to production |
| NL-inference for type detection (e.g., "make me a skill") | Rejected: brittle, token cost, harder to test. User-arg primary, interactive fallback. | If user research shows significant friction with explicit type argument |

---

## 11. Dependencies

| Artifact | Direction | Contract |
|---|---|---|
| `taxonomy/SKILL_TAXONOMY.md` | consumes | `domain: synapse`, `intent: write` must be valid entries — satisfied by CC1 migration |
| `registry/SKILL_REGISTRY.md` | produces for | synapse-creator adds its own row at creation; shared-steps writes rows for artifacts it creates |
| `synapse-brainstorm` | produces for (wrong-tool) | synapse-brainstorm wrong-tool block must redirect to `/synapse-creator <type>` — updated at CC2 sunset |
| `improve-skill` | produces for (wrong-tool) | synapse-creator wrong-tool block redirects existing-artifact modification to `/improve-skill` |
| `synapse-gatekeeper` | produces for | created artifacts land at `status: draft`; gatekeeper is the certification path |
| `write-{skill,protocol,agent,tool}-eval` | consumes (dispatches) | `handoff-eval($TYPE)` dispatches the type-specific eval writer; `write-tool-eval` must exist before flow-tool ships |
| `skill-creator`, `protocol-creator`, `agent-creator` | replaces | sunset after cross-check passes (CC2); knowledge transfer audit required (CC3) |
