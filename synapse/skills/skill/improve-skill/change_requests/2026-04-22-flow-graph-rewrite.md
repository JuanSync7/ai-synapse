# Decision Memo — improve-skill: flow-graph rewrite + flow-graph awareness

> Artifact type: skill (change request) | Source brainstorm: `.brainstorms/2026-04-22-improve-skill-flowgraph/notes.md` | Supersedes: `change_requests/2026-04-22-brainstorm-multi-artifact-output.md`

---

## What I want

Rewrite improve-skill's own SKILL.md as a flow-graph, and teach it to recognize, evaluate, and preserve flow-graph structure in the skills it improves. improve-skill consumes skill-creator's companion files via symlinks — no duplication. The only net-new owned content is the structure-preserving edit rules unique to improve-skill's "fix existing skills" mission.

---

## Why Claude needs it

Flow-graph is now the universal SKILL.md structure. Without this change:

1. **improve-skill doesn't enforce flow-graph conformance.** Its structural checklist has no items for MUST/MUST NOT sections, node anatomy, edge conditions, position tracking, or [END] as a real node. A SKILL.md missing per-node Don'ts or explicit edges passes structural review.

2. **improve-skill could break flow-graph structure while fixing other issues.** It might flatten a flow-graph into prose, consolidate per-node Load declarations into a preamble, move Don'ts out of their nodes into a global section, or remove self-loop edges — all of which silently degrade the skill.

3. **improve-skill's own SKILL.md is 283 lines of prose.** It doesn't follow the pattern it should enforce. Checklists, score card formats, and trace-back procedures are inlined as always-on content competing for attention every turn.

---

## Injection shape

Workflow + structural pattern enforcement. improve-skill is a discipline-enforcement skill: it takes an existing SKILL.md, scores it against best practices (now including flow-graph conformance), fixes failing items, and re-scores. The flow-graph awareness extends what it checks and adds constraints on how it edits.

---

## What it produces

Updated SKILL.md files that:
- Pass structural checklist (baseline + extended + principles alignment + flow-graph conformance)
- Pass behavioral tests (EVAL.md output criteria)
- Preserve flow-graph topology when the target is already flow-graph structured
- Flag non-flow-graph skills with a redirect to `/skill-creator` for migration

---

## Architecture details

### improve-skill stays separate from skill-creator

Different triggers ("improve this skill" vs "create a skill"), different execution patterns (iterative score-fix loop vs creation pipeline), different user intent. skill-creator [V] dispatches improve-skill; improve-skill never dispatches skill-creator. Clean producer→consumer boundary.

### Shared infrastructure via symlinks

improve-skill references skill-creator's companion files — no duplication. When skill-creator's references evolve, improve-skill gets updates for free. The only owned content is `structure-preserving-edits.md` (unique to editing existing flow-graphs).

### Companion-file-writer agent shared

When a fix requires creating or updating a companion file (e.g., moving content out of an over-budget SKILL.md), improve-skill dispatches skill-creator's `skill-companion-file-writer` agent via symlink. Same agent, same conventions, one definition.

### Precondition check at entry

Before starting the scoring loop, verify all file references in the target skill directory resolve. Use `scripts/check-links.sh` or check directly. Broken symlinks or dead references = FAIL LOUDLY before wasting cycles scoring against stale knowledge.

### Flow-graph conformance in structural pass

Flow-graph conformance checks are derived from reading `flow-graph-pattern.md` at the structural scoring node — not maintained as a separate checklist. The agent reads the pattern and checks the target against it. This avoids a maintenance burden of two files drifting apart.

### Prose SKILL.md handling

When improve-skill encounters a SKILL.md that is not flow-graph structured:
- Flag as a structural finding: "SKILL.md is not flow-graph structured"
- Redirect to `/skill-creator` for migration
- Continue scoring remaining checklist items against the prose structure (the skill may have other fixable issues)
- Do NOT auto-convert prose to flow-graph — that's a full rewrite, which is skill-creator's job

### Structure-preserving edit rules (unique to improve-skill)

When improve-skill makes fixes to a flow-graph SKILL.md:
- Do not rename node IDs without updating every edge that references them
- Do not move Don'ts out of their node into a global section (per-node placement is intentional for attention weight)
- Do not consolidate Load declarations into a single preamble (recency at the relevant node is intentional)
- Do not remove self-loop edges — they make iteration explicit
- Do not remove [END] or reduce it to a comment — it is a real node with Do/Don't
- Do not add prose sections that bypass the node/edge structure
- Do not inflate SKILL.md beyond 500 lines (hard cap) — move content to companion files and add Load reference at the appropriate node
- If a Load target doesn't resolve, FAIL LOUDLY — do not proceed with stale or missing references

### Content that moves to companion files

