---
name: skill-creator
description: Use when asked to create a new skill, build a skill for X, or write a skill.
domain: meta.create
intent: write
tags: [skill, SKILL.md, scaffold]
user-invocable: true
argument-hint: "[what the skill should do]"
---

# Skill Creator

Creates new Claude Code skills and generates their evaluation artifacts. Follows the official [Anthropic skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator) workflow, extended with automatic EVAL.md generation.

Creating a skill is an act of context injection — you're not programming the agent, you're loading its context with judgment it can't derive from training alone. A skill that works changes agent output; a skill that doesn't just adds token noise. This workflow ensures you prove the need first (Phase 1.5), write only what changes behavior (Phase 2), and validate it does (Phases 3-7).

## Progress Tracking (applies to skill-creator itself AND every skill it creates)

**For skill-creator itself:** Create a task list at the start:

```
TaskCreate: "Phase 1: Understand — capture intent, triggers, output, siblings"
TaskCreate: "Phase 1.5: Baseline test"
TaskCreate: "Phase 2: Write the skill"
TaskCreate: "Phase 2.5: Pipeline registration — add to SKILLS_REGISTRY.yaml"
TaskCreate: "Phase 3: Generate test prompts"
TaskCreate: "Phase 4: Generate output criteria"
TaskCreate: "Phase 5: Assemble EVAL.md"
TaskCreate: "Phase 6-7: Validate and iterate"
```

Mark each task `in_progress` when starting, `completed` when done.

**For every skill you create:** If the skill has multiple steps, phases, or stages, include a Progress Tracking section with explicit TaskCreate examples showing what tasks to create. The user sees a persistent task list at the bottom of their session — this is the primary way they track progress through multi-step skills.

```markdown
## Progress Tracking

At the start, create a task list for each phase:

\`\`\`
TaskCreate: "Phase 1: [phase name]"
TaskCreate: "Phase 2: [phase name]"
...
\`\`\`

Mark each task `in_progress` when starting, `completed` when done.
```

**For every skill that dispatches agents:** Include an instruction to set `model:` explicitly on every Agent dispatch so the user sees which model is being used (e.g., `Agent (...) opus`). This is not optional — skills that dispatch agents without visible model selection confuse users about what's running and at what cost.

## Core Principles

Before building a skill, internalize these — they determine whether the skill actually changes agent behavior or just adds noise.

1. **Context injection, not a program** — only include what the agent can't derive from training
2. **Mental model before mechanics** — conceptual framing before rules
3. **Description is a routing contract** — trigger conditions, not workflow summary
4. **Explicit scope boundaries** — what this does, doesn't do, and what sibling handles instead
5. **Policy over procedure** — teach judgment, not mechanical steps
6. **Opinionated over descriptive** — SKILL.md encodes decisions ("default to X", "always Y", "never Z"), not options. Educational content belongs in reference files. A skill that lists possibilities is just documentation.
7. **Safe defaults for blocking operations** — every HITL gate, approval checkpoint, or interactive prompt must define a provisional/safe default for headless execution. Silent auto-approve is not acceptable. This applies to any skill that can block.
8. **Every instruction traces to a failure mode** — if removing it wouldn't change output, remove it
9. **Progressive disclosure** — always-on in SKILL.md, on-demand in companion files
10. **Restriction when discipline demands it** — some skills must override defaults
11. **Loud failure on preconditions** — check inputs, surface failures, never proceed silently
12. **Concrete over abstract** — filled-in examples, good/bad contrasts

## Workflow

### Phase 1: Understand

1. **Capture intent** — What should this skill enable Claude to do?
2. **Identify triggers** — What user phrases/contexts should invoke it?
3. **Define output** — What does the skill produce? (document, code, config, etc.)
4. **Check for siblings** — Does this overlap with existing skills? If so, clarify boundaries.

**Before proceeding:** Verify you have a clear goal — you need a trigger phrase the user would say, a defined output artifact, and no unresolvable overlap with an existing skill. If any are missing, ask a specific question before continuing. Proceeding with an underspecified goal produces a skill with wrong triggers or unclear scope.

### Phase 1.5: Baseline Test

Run the core task WITHOUT the skill first. If Claude already produces correct output unaided, the skill teaches behavior that needs no teaching — stop and document why instead.

> If you cannot show it fails without the skill, you cannot prove the skill is needed.

### Phase 2: Write the Skill

> **Read [`references/skill-design-principles.md`](references/skill-design-principles.md)** before writing the SKILL.md body — full reasoning and examples for each principle.

Build the skill directory:

```
skill-name/
├── SKILL.md          (required — under 500 lines)
├── SCOPE.md          (recommended — 5-line capability profile for model migration)
├── templates/        (optional — output format skeletons)
├── references/       (optional — domain knowledge, loaded on demand)
├── rules/            (optional — hard constraints, naming conventions, coding standards)
├── examples/         (optional — complete worked examples)
├── test-inputs/      (optional — fixed stimulus files for reproducible evals)
├── EVAL.md           (generated — quality criteria + test prompts)
├── PROGRAM.md        (optional — research directions for auto-research loops)
└── research/         (optional — iterations.tsv + changelog.md from auto-research)
```

