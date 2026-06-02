# Writing Conventions

Structural conventions for SKILL.md and companion files. Loaded at [W] — applies to every skill produced.

---

## Frontmatter

Required fields:

```yaml
---
name: skill-name
description: "Trigger conditions ONLY — phrases a USER would say."
domain: <from SKILL_TAXONOMY.md>
intent: <from SKILL_TAXONOMY.md>
tags: [lowercase, hyphenated]
user-invocable: true
argument-hint: "[expected arguments]"
---
```

> Read `taxonomy/SKILL_TAXONOMY.md` to pick `domain` and `intent` values. Do not invent new values.

### Description is a routing contract

The `description` field specifies when the skill fires, not what it does. If the description could replace reading the body, it's too broad.

**Good:**
```yaml
description: "Use when asked to create a new skill, build a skill for X, or write a skill."
```
*Trigger conditions only. Must read the body to know how.*

**Bad (workflow summary):**
```yaml
description: "Creates skills by understanding intent, building SKILL.md with companion files, generating EVAL.md."
```
*Summarizes the workflow — agent may follow this instead of reading the body.*

**Bad (internal vocabulary):**
```yaml
description: "Routes by document ROLE and LAYER to the correct writer."
```
*Uses terms no user would say.*

---

## Skill Directory Structure

```
skill-name/
├── SKILL.md          (required — flow-graph structure, ~80 lines target, 500 hard cap)
├── SCOPE.md          (recommended — 5-line capability profile)
├── agents/           (optional — symlinks to agent definitions this skill dispatches)
├── templates/        (optional — output format skeletons)
├── references/       (optional — domain knowledge, loaded on demand)
├── rules/            (optional — hard constraints, naming conventions)
├── examples/         (optional — complete worked examples)
├── test-inputs/      (optional — fixed stimulus files for reproducible evals)
├── EVAL.md           (generated — quality criteria + test prompts)
├── PROGRAM.md        (optional — research directions for auto-research)
└── research/         (optional — iterations.tsv + changelog.md from auto-research)
```

---

## Folder Conventions

Companion folders are **flat siblings** of SKILL.md — never nested inside each other.

| Folder | Contains | When the agent reads it |
|--------|----------|------------------------|
| `templates/` | Output skeletons with placeholders | Before generating output — defines the shape |
| `references/` | Domain patterns, algorithms, protocol definitions | On-demand during specific nodes — consulted per decision |
| `rules/` | Hard constraints, naming conventions, coding standards | Always — loaded at execution start, not optional |
| `examples/` | Complete worked examples of the skill's output | When the agent needs a concrete model to follow |

**Why flat, not nested:** Nesting blurs the distinction between folder types. The top-level folder name tells the agent *what kind* of companion file it's reading.

**When to create folders:** Only when a skill has 2+ companion files of the same type. A single template can live at the root as `template.md`.

---

## Companion File Pointing Syntax

Point to companion files from SKILL.md using Load declarations in node headers:

```
Load: references/file.md, templates/skeleton.md
```

For prose-context loading (outside flow-graph nodes):
```markdown
> **Read [`references/file.md`](references/file.md)** when entering Phase 2.
```

---

## Execution Fence

Every skill must include this fence to separate execution artifacts from improvement artifacts:

```markdown
> **Execution scope:** Ignore `research/`, `EVAL.md`, `PROGRAM.md`, `SCOPE.md`, and `test-inputs/` during execution — these are used only by improvement and migration workflows.
```

---

## Line Budget

- **~80 lines target** for SKILL.md. Every line is always-loaded and competes for attention every turn.
- **500 lines hard cap.** If approaching it, move content to companion files.
- If 80 lines genuinely cannot hold the always-on judgment, the skill's scope is too broad — split it.
- On-demand loading is about **attention weight recency**, not token saving.

---

## Voice and Tone

- **Imperative voice** for instructions: "Validate the input" not "The input should be validated"
- **Commitment language** (MUST/NEVER/DO NOT) for constraints, gates, and prohibitions
- **Policy language** for judgment calls and coaching: "when X, prioritize Y over Z"
- A skill that uses MUST everywhere is rigid. A skill that uses "should" everywhere is ignorable.

---

## Wrong-Tool Detection Section

Every skill must have this section. Place it after the opening paragraph, before the flow graph.

```markdown
## Wrong-Tool Detection

- **User wants X** → redirect to `/sibling-skill`
- **User wants Y** → not this skill; suggest Z instead
```

Name specific sibling skills and their triggers.

---

## Progress Tracking

For skills with 3+ phases, include a progress tracking convention:

```markdown
Update task progress at phase transitions — create tasks at session start,
mark in_progress when starting, completed when done.
```

This is harness-agnostic — no tool-specific names (not `TaskCreate`, not `task_add`).

---

## Subagent Model Visibility

Every skill that dispatches subagents must set `model:` explicitly on each dispatch. Users need to see which model is running and at what cost.

---

## Verbatim Annotation Convention

If the produced skill involves subagents that read working documents (notepads, scratch files):

Include a MUST rule:
> When writing structural content (directory trees, schemas, flow graphs, code blocks) to the working document, prefix with `<!-- VERBATIM -->`.

Subagents must copy annotated blocks as-is, never compress or summarize.

Only applies to skills with persistent working documents consumed by subagents.
