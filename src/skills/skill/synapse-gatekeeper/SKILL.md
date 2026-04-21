---
name: synapse-gatekeeper
description: "Use when a skill, agent, or protocol is complete and ready for promotion review, or to check if an artifact meets the bar to land in ai-synapse."
domain: skill.eval
intent: validate
tags: [skill, agent, protocol, promotion, certification, gatekeeper]
user-invocable: true
argument-hint: "<artifact-path> [--score <0-100>]"
---

Synapse gatekeeper is the promotion gate for ai-synapse. An artifact is not ready to merge just because it was built — it must meet the bar. This skill reads a finished skill, agent, or protocol, detects the artifact type, and runs the appropriate checklist. APPROVE = ready for PR. REVISE = fixable gaps. REJECT = fundamental problem that prevents promotion. The verdict is always the first line so orchestrators can parse it without scanning the full report.

Three artifact types, three flows:
- **Skill** (default) — `SKILL.md` in a directory under `src/skills/` → three tiers (structural, quality, registry)
- **Agent** — `.md` file in `src/agents/` → two tiers (structural, quality) via `references/agent-checklist.md`
- **Protocol** — `.md` file in `src/protocols/` → two tiers (structural, conformance) via `references/protocol-checklist.md`

---

## Execution Scope

Ignore any files named `research/`, `EVAL.md`, `PROGRAM.md`, `SCOPE.md`, or `test-inputs/` when they appear in the artifact directory being reviewed. These are scaffolding artifacts, not part of the live surface. For skills, evaluate `SKILL.md`, `references/`, `templates/`, and the domain `README.md` row. For agents and protocols, evaluate the `.md` file itself.

---

## Wrong-Tool Detection

| If the user wants to... | Redirect to |
|-------------------------|-------------|
| Fix gaps identified in a verdict | Issue the verdict first, then redirect to `/improve-skill` |
| Build a skill from scratch | `/skill-creator` |
| Build an agent from scratch | `/agent-creator` |
| Build a protocol from scratch | `/protocol-creator` |
| Review a decision or design approach (not an artifact) | `/stakeholder-reviewer` |
| Evaluate or rewrite an EVAL.md only | `/write-skill-eval`, `/write-agent-eval`, or `/write-protocol-eval` |

---

## Progress Tracking

```
TaskCreate "Phase 1 — Load artifact and detect type" status:in_progress
TaskCreate "Phase 2 — Structural tier check"
TaskCreate "Phase 3 — Quality / Conformance tier check"
TaskCreate "Phase 4 — Registry tier check (skills only)"
TaskCreate "Phase 5 — Issue verdict and report"
```

---

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `<artifact-path>` | Yes | Path to the artifact: skill directory (containing SKILL.md), agent `.md` file in `src/agents/`, or protocol `.md` file in `src/protocols/` |
| `--score <0-100>` | No | Eval score from a prior `/improve-skill` or auto-research run (skills only) |

---

## Phase 1 — Load and Detect Type

**Artifact type detection:**
- Path matches `src/agents/*.md` → **agent flow**
- Path matches `src/protocols/**/*.md` → **protocol flow**
- Path contains a `SKILL.md` file → **skill flow** (default)
- None of the above → emit `VERDICT: REJECT` with "unrecognized artifact type"

**Skill flow — read:**
- `<artifact-path>/SKILL.md`
- `<artifact-path>/EVAL.md`
- `<artifact-path>/` directory listing (to detect `references/`, `templates/`, `examples/`)

**Agent flow — read:**
- The agent `.md` file itself
- > **Read [`references/agent-checklist.md`](references/agent-checklist.md)** for the agent-specific checklist

**Protocol flow — read:**
- The protocol `.md` file itself
- > **Read [`references/protocol-checklist.md`](references/protocol-checklist.md)** for the protocol-specific checklist

**Early exits (skill flow only):**
- If `SKILL.md` is absent → emit `VERDICT: REJECT` immediately. Do not proceed.
- If `EVAL.md` is absent → record a REJECT-tier structural failure. Complete the structural checklist (marking EVAL.md as `[ ]`), then issue `VERDICT: REJECT`. Skip Quality and Registry tiers entirely — they require a working eval.

**Early exits (agent/protocol flow):**
- If the `.md` file is absent or empty → emit `VERDICT: REJECT` immediately.
- If frontmatter is absent → emit `VERDICT: REJECT` immediately.

---

## Phase 2 — Structural Tier

### Skill flow

> **Read [`../../SKILL_TAXONOMY.md`](../../SKILL_TAXONOMY.md)** to validate `domain` and `intent` values against the controlled vocabulary.