**Execution fence:** When a model *executes* a skill, it reads SKILL.md, templates/, references/, rules/, and examples/. It ignores `research/`, `EVAL.md`, `PROGRAM.md`, `SCOPE.md`, and `test-inputs/` — these are improvement/migration artifacts, not execution context. Include this fence in every skill you create:

```markdown
> **Execution scope:** Ignore `research/`, `EVAL.md`, `PROGRAM.md`, `SCOPE.md`, and `test-inputs/` during execution — these are used only by improvement and migration workflows.
```

#### Folder Conventions

Companion folders are **flat siblings** of SKILL.md — never nested inside each other. Each folder type has a distinct purpose and load-time:

| Folder | Contains | When the agent reads it |
|--------|----------|------------------------|
| `templates/` | Output skeletons with placeholders to fill in | Before generating output — defines the shape |
| `references/` | Domain patterns, CSS/JS snippets, algorithms | On-demand during generation — consulted per component |
| `rules/` | Hard constraints, naming conventions, coding standards | Always — loaded at execution start, not optional |
| `examples/` | Complete worked examples of the skill's output | When the agent needs a concrete model to follow |

**Why flat, not nested:** Nesting (e.g. `references/templates/`) blurs the distinction between folder types. The top-level folder name tells the agent *what kind* of companion file it's reading. SKILL.md pointers are self-documenting: `> Read templates/X for output format` vs `> Read references/Y when implementing Z`.

**When to create folders:** Only when a skill has 2+ companion files of the same type. A single template file can live at the root as `template.md` (like write-spec does). Move to a folder when you have multiple.

Point to companion files from SKILL.md using this format:
```markdown
> **Read [`references/file.md`](references/file.md)** when entering Phase 2 to write the SKILL.md body.
```

#### SKILL.md Frontmatter

> **Read [`../TAXONOMY.md`](../TAXONOMY.md)** to pick `domain` and `intent` values from the controlled vocabulary. Do not invent new values — if nothing fits, propose an addition to TAXONOMY.md.

```yaml
---
name: skill-name
description: [Triggering conditions ONLY — the phrases/contexts that should invoke this skill. Never summarize the workflow. If the description could replace reading the SKILL.md body, it's wrong.]
domain: [pick from TAXONOMY.md domains]
intent: [pick from TAXONOMY.md intents]
tags: [freeform, lowercase, hyphenated]
user-invocable: true
argument-hint: "[expected arguments]"
---
```

**Good description:**
```yaml
description: "Use when asked to create a new skill, build a skill for X, or write a skill."
```
*Trigger conditions only — the agent must read the body to learn how.*

**Bad description:**
```yaml
description: "Creates skills by understanding intent, building SKILL.md with companion files, generating EVAL.md, and running improve-skill validation loops."
```
*Summarizes the workflow — the agent may follow this instead of reading the body.*

#### Writing Principles

- **Imperative voice** for instructions. ("Validate the input" not "The input should be validated")
- **Keep SKILL.md under 500 lines.** Move detail needed only at one phase into companion files with explicit read-triggers.
- **SKILL.md is opinionated, references are educational.** SKILL.md states decisions and defaults ("always use X", "never Y"). Reference files teach patterns with annotated examples. If SKILL.md reads like documentation listing options, it's wrong — it should read like a senior engineer's judgment calls.
- **Phrasing that sticks** — authority signals ("must", "always") and commitment signals ("you have verified") increase compliance with discipline-enforcing instructions.

### Phase 2.5: Pipeline Registration

After writing the SKILL.md, determine if the skill should be pipeline-routable:

> "Is this skill a pipeline stage — should it appear in assembled pipelines when the orchestrator routes goals? (yes/no)"

If **no**: skip this phase. The skill will appear in `SKILLS_REGISTRY.yaml` without a `pipeline:` block (inventory only, not router-selectable).

If **yes**, collect the following and append the entry to `SKILLS_REGISTRY.yaml` under the correct domain/group:

| Field | Prompt | Notes |
|---|---|---|
| `domain` | Which top-level domain? (engineering/quality/meta) | Create a new domain if none fits |
| `group` | Which group within that domain? | Create a new group with a summary if none fits |
| `stage_name` | Short canonical ID used in `--stages` and presets | Must be unique across the entire registry |
| `input_type` | What artifact does this stage consume? | Use `\|` for union (any one satisfies) |
| `output_type` | What artifact does this stage produce? | Single type only |
| `context_type` | Stakeholder-reviewer gate type | Must be one of: `qa_answer`, `approach_selection`, `design_approval`, `spec_review`, `code_review`, `doc_review` |
| `requires_all` | Stage names that ALL must complete before this one | Use for hard sequential dependencies |
| `requires_any` | Stage names where AT LEAST ONE must complete | Use when multiple upstream paths are valid |
| `skippable` | Can this stage be omitted from a pipeline? | `false` for stages that produce core artifacts |

