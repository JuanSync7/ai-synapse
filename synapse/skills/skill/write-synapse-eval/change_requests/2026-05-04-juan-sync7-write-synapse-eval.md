# Decision Memo — write-synapse-eval

> Artifact type: skill | Memo type: creation | Design doc: `../../../.brainstorms/2026-05-04-write-synapse-eval/design.md`

---

## What I want

A single router-based skill (`/write-synapse-eval`) that generates EVAL.md files for any of the four artifact classes — skill, protocol, agent, tool. It replaces the standalone `/write-skill-eval` and fills the missing `write-{protocol,agent,tool}-eval` gap, consolidating four separate type-flows under one entry point. Architecture mirrors `synapse-creator` exactly: a thin routing `SKILL.md` plus per-type flow files, shared steps, a type-config map, and per-type EVAL.md templates.

The four flows are **asymmetric by design**:
- `skill` flow = **dispatch** (~120 LOC): ports existing write-skill-eval routing + dispatches skill-eval-{prompter,judge,auditor} agents, assembles results.
- `protocol` / `agent` / `tool` flows = **transcription** (~50–60 LOC each): read the canonical synapse-gatekeeper checklist for that type, translate Tier 1 items → EVAL-Sxx criteria, Tier 2 items → type-specific prefix criteria (EVAL-Cxx / EVAL-Qxx / EVAL-Xxx), and write the file.

All four flows ship fully working in v1. No scaffold-only deferrals.

---

## Why Claude needs it

Without this skill, three artifact classes (protocol, agent, tool) have no eval-generation path at all. The existing `/write-skill-eval` only handles skills. `synapse-creator`'s `flow-agent.md` hands off to `/write-agent-eval` — a dead reference (T3.6 FAIL). Adding separate write-protocol-eval / write-agent-eval / write-tool-eval skills would produce redundant routing logic across four artifacts and make maintenance drift likely. A single consolidating router resolves all four gaps in one artifact, with extension cost of "add one flow file + one template" for future types.

---

## Injection shape

- **Workflow:** Phase descriptions, flow graph, node specs. Router SKILL.md owns the `[NEW] → [ROUTE] → flow-<TYPE>:[START]` lifecycle; each flow file owns its full type-specific lifecycle from artifact read through EVAL.md write.
- **Policy:** Hard gates (type validation, path existence check, single-flow-load invariant, atomic write, EVAL.md clobber guard, read-only invariant on source artifact). Wrong-tool detection block redirecting to `/improve-skill`, `/synapse-gatekeeper`, `/synapse-brainstorm`.
- **Domain knowledge:** Per-type tier shapes and tier-ID prefixes, loaded on-demand from `type-config.md`; canonical tier checklists referenced from `synapse-gatekeeper/references/{agent,protocol,tool}-checklist.md`. For the transcription flows, the checklist IS the domain knowledge — write-synapse-eval does not bake in criteria; it reads them fresh.

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