| Check | Pass condition |
|-------|---------------|
| SKILL.md exists | File is present and non-empty |
| EVAL.md exists | File is present (**REJECT if absent**) |
| Frontmatter complete | `name`, `description`, `domain`, `intent` all present |
| `domain` in SKILL_TAXONOMY.md | Value matches a row in SKILL_TAXONOMY.md |
| `intent` in SKILL_TAXONOMY.md | Value matches a row in SKILL_TAXONOMY.md |
| `tags` well-formed | Array of lowercase hyphenated strings |
| `user-invocable` present | Field exists (true or false) |
| `argument-hint` present | Present when `user-invocable: true` |
| Domain README has row | Domain `README.md` contains a row linking this skill |
| Name globally unique | No collision in `SKILLS_REGISTRY.yaml` |

**Name uniqueness:** Check `SKILLS_REGISTRY.yaml` for any entry with the same `name` value. A collision is an immediate REJECT — two skills with the same name cannot coexist in `~/.claude/skills/`.

### Agent flow

Use the checklist from `references/agent-checklist.md` (loaded in Phase 1). Validate against `AGENT_TAXONOMY.md` and `AGENTS_REGISTRY.md`.

### Protocol flow

Use the checklist from `references/protocol-checklist.md` (loaded in Phase 1). Validate against `PROTOCOL_TAXONOMY.md`.

---

## Phase 3 — Quality / Conformance Tier

### Skill flow

> **Read [`references/skill-design-principles.md`](references/skill-design-principles.md)** before evaluating quality criteria.

| Check | Pass condition |
|-------|---------------|
| Description is routing contract | Specifies *when* the skill fires — not a workflow summary |
| Eval score ≥ 80 | Provided score is ≥ 80 |
| SKILL.md under 500 lines | Line count ≤ 500 |
| Instructions trace to failure modes | Each instruction implies "without this, the agent does X which causes Y" |
| Wrong-Tool Detection present | Section redirects to sibling skills on intent mismatch |
| `references/` used correctly | Companion files load at specific decision points, not inlined wholesale |

**If no score is provided:** Mark the quality tier as `unverified`. A missing score blocks APPROVE — a skill cannot be certified without a measured eval score. The verdict will be at most REVISE.

### Agent flow

Use the Tier 2 (Quality) checks from `references/agent-checklist.md`.

### Protocol flow

Use the Tier 2 (Conformance) checks from `references/protocol-checklist.md`.

---

## Phase 4 — Registry Tier (Skills Only)

**Agent and protocol flows skip this phase entirely** — agents are listed in `AGENTS_REGISTRY.md` (checked in Phase 2), protocols have no registry.

> **Read [`../../SKILLS_REGISTRY.yaml`](../../SKILLS_REGISTRY.yaml)** to check registration status.

A skill is **pipeline-routable** if it: (a) consumes a defined artifact type, (b) produces a defined artifact type, and (c) other skills in the registry depend on its output via `requires_all` or `requires_any`.

| Check | Pass condition |
|-------|---------------|
| Pipeline-routable → has registry entry | `pipeline:` block present with `stage_name`, `input_type`, `output_type`, `context_type`, `requires_all`/`requires_any` |
| Not pipeline-routable → absence is correct | No `pipeline:` block; inventory entry with explanatory comment is sufficient |
| If registered: `stage_name` unique | No other skill uses the same `stage_name` |
| If registered: dependencies resolve | All `requires_all`/`requires_any` values match real stage names in the registry |

---

## Phase 5 — Verdict and Report

> **Read [`../../GOVERNANCE.md`](../../GOVERNANCE.md)** for authoritative REVISE vs. REJECT classification.

**Verdict rules:**

| Condition | Verdict |
|-----------|---------|
| All tiers pass | APPROVE |
| Any fixable gap (score < 80, weak description, missing README row, missing argument-hint, unverified quality tier, missing registry entry for pipeline skill) | REVISE |
| EVAL.md absent, name collision, or fundamental structural failure | REJECT |

> **Read [`examples/example-verdict.md`](examples/example-verdict.md)** for complete worked examples of each verdict type.

**Output format:**

```
VERDICT: <APPROVE | REVISE | REJECT>

## Certification Report — <artifact-name> (<skill | agent | protocol>)

### Structural                    <✓ | ✗>
- [x] ...

### Quality / Conformance         <✓ | ✗ | unverified>
- [x] ...

### Registry                      <✓ | ✗ | N/A>
- [x] ...
(N/A for agents and protocols)

## Gaps
<specific actionable items — omit section entirely if APPROVE>
```

The verdict must always be the first line of output. Orchestrators rely on this for automated parsing — do not prepend preamble, headers, or explanatory text before it.
