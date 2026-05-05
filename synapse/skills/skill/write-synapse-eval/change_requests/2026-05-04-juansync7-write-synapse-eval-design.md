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

### Mirror synapse-creator's router architecture — not its flow symmetry

The `synapse-creator` router pattern (SKILL.md + `flow-{type}.md` + `shared-steps.md` + `type-config.md` + `templates/{type}/`) has been proven across four artifact types and is inherited without modification. However, the flow files are NOT symmetric: the actual problem shapes differ by type. `flow-skill.md` is dispatch-rich because skill evaluation requires subjective output grading; `flow-{protocol,agent,tool}.md` are short transcription flows because gatekeeper grading criteria for those types are entirely static checklists. Imposing symmetry where none exists would bloat flows with logic that has no real work to do.

**Implication:** `flow-skill.md` ≈ 120 LOC (port existing write-skill-eval routing + 3 agent dispatches + assembly); `flow-protocol.md` and `flow-agent.md` ≈ 50 LOC each; `flow-tool.md` ≈ 60 LOC. The router earns its place through a single entry point and a unified MUST/MUST-NOT contract — not through flow-file uniformity.

### Single-source-of-truth for non-skill evaluation criteria

`synapse-gatekeeper/references/{agent,protocol}-checklist.md` are the canonical grading criteria for those artifact types. Baking those criteria into templates or flow files would create dual-maintenance drift: criteria in EVAL.md outputs would diverge from what gatekeeper actually applies. Transcription flows load the checklist files at run-time and adapt them to EVAL-Sxx tier format — they do not reproduce checklist content inline.

**Implication:** If a gatekeeper checklist file is missing or renamed, the transcription flow fails loud with the unresolved Load path. No fallback content is baked into templates. Pre-commit hook check that the Load target resolves is additive structural validation.

### Read-only against source artifact — no taxonomy validation

`write-synapse-eval` reads the source artifact's frontmatter only to extract the artifact name and verify the file exists. It does NOT validate frontmatter field values against taxonomy (e.g., whether `domain` is a known value in `SKILL_TAXONOMY.md`). Taxonomy validation is gatekeeper's responsibility. Duplicating it here creates drift risk: the two validators could diverge in what they accept, producing confusing double-failure signals.

**Implication:** Precondition checks at `[ROUTE]` are path-structural only — `$ARTIFACT_PATH` exists, is readable, and matches the expected path shape for its type. Taxonomy correctness is out of scope.

### Atomic write — assemble in memory, write once

EVAL.md is either fully written or not written at all. Partial writes (e.g., writing structural criteria before dispatch agents finish) leave an artifact in an invalid state that could be picked up by gatekeeper or improve-skill as if it were complete.

**Implication:** Every flow file assembles the full EVAL.md content in memory before issuing a single write. If dispatch fails mid-flow (skill flow only), the file state is zero — no partial output. Users see the error and re-run.

### Default-deny overwrite of existing EVAL.md

Silently overwriting an existing EVAL.md would destroy measurement history and invalidate any improve-skill iteration in progress. The right tool for refining an existing EVAL.md is `/improve-skill`, not regeneration from scratch.

**Implication:** `[ROUTE]` checks for an existing EVAL.md at the target path. If found: fail with a clear message — "EVAL.md exists; use `--force` to overwrite or `/improve-skill` to refine via measurement." `--force` bypasses the check. No silent overwrite.

### Explicit args only — no natural-language inference

Ambiguous type inference produces the wrong EVAL.md tier shape. A protocol artifact evaluated as a skill gets EVAL-O output criteria that have no meaning for a protocol. Consistency with `synapse-creator` (which has the same failure mode) also reduces cognitive load for callers who use both skills.

**Implication:** CLI is `/write-synapse-eval <type> <path>`. No argument guessing. Wrong or missing `$TYPE` fails at `[ROUTE]` with a valid-list error before any file load. Path-pattern hints ("looks like an agent path — did you mean agent?") are allowed but still require explicit confirmation.

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
- User invokes with path to existing EVAL.md (not source artifact) → clarify and redirect

---

**`[ROUTE]` — Validation and flow dispatch**

Load: `references/type-config.md` (for path-shape validation)
Do:
1. Confirm `$TYPE ∈ {skill, protocol, agent, tool}` — fail loudly with valid list if not.
2. Confirm `$ARTIFACT_PATH` exists and is readable — fail loudly if not.
3. Validate path shape against type-config: `skill`/`tool` expect a directory; `agent`/`protocol` expect a flat `.md` file — fail with "type/path mismatch" if wrong.
4. Read source frontmatter to extract artifact name — structural check only; do NOT validate taxonomy values.
5. Check if EVAL.md already exists at the target path — if yes, fail loudly: "EVAL.md exists; use `--force` to overwrite or `/improve-skill` to refine via measurement."
6. Load EXACTLY ONE `references/flow-<TYPE>.md`.

