# Skill Anatomy

Canonical structure of a SKILL.md file. This is the **structural** spec — what must be present and in what shape. The **quality** spec lives in `synapse/skills/synapse-router-artifact-creator/references/skill-design-principles.md` (loaded separately for graded design judgment).

This file is loaded by:
- `synapse-router-artifact-creator/references/flow-skill.md` at `[W]` — to know what to draft
- `synapse-skill-anatomy-reviewer` at runtime — to grade structural presence (binary checks)
- `/synapse-skill-skill-improver` — for structural pre-checks
- `/synapse-router-artifact-gatekeeper` — for promotion certification

Single source of truth. If anatomy evolves, edit this file and every consumer picks up the change.

---

## Universal Structure

Every SKILL.md is YAML frontmatter followed by a markdown body. The body MUST follow flow-graph form (Load / Brief / Do / Don't / Exit per node) — prose-structured skills are rejected.

```
---
<frontmatter — required + optional fields>
---

# <Skill Title>

<Mental Model — one paragraph WHY>

## MUST (every turn)
- <imperatives>

## MUST NOT (global)
- <prohibitions>

## Wrong-Tool Detection            ← if user-invocable
- <sibling skill redirects>

## Progress Tracking               ← if 3+ phases
<TaskCreate guidance>

## Flow

### [NODE-A] — <name>
Load: <files>
Brief: <one-line purpose>
Do:
  1. <action>
Don't:
  - <constraint>
Exit:
  → [NODE-B] : <gate>

### [NODE-B] — <name>
...
```

---

## Mandatory Sections (binary anatomy gate)

Each row below is a binary check. The anatomy-reviewer must verify presence/format only — quality of content is graded by `synapse-skill-design-judge`.

| # | Section | Rule | Trigger condition |
|---|---------|------|-------------------|
| A1 | Frontmatter | Required fields: `name`, `description`, `domain`, `subdomain`, `scope`, `role`. Optional: `tags`, `user-invocable`, `argument-hint`. Slug shape and required fields defined in `taxonomy/SKILL_TAXONOMY.md`; allowed values for `domain` / `subdomain` / `scope` / `role` MUST exist in the matching `##` section of `registry/SKILL_VOCABULARY.md`. | Always |
| A2 | `description` field | Single-line, non-empty, ends with trigger condition language ("Use when…", "Triggered by…"). Must NOT be a workflow summary. | Always |
| A3 | Skill title | First H1 heading after frontmatter. Title-case. | Always |
| A4 | Mental Model paragraph | One paragraph immediately after the H1, before any section heading. Explains WHY the skill exists. | Always |
| A5 | `## MUST (every turn)` section | Imperative bullets. At least one bullet. | Always |
| A6 | `## MUST NOT (global)` section | Prohibition bullets. At least one bullet. | Always |
| A7 | `## Wrong-Tool Detection` section | Names sibling skill(s) and their trigger boundary. | If `user-invocable: true` |
| A8 | `## Progress Tracking` section | Includes `TaskCreate` guidance. | If skill has 3+ phases / nodes in Flow |
| A9 | `## Flow` section + at least one node | Each node follows `[NAME] — title` heading + Load / Brief / Do / Don't / Exit. | Always |
| A10 | Node anatomy compliance | Every node under `## Flow` has all five sub-fields (Load / Brief / Do / Don't / Exit) — Load may be empty if no companions. | Always |
| A11 | Entry node | Exactly one node marked entry (typically `[START]` or `[U]`). | Always |
| A12 | `[END]` node | Reports outcomes; does not auto-route. | Always |

---

## Frontmatter Schema

```yaml
---
name: <slug>                         # MUST be globally unique; MUST match {domain}-{subdomain}-{scope}-{role}
description: "<trigger contract>"    # MUST be single line; routing contract not workflow summary
domain: <value>                      # MUST exist in SKILL_VOCABULARY.md §Domains
subdomain: <value>                   # MUST exist in SKILL_VOCABULARY.md §Subdomains
scope: <noun>                        # MUST exist in SKILL_VOCABULARY.md §Scopes
role: <noun>                         # MUST exist in SKILL_VOCABULARY.md §Roles
tags: [<lowercase>, <hyphenated>]    # Optional; if present, lowercase-hyphenated only
user-invocable: <true|false>         # Optional; default false
argument-hint: "<inline help>"       # Optional; only if user-invocable: true
---
```

**Validation rules:**
- `name` MUST match the skill directory name.
- `description` MUST NOT be empty, MUST NOT exceed one line.
- `description` MUST contain a trigger phrase (regex-detectable: "Use when", "Triggered by", "Use this skill", "When asked to", or equivalent).
- `description` MUST NOT contain workflow verbs that summarize the body ("Creates X by reading Y, generating Z, validating W").

---

## Flow-Graph Form

Every skill is a finite-state machine. Nodes have entry conditions, do work, and have exit gates. Prose-structured skills (sequential paragraphs without node boundaries) are anatomy failures.

**Each node:**

```
### [NODE-ID] — <human name>
Load: <comma-separated companion files; "none" if none>
Brief: <one-sentence purpose of this node>
Do:
  1. <action>
  2. <action>
Don't:
  - <constraint>
  - <constraint>
Exit:
  → [NEXT-NODE] : <gate condition>
  → [OTHER-NODE] : <alternative gate condition>
```

**Compliance points:**
- Node IDs are square-bracketed UPPERCASE-or-CamelCase.
- Every node has a non-empty `Brief`.
- `Do` is a numbered list.
- `Don't` is a bulleted list.
- `Exit` lists at least one transition with an explicit gate.
- `[END]` is the terminal node — its `Exit` is empty or absent.

---

## Companion File Anatomy

Companions live in `references/`, `templates/`, `agents/`, or `change_requests/`. SKILL.md MUST declare each companion's load point via `Load:` lines in node specs. Orphan companions (files not loaded by any node) fail the companion-auditor.

**Allowed subdirectories under a skill:**
- `references/` — loaded on demand at specific decision points
- `templates/` — output skeletons used at write nodes
- `agents/` — symlinks to internal agent recipes
- `examples/` — worked examples (rare; usually a sign instructions need rewriting)
- `change_requests/` — historical records of brainstorm-driven changes (frozen)
- `research/`, `test-inputs/`, `PROGRAM.md`, `SCOPE.md`, `EVAL.md` — improvement/migration scaffolding (out of scope for anatomy review)

---

## Out of Scope for Anatomy Review

These are checked by other agents, not the anatomy-reviewer:

| Concern | Owner |
|---------|-------|
| Quality of mental model framing (clear vs vague) | `synapse-skill-design-judge` |
| Whether instructions trace to failure modes | `synapse-skill-design-judge` |
| Progressive disclosure done well | `synapse-skill-design-judge` + `synapse-skill-companion-auditor` |
| Companion file content quality | `synapse-skill-companion-auditor` |
| Output quality on test prompts | `synapse-skill-eval-judge` (post-EVAL grading) |
| EVAL.md presence and content | `write-skill-eval` + `/synapse-router-artifact-gatekeeper` |
| Registry row consistency | `.githooks/pre-commit` (Tier 1 structural) |

---

## Failure Reporting

When a skill fails anatomy review, the reviewer emits per-row PASS/FAIL with the specific section ID (A1–A12) and a short fix note. Format defined in `synapse-skill-anatomy-reviewer`'s output schema.