**[ROUTE]** — Load: `references/type-config.md`. Do: validate `$TYPE ∈ {skill, protocol, agent, tool}`; validate `$ARTIFACT_PATH` exists and matches type expectations (dir vs flat file); extract artifact name + frontmatter for header (READ-ONLY — do not validate taxonomy values, that is gatekeeper's job); check for existing EVAL.md and apply clobber guard; load exactly one `references/flow-<TYPE>.md`. Don't: inline any eval-generation logic; branch on `$TYPE` in `shared-steps.md`; validate frontmatter field values against taxonomy. Exit: → `flow-<TYPE>:[START]` on all-gates-pass; loud failure on any gate miss.

**flow-skill:[START … END]** — Load: `references/flow-skill.md` + `references/shared-steps.md`. Do: port existing write-skill-eval dispatch pattern — invoke skill-eval-prompter (blind), skill-eval-judge, skill-eval-auditor; assemble EVAL-S + EVAL-E + EVAL-F + EVAL-O + Test Prompts in memory; write atomically. Don't: modify skill under evaluation. Exit: file path + tier-count summary.

**flow-protocol:[START … END]** — Load: `references/flow-protocol.md` + `synapse-gatekeeper/references/protocol-checklist.md`. Do: read protocol artifact header; transcribe checklist Tier 1 items → EVAL-Sxx criteria; transcribe Tier 2 conformance items → EVAL-Cxx criteria; assemble in memory; write atomically. Don't: modify protocol under evaluation; fall back to baked-in content if checklist is missing — fail loud instead. Exit: file path + tier-count summary.

**flow-agent:[START … END]** — Load: `references/flow-agent.md` + `synapse-gatekeeper/references/agent-checklist.md`. Do: read agent artifact header; transcribe Tier 1 → EVAL-Sxx; transcribe Tier 2 quality items → EVAL-Qxx; assemble in memory; write atomically. Don't: modify agent under evaluation; bake in criteria outside the checklist source. Exit: file path + tier-count summary.

**flow-tool:[START … END]** — Load: `references/flow-tool.md` + tool gatekeeper rules (inline section of synapse-gatekeeper SKILL.md, or extracted `tool-checklist.md` if that extraction happens in this PR). Do: read tool artifact header; transcribe structural rules → EVAL-Sxx; scaffold EVAL-Xxx around the tool's existing `test/` directory (script invocation + exit-code assertions); assemble in memory; write atomically. Don't: modify tool under evaluation. Exit: file path + tier-count summary.

---

## Entry gates

| Transition | Gate |
|---|---|
| [NEW] → [ROUTE] | Intent confirmed as EVAL.md generation (not improvement, grading, or brainstorm) |
| [ROUTE] → flow-\<TYPE\>:[START] | `$TYPE ∈ {skill, protocol, agent, tool}` AND `$ARTIFACT_PATH` exists AND type/path contract matches AND no existing EVAL.md (or `--force` passed) |
| flow-\<TYPE\>:[END] → done | EVAL.md written successfully; exit signal emitted |

---

## Companion files anticipated

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

**Load point summary:**
- `SKILL.md` — always-loaded (router, <100 LOC)
- `references/type-config.md` — loaded at [ROUTE]
- `references/flow-<TYPE>.md` — one per session, loaded at [ROUTE] after type validation
- `references/shared-steps.md` — loaded within flows as needed (shared parameterized ops only)
- `synapse-gatekeeper/references/{protocol,agent}-checklist.md` — loaded inside protocol/agent flows as canonical transcription source
- `templates/<type>/eval.md` — loaded during assembly as structural skeleton

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

## Per-type EVAL tier shape (v2 — grounded in canonical gatekeeper checklists)

<!-- VERBATIM -->
| Type     | Flow shape       | Tiers (with source)                                                                                              | Generation mechanism                                                                  |
|----------|------------------|------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| skill    | **dispatch**     | EVAL-S (structural) + EVAL-E (orchestration, opt) + EVAL-F (flow-graph, opt) + EVAL-O (output) + Test Prompts    | Dispatch skill-eval-{prompter,judge,auditor} agents (existing); assemble + write       |
| protocol | **transcribe**   | EVAL-S (transcribe `protocol-checklist.md` Tier 1) + EVAL-C (transcribe Tier 2 conformance)                       | Read gatekeeper checklist → format as EVAL-Sxx/Cxx criteria → write                    |
| agent    | **transcribe**   | EVAL-S (transcribe `agent-checklist.md` Tier 1) + EVAL-Q (transcribe Tier 2 quality)                              | Read gatekeeper checklist → format as EVAL-Sxx/Qxx criteria → write                    |
| tool     | **transcribe+**  | EVAL-S (structural per tool gatekeeper rules) + EVAL-X (script invocation: run `test/` + check exit codes)        | Read gatekeeper tool rules + scaffold EVAL-X around tool's existing `test/` directory  |

---

## MUST / MUST NOT

<!-- VERBATIM -->
**MUST (every turn)**
- Record position: `Position: [node-id] — <context>`
- Confirm `$TYPE ∈ {skill, protocol, agent, tool}` BEFORE loading any flow file
- Validate `$ARTIFACT_PATH` exists BEFORE flow load
- Load EXACTLY ONE `references/flow-<type>.md` per session
- Atomic write: assemble EVAL.md fully in memory, write once
- Treat source artifact as read-only: extract name + frontmatter header only; never modify, never validate taxonomy values (that is gatekeeper's job)

**MUST NOT (global)**
- Inline eval-generation logic in SKILL.md — routing only
- Branch on `$TYPE` inside `references/shared-steps.md` — type variation comes from `type-config.md` lookup
- Modify the artifact being evaluated — read-only operation
- Grade the artifact (that's `/synapse-gatekeeper`'s job) — produce criteria, don't apply them
- Fall back to baked-in criteria if a gatekeeper checklist file is missing — fail loud with the unresolved Load path; no silent fallback

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
| Subagent dispatch failure (skill flow) | No partial EVAL.md written; assembly stays in memory until all agents complete |
| Gatekeeper checklist file missing or renamed (transcription flows) | Fail loud with unresolved Load path; never bake in criteria or guess from training |
| User wants to improve against existing EVAL | Redirect to `/improve-skill` (wrong-tool detection at [NEW]) |
| User wants to certify/grade | Redirect to `/synapse-gatekeeper` (wrong-tool detection at [NEW]) |
| User wants to brainstorm what eval to write | Redirect to `/synapse-brainstorm` (wrong-tool detection at [NEW]) |
| Multi-artifact in one session | Reject; instruct caller to dispatch parallel agents (one invocation per artifact) |
| Pathway eval (5th type) | Out of v1 scope — additive extension: extract pathway-checklist.md in gatekeeper, add flow-pathway.md + templates/pathway/eval.md + type-config row here |

---

## Tensions accepted

| Tension | Decision | Revisit when |
|---------|----------|--------------|
| Asymmetric flows (skill ~120 LOC, others ~50 LOC) violate "symmetric router" aesthetic | Accepted — symmetry is not a goal; matching the actual problem shape is. Router earns its place even with asymmetric flows. | Tool flow grows >150 LOC (would suggest tool eval has hidden dispatch needs we missed) |
| Hard coupling to synapse-gatekeeper checklist filenames | Accepted — single-source-of-truth wins over decoupling. Pre-commit hook will catch breakage. | Gatekeeper's checklist file structure becomes unstable across 2+ releases |
| `write-skill-eval` sunset deprecates a `stable` skill | Accepted — same pattern as skill-creator → synapse-creator sunset; 1-release deprecation window | Anyone reports a missing migration path during deprecation window |

---

## Dependencies

| Artifact | Direction | Contract |
|---|---|---|
| `synapse/skills/skill/write-skill-eval/` | consumes (porting) | flow-skill.md is a near-mechanical port of existing routing logic + agent dispatch |
| `synapse/agents/skill-eval/{prompter,judge,auditor}.md` | consumes | Existing dispatch agents stay in place; flow-skill.md dispatches them unchanged |
| `synapse-gatekeeper/references/protocol-checklist.md` | consumes | Canonical Tier 1/Tier 2 source for flow-protocol.md transcription; Load path must resolve or fail loud |
| `synapse-gatekeeper/references/agent-checklist.md` | consumes | Canonical Tier 1/Tier 2 source for flow-agent.md transcription; Load path must resolve or fail loud |
| synapse-gatekeeper tool checklist (inline or extracted) | consumes | Structural rules source for flow-tool.md; creator decides whether to extract to tool-checklist.md in this PR or load from inline section |
| `synapse/skills/synapse/synapse-creator/` | produces for | Post-scaffold handoff updated from dead `/write-agent-eval` to `/write-synapse-eval agent <path>` (resolves T3.6 FAIL) |
| `synapse/skills/skill/improve-skill/` | produces for | When EVAL.md missing, dispatch becomes `/write-synapse-eval skill <path>` (trivial 1-line edit) |

---

## Sunset migration (post-merge)

<!-- VERBATIM -->
- Mark `synapse/skills/skill/write-skill-eval/` row in registry as `deprecated` with pointer to `write-synapse-eval`
- Keep the directory in place for one release cycle; update synapse-creator's `flow-skill.md` and any `/improve-skill` references to point to `/write-synapse-eval skill <path>`
- Update `flow-agent.md` (synapse-creator) — replace the dead `/write-agent-eval` handoff with `/write-synapse-eval agent <path>` (resolves T3.6 FAIL)

---

## Open questions

None. All 5 lenses applied and resolved during brainstorm. All four flows ship fully working in v1 — skill flow ported from write-skill-eval; protocol/agent/tool flows implemented as transcription from canonical gatekeeper checklists (no scaffold-only deferrals). Creator decisions to make: (1) whether to extract synapse-gatekeeper's tool checklist into a standalone `tool-checklist.md` in this PR or load from the inline section; (2) whether the pre-commit hook addition for Load-path validation ships in this PR or a follow-on.