Don't: load more than one flow file; validate taxonomy values; proceed past this node with any validation failure.

Exit: transfer control to `flow-<TYPE>:[START]`.

---

**`flow-skill:[START → END]`** — Dispatch-rich skill eval lifecycle

Load: `references/shared-steps.md`, `templates/skill/eval.md`
Do:
1. Read SKILL.md — extract artifact name and invocation signature.
2. Dispatch `skill-eval-prompter` (blind prompting, no judge bias).
3. Dispatch `skill-eval-judge` (grades prompter output).
4. Dispatch `skill-eval-auditor` (audit trail for judge scoring).
5. Assemble full EVAL.md in memory: EVAL-S (structural) + EVAL-E (orchestration, opt) + EVAL-F (flow-graph, opt) + EVAL-O (output) + Test Prompts.
6. Write EVAL.md atomically; emit exit signal with tier-count summary.

Don't: branch on `$TYPE`; modify the source artifact; apply grading; write partial output.

---

**`flow-protocol:[START → END]`** — Transcription protocol eval lifecycle

Load: `synapse-gatekeeper/references/protocol-checklist.md`, `templates/protocol/eval.md`
Do:
1. Read protocol `.md` file — extract artifact name.
2. Load gatekeeper `protocol-checklist.md` — Tier 1 → EVAL-S criteria, Tier 2 → EVAL-C (conformance) criteria.
3. Adapt checklist items to EVAL-Sxx/Cxx tier format.
4. Assemble full EVAL.md in memory.
5. Write EVAL.md atomically; emit exit signal.

Don't: reproduce checklist content inline; fall back to baked-in criteria if checklist is missing — fail loud.

---

**`flow-agent:[START → END]`** — Transcription agent eval lifecycle

Load: `synapse-gatekeeper/references/agent-checklist.md`, `templates/agent/eval.md`
Do:
1. Read agent `.md` file — extract artifact name.
2. Load gatekeeper `agent-checklist.md` — Tier 1 → EVAL-S criteria, Tier 2 → EVAL-Q (quality) criteria.
3. Adapt checklist items to EVAL-Sxx/Qxx tier format.
4. Assemble full EVAL.md in memory.
5. Write EVAL.md atomically; emit exit signal.

Don't: reproduce checklist content inline; fall back to baked-in criteria if checklist is missing — fail loud.

---

**`flow-tool:[START → END]`** — Transcription-plus tool eval lifecycle

Load: gatekeeper tool rules, `templates/tool/eval.md`
Do:
1. Read tool directory — extract artifact name and `test/` directory structure.
2. Load gatekeeper tool checklist (currently inline in synapse-gatekeeper SKILL.md; extract or load from inline section).
3. Produce EVAL-S (structural) criteria from checklist.
4. Scaffold EVAL-X (exit-codes/side-effects) criteria around tool's existing `test/` directory.
5. Assemble full EVAL.md in memory.
6. Write EVAL.md atomically; emit exit signal.

Don't: invent EVAL-X criteria not backed by actual `test/` scripts; fall back silently if tool checklist is missing.

### 3.3 Entry Gates

| Transition | Gate conditions |
|---|---|
| `[NEW] → [ROUTE]` | Single artifact implied; `$TYPE` and `$ARTIFACT_PATH` extractable from invocation |
| `[ROUTE] → flow-<TYPE>:[START]` | `$TYPE ∈ {skill, protocol, agent, tool}`; `$ARTIFACT_PATH` exists and is readable; path shape matches type-config; frontmatter readable; no existing EVAL.md (or `--force` flag present) |

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
    ├── agent/eval.md                 # EVAL-S + EVAL-Q (quality) skeleton
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

| Type     | Flow shape       | Tiers (with source)                                                                                              | Generation mechanism                                                                  |
|----------|------------------|------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| skill    | **dispatch**     | EVAL-S (structural) + EVAL-E (orchestration, opt) + EVAL-F (flow-graph, opt) + EVAL-O (output) + Test Prompts    | Dispatch skill-eval-{prompter,judge,auditor} agents (existing); assemble + write       |
| protocol | **transcribe**   | EVAL-S (transcribe `protocol-checklist.md` Tier 1) + EVAL-C (transcribe Tier 2 conformance)                       | Read gatekeeper checklist → format as EVAL-Sxx/Cxx criteria → write                    |
| agent    | **transcribe**   | EVAL-S (transcribe `agent-checklist.md` Tier 1) + EVAL-Q (transcribe Tier 2 quality)                              | Read gatekeeper checklist → format as EVAL-Sxx/Qxx criteria → write                    |
| tool     | **transcribe+**  | EVAL-S (structural per tool gatekeeper rules) + EVAL-X (script invocation: run `test/` + check exit codes)        | Read gatekeeper tool rules + scaffold EVAL-X around tool's existing `test/` directory  |

