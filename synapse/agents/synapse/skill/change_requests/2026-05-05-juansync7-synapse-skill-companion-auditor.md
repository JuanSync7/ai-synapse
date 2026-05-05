# Decision Memo — synapse-skill-companion-auditor

> Artifact type: agent | Memo type: creation | Design doc: `/home/juansync7/ai-synapse/.brainstorms/2026-05-05-synapse-skill-signal-reviewer/notepad.md`

---

## What I want

A sub-agent that audits the companion files of a skill — `references/` and `templates/` — and reports per-file PASS/FAIL findings to the orchestrator (`synapse-skill-signal-reviewer`). It checks that progressive disclosure is done right: every companion file has a documented load trigger in SKILL.md (no orphans), none of its content duplicates SKILL.md body, size is proportionate to purpose, templates are concrete (not skeletal), and references are modular (single-concern, loadable independently).

The auditor operates on one skill directory at a time. If the skill has zero companion files it skips all companion checks and reports "no companion files — criterion skipped" rather than failing vacuously.

---

## Why Claude needs it

Without this agent, companion-file hygiene is never checked at creation time. The current `synapse-skill-signal-reviewer` (orchestrator) would have to inline companion checks alongside anatomy and design checks, collapsing three distinct quality surfaces into one undifferentiated pass. Practically, two failure modes dominate:

1. **Orphan companion files** — a `references/foo.md` exists but SKILL.md never mentions a load trigger for it. The agent loads it at an undefined moment (or never), making the file dead weight that still occupies context.
2. **Content duplication** — a companion file restates something already in SKILL.md body, violating progressive-disclosure and adding bloat without benefit.

An auditor scoped to companion files keeps these checks concentrated, fast, and attributable — the orchestrator gets clean `[companion] file: ... — issue` labels it can aggregate without parsing mixed output.

---

## Injection shape

- **Policy:** Judgment rules for per-file progressive-disclosure checks (load trigger detection, duplication assessment, size-fit-purpose, template concreteness, reference modularity).
- **Domain knowledge:** Spec loaded at runtime from `synapse/skills/skill/skill-creator/references/skill-design-principles.md` — specifically the progressive-disclosure rules section.

---

## What it produces

| Output | Count | Mutable? | Purpose |
|---|---|---|---|
| Per-file PASS/FAIL table (markdown) | 1 per run | No | Structured findings returned to orchestrator for aggregation |

---

## Edge cases considered

| Edge case | Handling |
|---|---|
| Skill has 0 companion files (no `references/` or `templates/`) | Skip all companion checks; return "no companion files — criterion skipped". Orchestrator treats this as neutral (not a fail). This is an orchestrator-level rule, but the auditor must signal it explicitly so the orchestrator doesn't interpret silence as PASS or FAIL. |
| `references/` or `templates/` directory exists but is empty | Same as 0 companion files — skip, signal skipped. |
| Companion file has a load trigger in SKILL.md but trigger text is vague ("see references/") | Flag as WARN (not FAIL); report `[companion] file: references/X.md — load trigger present but vague (no decision point specified)`. |
| A template file contains only placeholder slots (skeletal) | FAIL with note `[companion] file: templates/X.md — template is skeletal; must be concrete and completable`. |
| A reference file covers multiple unrelated concerns | FAIL with note `[companion] file: references/X.md — not modular; mixes N concerns`. |
| SKILL.md references a companion file by name but file doesn't exist on disk | FAIL with note `[companion] file: references/X.md — referenced in SKILL.md but file missing (dangling reference)`. |
| spec source file (`skill-design-principles.md`) is missing at runtime | Loud fail — do not proceed; emit `AGENT FAILURE: spec source not found at synapse/skills/skill/skill-creator/references/skill-design-principles.md`. |

---

## Companion files anticipated

**Always loaded (at agent invocation):**