**YAML entry to append under the correct domain/group:**
```yaml
          - name: <skill-name>
            description: "<one-line description>"
            pipeline:
              stage_name: <stage-name>
              input_type: <type>
              output_type: <type>
              context_type: <type>
              requires_all: [<stage>, ...]   # omit if empty
              requires_any: [<stage>, ...]   # omit if empty
              skippable: true | false
```

**Concrete example — write-spec skill:**
```yaml
          - name: write-spec
            description: "Writes a formal requirements specification document"
            pipeline:
              stage_name: spec
              input_type: design_sketch
              output_type: formal_spec
              context_type: spec_review
              requires_all: [brainstorm]
              skippable: true
```

After appending, verify:
- `stage_name` is unique (no collision with existing entries)
- All `requires_all`/`requires_any` values resolve to a known `stage_name` or `built_in`
- The `context_type` is in the allowed list

Show the user the appended entry and confirm.

### Phase 3: Generate Test Cases

First, identify the skill type — it determines what to test:

| Skill type | What to test |
|-----------|--------------|
| Discipline-enforcing | Does output fail without the skill? Does it hold under rationalization pressure? |
| Technique | Is the technique applied correctly? Is it skipped under time/complexity pressure? |
| Pattern | Is the pattern applied completely? Are edge cases covered? |
| Reference | Is the referenced content actually used, or does the agent invent instead? |

After writing the skill, run `/generate-test-prompts` with only the skill's name and description:

```
/generate-test-prompts [skill-name] [one-line description]
```

This produces diverse test prompts across personas (naive, experienced, adversarial, wrong-tool) — blind to the SKILL.md body to avoid implementation bias.

### Phase 4: Generate Output Criteria

Run `/generate-output-criteria` with the skill directory path:

```
/generate-output-criteria [path to skill directory]
```

This reads the full SKILL.md as an impartial judge and produces binary output quality criteria (EVAL-Oxx) — what makes the skill's output good or bad.

### Phase 5: Assemble EVAL.md

Combine the outputs from Phase 3 and Phase 4 into an EVAL.md in the skill's directory:

```markdown
# [Skill Name] — Evaluation Criteria

## Structural Criteria
(From improve-skill's baseline checklist — no need to duplicate here)

## Output Criteria
(From /generate-output-criteria)

## Test Prompts
(From /generate-test-prompts)
```

### Phase 6: Validate

Run `/improve-skill [path to SKILL.md]` to execute the full structural + behavioral loop. This validates that:
- The SKILL.md passes all structural quality criteria
- The skill produces outputs that pass all EVAL.md output criteria
- Failures are traced back to SKILL.md and fixed

### Phase 7: Iterate

If improve-skill surfaces failures:
1. Fix SKILL.md based on traced root causes
2. Re-run the behavioral loop
3. If output criteria need adjustment (they were wrong, not the skill), update via `/generate-output-criteria`
4. If test prompts are insufficient, add more via `/generate-test-prompts`

## Skill Quality Standards

A complete skill has:

| Artifact | Purpose | Generated by | When |
|----------|---------|-------------|------|
| SKILL.md | Instructions for the agent | skill-creator (you) | always |
| SCOPE.md | Capability profile (long context? tool use? min model tier?) | skill-creator (you) | recommended |
| EVAL.md | Quality criteria + test prompts | write-skill-eval pipeline | always |
| templates/ | Output format skeletons | skill-creator (you) | optional |
| references/ | Domain knowledge, loaded on demand | skill-creator (you) | optional |
| rules/ | Hard constraints, naming conventions, coding standards | skill-creator (you) | optional |
| examples/ | Complete worked examples | skill-creator (you) | optional |
| test-inputs/ | Fixed stimulus files for reproducible evals | skill-creator (you) | when skill processes file inputs |
| PROGRAM.md | Research directions for auto-research loops | human | when entering auto-research |
| research/ | iterations.tsv + changelog.md | auto-research | when entering auto-research |

## Common Shortcuts and Why They Fail

| Shortcut | Why it fails |
|----------|-------------|
| "This skill is simple, baseline test is overkill" | Simplicity is irrelevant. Without a failing baseline, you cannot prove the skill is needed. |
| "I'll add EVAL.md after the skill is working" | Post-hoc EVAL.md is written by the author, not a judge. Criteria will be biased toward what the skill already does and won't catch real failures. |
| "I'll skip /improve-skill, the skill looks correct to me" | The evaluation loop exists to surface failures you can't see by inspection. Skipping it makes EVAL.md worthless. |

## When to Hand Off

| Task | Route to |
|------|----------|
| Skill needs structural improvement | `/improve-skill [path]` |
| Need to regenerate test prompts | `/generate-test-prompts [name] [description]` |
| Need to regenerate output criteria | `/generate-output-criteria [path]` |
| Need full EVAL.md from scratch | `/write-skill-eval [path]` |