Tier ID prefixes are type-scoped to avoid collision when the same criteria name appears across types (e.g., "structural" is EVAL-S for all types, but EVAL-C is protocol-only, EVAL-Q is agent-only, EVAL-X is tool-only).

---

## 7. `shared-steps.md` Scope

`shared-steps.md` contains only operations genuinely shared across all four flows with no type-branching:

- `validate-frontmatter` — extract artifact name from frontmatter header
- `resolve-output-path` — per type-config: directory `<dir>/EVAL.md` or flat `<name>.eval.md` adjacent
- `write-eval-atomic` — assemble in memory → single write
- `existing-eval-guard` — check for collision; `--force` / redirect to `/improve-skill` on conflict

NOT in `shared-steps.md`: registry-row writes, README updates (eval generation is a single file write per session; no registry or README mutations).

`type-config.md` keys: `output-path-shape` (directory|flat), `output-filename` (EVAL.md|<name>.eval.md), `tier-prefixes` (per type), `canonical-checklist-source` (transcription flows), `template-path` (`templates/<type>/eval.md`).

---

## 8. Behavioral Invariants

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

## 9. Handoff Contract

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

## 10. Accepted Tensions

| Tension | Decision | Revisit when |
|---------|----------|--------------|
| Asymmetric flows (skill ~120 LOC, others ~50 LOC) violate "symmetric router" aesthetic | Accepted — symmetry is not a goal; matching the actual problem shape is. Router earns its place even with asymmetric flows. | Tool flow grows >150 LOC (would suggest tool eval has hidden dispatch needs we missed) |
| Hard coupling to synapse-gatekeeper checklist filenames | Accepted — single-source-of-truth wins over decoupling. Pre-commit hook will catch breakage. | Gatekeeper's checklist file structure becomes unstable across 2+ releases |
| `write-skill-eval` sunset deprecates a `stable` skill | Accepted — same pattern as skill-creator → synapse-creator sunset; 1-release deprecation window | Anyone reports a missing migration path during deprecation window |

---

## 11. Dependencies

| Artifact | Direction | Contract |
|---|---|---|
| `synapse/skills/skill/write-skill-eval/` | supersedes | `write-synapse-eval` replaces this; `flow-skill.md` is a near-mechanical port of its logic; original deprecated post-merge |
| `synapse/skills/synapse/synapse-creator/references/flow-{skill,agent,protocol,tool}.md` | consumed by (caller) | Post-scaffold handoff: `synapse-creator` calls `/write-synapse-eval <type> <new-artifact-path>`; resolves T3.6 FAIL (dead `/write-agent-eval` reference) |
| `synapse/skills/skill/improve-skill/` | consumed by (caller) | When EVAL.md missing, `improve-skill` dispatches `/write-synapse-eval skill <path>` (replaces direct `/write-skill-eval` reference; 1-line edit) |
| `synapse/agents/skill-eval/{prompter,judge,auditor}.md` | consumes | `flow-skill.md` dispatches these existing agents; they stay in place |
| `synapse-gatekeeper/references/protocol-checklist.md` | consumes | Canonical Tier 1/2 source for `flow-protocol.md` transcription; Load path failure = hard stop |
| `synapse-gatekeeper/references/agent-checklist.md` | consumes | Canonical Tier 1/2 source for `flow-agent.md` transcription; Load path failure = hard stop |
| gatekeeper tool rules (inline in synapse-gatekeeper SKILL.md) | consumes | Source for `flow-tool.md` EVAL-S criteria; extract to `tool-checklist.md` in gatekeeper or load inline section |
| `taxonomy/SKILL_TAXONOMY.md` | consumes | `domain: skill`, `intent: write` validated against taxonomy on commit |

---

## 12. Sunset Migration

<!-- VERBATIM -->

- Mark `synapse/skills/skill/write-skill-eval/` row in registry as `deprecated` with pointer to `write-synapse-eval`
- Keep the directory in place for one release cycle; update synapse-creator's `flow-skill.md` and any `/improve-skill` references to point to `/write-synapse-eval skill <path>`
- Update `flow-agent.md` (synapse-creator) — replace the dead `/write-agent-eval` handoff with `/write-synapse-eval agent <path>` (resolves T3.6 FAIL)