| File | Loaded at | Purpose |
|------|-----------|---------|
| `synapse/skills/skill/skill-creator/references/skill-design-principles.md` | Invocation | Source-of-truth spec for progressive-disclosure rules; auditor checks against this, not against inline re-encodings |

---

## Dependencies

| Artifact | Direction | Contract |
|---|---|---|
| `synapse-skill-signal-reviewer` (orchestrator) | consumes output from | Dispatches this auditor with skill directory path; receives per-file PASS/FAIL table; aggregates under `[companion]` prefix for unified verdict |
| `synapse/skills/skill/skill-creator/references/skill-design-principles.md` | consumes | Progressive-disclosure rules section; loaded at runtime; loud fail if missing |
| `synapse-skill-companion-writer` (sibling agent) | adjacent — writer/auditor pair | Writer produces companion files; auditor reviews them. Same surface, clean symmetry, NOT a naming collision. No runtime dependency between them. |

---

## Naming conventions

- Pattern: `synapse-skill-companion-auditor`
- Segment breakdown: `synapse` (domain) · `skill` (subdomain) · `companion` (surface) · `auditor` (role terminal)
- Taxonomy: `domain: synapse`, `role: auditor`
- Canonical location: `synapse/agents/synapse/skill/synapse-skill-companion-auditor.md`
- Adjacent name `synapse-skill-companion-writer` is the paired writer — same surface, distinct role terminal (`writer` vs `auditor`). The pair forms a writer/auditor pattern on the companion-file surface.

---

## Frontmatter

```yaml
---
name: synapse-skill-companion-auditor
description: "Audits references/ and templates/ companion files for a skill — checks load triggers, no duplication with SKILL.md body, size-fit-purpose, template concreteness, and reference modularity"
domain: synapse
role: auditor
tags: [companion-files, progressive-disclosure, skill-review]
---
```

---

## Output schema

```markdown
## Companion File Audit — <skill-name>

_Spec source: synapse/skills/skill/skill-creator/references/skill-design-principles.md (progressive-disclosure rules)_

| File | Check | Result | Notes |
|------|-------|--------|-------|
| references/<name>.md | Load trigger documented in SKILL.md | PASS/FAIL/WARN | ... |
| references/<name>.md | Content not duplicated in SKILL.md body | PASS/FAIL | ... |
| references/<name>.md | Size fits purpose (not bloated, not too thin) | PASS/FAIL | ... |
| references/<name>.md | Modular (single concern, loadable independently) | PASS/FAIL | ... |
| templates/<name>.md | Load trigger documented in SKILL.md | PASS/FAIL/WARN | ... |
| templates/<name>.md | Concrete and completable (not skeletal) | PASS/FAIL | ... |

**Summary:** N files checked — M pass, K fail, J warn
```

If no companion files exist:

```markdown
## Companion File Audit — <skill-name>

No companion files found (references/ and templates/ absent or empty) — companion criterion skipped.
```

All findings prefixed with `[companion] file: <path> — <issue>` for orchestrator aggregation.

---

## Pipeline integration

Dispatched by `synapse-skill-signal-reviewer` (orchestrator) in parallel with `synapse-skill-anatomy-reviewer` and `synapse-skill-design-judge`:

```
[R] synapse-skill-signal-reviewer
  ├── dispatch synapse-skill-anatomy-reviewer (SKILL.md path)
  ├── dispatch synapse-skill-design-judge (SKILL.md path)
  └── dispatch synapse-skill-companion-auditor (skill directory path)  ← this agent

Aggregation rule (orchestrator responsibility):
  APPROVE iff:
    - anatomy: all checks pass (100%)
    - design: avg ≥ 3.5, no dimension < 2
    - companion: ≥ 90% pass (or skipped — 0 files)
  REVISE: any anatomy fail OR design avg < 3.5 OR any dimension < 2 OR companion < 90%
  ESCALATE: REVISE on second cycle
```

Model: sonnet.

---

## Open questions

None — all questions resolved during brainstorm lens rotation.