| Current inline content | Destination | Loaded at |
|----------------------|-------------|-----------|
| Baseline checklist (15 items) | `references/structural-checklist.md` | Structural scoring node |
| Extended checklist (5 items) | Same file | Same node |
| Principles alignment checklist (8 items) | Same file | Same node |
| Score card format examples | `templates/score-card-format.md` | Output/presentation node |
| Behavioral trace-back procedure | `references/behavioral-trace-procedure.md` | Behavioral scoring node |
| EVAL.md auto-detection logic | Stays inline in SKILL.md | Entry node — routing decision |
| Constraints section | Becomes MUST NOT in flow-graph | Global |

### Line budget

~80 lines target (aspirational), 500 hard cap. Do not prematurely move content to companions at 81 lines. The target is a signal to consider extraction, not a gate.

### Companion-file-writer failure handling

Retry once with enriched brief (more context from conversation or memo). If retry fails, FAIL LOUDLY — surface to user. Never fall back to inlining content to paper over the failure.

---

## Edge cases considered

- **Partially-conformant flow-graph:** Has Flow/Entry/MUST but missing per-node Don'ts or edges without conditions. Each missing element is a separate checklist failure, fixed surgically. Not flagged as "non-flow-graph."
- **Node IDs renamed during fix:** Must update every edge declaration referencing the old ID in the same change.
- **Don'ts genuinely not needed:** Some nodes may have no guardrails. Don't is the one section that can be absent — Entry, Do, Exit, [END] are mandatory. MUST section is mandatory.
- **Fix pushes SKILL.md past 500 lines:** Move existing content to companion file (dispatch companion-file-writer), then apply the fix. Budget respected, fix still happens.
- **Self-referential execution:** improve-skill scoring its own SKILL.md. No circular dependency — reads references as knowledge, scores the target file. The target happens to be itself, but execution is file-on-file, not self-modifying.
- **Broken symlinks at entry:** check-links.sh or direct check catches dead references before scoring begins. Fail with broken paths listed.
- **Companion-file-writer agent failure:** Retry once with enriched brief. On second failure, FAIL LOUDLY — surface specific gaps to user.

---

## Companion files anticipated

### references/ — domain knowledge loaded on-demand

| File | Source | Loaded at | Purpose |
|------|--------|-----------|---------|
| `flow-graph-pattern.md` | symlink → skill-creator | Structural scoring node | Canonical flow-graph pattern — conformance derived from reading this |
| `writing-conventions.md` | symlink → skill-creator | Structural scoring node | Conventions for frontmatter, folder structure, voice/tone |
| `companion-dispatch-protocol.md` | symlink → skill-creator | Companion creation node | How to compose dispatch for companion-file-writer agent |
| `structure-preserving-edits.md` | **NEW, owned** | Fix node (structural + behavioral) | Surgical edit rules unique to improve-skill: don't flatten, don't consolidate, don't restructure. Includes symlink contract: fail loudly if Load target doesn't resolve. |
| `structural-checklist.md` | **NEW, owned** | Structural scoring node | Baseline + extended + principles alignment checklist items extracted from current SKILL.md |
| `behavioral-trace-procedure.md` | **NEW, owned** | Behavioral scoring node | How to trace output/execution failures back to SKILL.md instructions |

### templates/ — output format skeletons

| File | Source | Loaded at | Purpose |
|------|--------|-----------|---------|
| `flow-graph-skeleton.md` | symlink → skill-creator | Structural scoring node | Reference for what a compliant flow-graph looks like |
| `flow-graph-worked-example.md` | symlink → skill-creator | Structural scoring node | Concrete example (synapse-brainstorm) |
| `score-card-format.md` | **NEW, owned** | Output/presentation node | Structural + behavioral + execution score card templates |

### agents/

| File | Source | Purpose |
|------|--------|---------|
| `skill-companion-file-writer.md` | symlink → skill-creator | Dispatched when fixes require new/updated companion files |
| `skill-eval-judge.md` | existing, unchanged | Domain-agnostic judge for behavioral grading |

---

## Dependencies

| Artifact | Contract | Required? | Direction |
|----------|----------|-----------|-----------|
| `skill-creator/references/flow-graph-pattern.md` | Canonical flow-graph pattern definition | Yes | improve-skill consumes via symlink |
| `skill-creator/references/writing-conventions.md` | Writing conventions for skills | Yes | improve-skill consumes via symlink |
| `skill-creator/references/companion-dispatch-protocol.md` | Dispatch protocol for companion-file-writer | Yes | improve-skill consumes via symlink |
| `skill-creator/templates/flow-graph-skeleton.md` | Structural template | Yes | improve-skill consumes via symlink |
| `skill-creator/templates/flow-graph-worked-example.md` | Worked example | Yes | improve-skill consumes via symlink |
| `skill-creator/agents/skill-companion-file-writer.md` | Companion file writer agent | Yes | improve-skill dispatches via symlink |
| `scripts/check-links.sh` | Link validation | Yes | improve-skill runs as precondition |

---

## Follow-up tasks (not part of this change request)

1. Regenerate improve-skill's EVAL.md after rewrite (`/write-skill-eval`)
2. Run `/improve-skill` against the rewritten improve-skill (self-improvement)
3. Run `/synapse-gatekeeper` for certification

---

## Open questions

None. All threads resolved during brainstorm.
