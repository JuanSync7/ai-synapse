---
name: improve-skill
description: "Use when a skill needs quality improvement — check it against best practices, test it on sample prompts, and fix what fails. Triggered by 'improve this skill', 'fix the skill', 'review skill quality', 'make the skill better'."
domain: skill.create
intent: improve
tags: [skill, quality, score-fix loop]
user-invocable: true
argument-hint: "[path to SKILL.md] [optional: --structural-only | --behavioral-only]"
---

# Improve Skill

Applies the Karpathy autoresearch loop to improve any SKILL.md:

> **Modify → measure → keep if improved → repeat**

## Progress Tracking

At the start, create a task list:

```
TaskCreate: "Pass 1: Structural — score against baseline checklist"
TaskCreate: "Pass 2: Behavioral — run skill on test prompts, grade outputs"
```

Mark each `in_progress` when starting, `completed` when done. When dispatching subagents for behavioral testing, set `model:` explicitly.

**Three primitives applied to skill-writing:**
- **Modifiable target** — the SKILL.md (single file)
- **Scalar metric** — quality checklist pass rate (N / total items)
- **Cycle** — score → fix failing items → re-score → present at full pass

---

## Two-Pass Architecture

improve-skill runs two complementary passes:

```
Pass 1: Structural (fast, no skill execution)
  Score SKILL.md against baseline checklist + EVAL.md structural criteria
  Fix → re-score → repeat until passing

Pass 2: Behavioral (slower, requires running the skill)
  Run skill on test prompts from EVAL.md
  Grade outputs against EVAL.md output criteria
  If the skill's EVAL.md contains `## Execution Criteria` (EVAL-Exx):
    inject the execution trace protocol into the subagent prompt
    and grade the returned trace against EVAL-E criteria
  Trace failures back to SKILL.md instructions
  Fix SKILL.md → re-run → re-grade → repeat until passing
```

Pass 1 always runs first. Pass 2 runs if an EVAL.md exists with output criteria and test prompts.

Use `--structural-only` to skip Pass 2, or `--behavioral-only` to skip Pass 1.

---

## Pass 1: Structural Loop

### The Loop

1. **Read** — Read the target SKILL.md, any companion files, and EVAL.md (if it exists)
2. **Score** — Evaluate against baseline checklist + EVAL.md structural criteria (EVAL-Sxx)
3. **Identify** — List each failing item with a one-line reason
4. **Fix** — Edit the SKILL.md to address each failure
5. **Re-score** — Recount; if not at 100%, return to step 3
6. **Present** — Show summary of changes and final score

If after two fix cycles items still fail, surface the specific blockers to the user rather than continuing to guess.

### Baseline Checklist

Derived from the [skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator) authoring standard.

#### Description (frontmatter)
- [ ] Written in third person ("Processes X" not "I can help with X")
- [ ] Includes WHAT (specific capabilities) and WHEN (trigger scenarios/keywords)
- [ ] Specific enough for skill discovery — no vague verbs like "helps with" or "assists"

#### Body
- [ ] SKILL.md body is under 500 lines
- [ ] No time-sensitive information (no dates, version cutoffs, "currently X")
- [ ] Consistent terminology — one term per concept, used throughout
- [ ] Concrete examples present — not abstract descriptions of what examples would look like
- [ ] File references are one level deep (SKILL.md → reference.md, not deeper)

#### Structure
- [ ] Progressive disclosure: essential content in SKILL.md, detail in companion files
- [ ] Workflows use clear numbered steps or checklists
- [ ] No Windows-style paths (`scripts/helper.py`, not `scripts\helper.py`)

#### Progress & Visibility (conditional — only applies if the skill has multiple steps/phases OR dispatches agents)
- [ ] Multi-step skills have a Progress Tracking section with explicit TaskCreate examples showing what tasks to create at the start
- [ ] Skills that dispatch agents require `model:` to be set explicitly on every Agent dispatch

### Extended Criteria

When doing a deep improvement pass, also evaluate:

- [ ] No internal redundancy — the same instruction does not appear in two places
- [ ] DRY within body — if guidance appears in both a "do this" and "don't do this" form, keep only one
- [ ] Good/bad contrast examples — examples show both correct and incorrect forms
- [ ] Input/decision points are prioritized — grouped or tiered so the agent knows what to address first
- [ ] All format examples have concrete filled-in content, not just empty templates

#### Principles Alignment
<!-- Source of truth: skill-creator/references/skill-design-principles.md
     Update these criteria when the source principles change. -->

When doing a deep improvement pass, also evaluate against skill design principles:

- [ ] Mental model present — skill opens with a conceptual framing paragraph before any rules or workflow steps
- [ ] Description is trigger-only — frontmatter description contains trigger conditions/keywords, not a workflow summary or capability list
- [ ] Scope boundary stated — skill explicitly says what it does NOT do, or names the sibling skill that handles the adjacent case
- [ ] Instructions are traceable — each major instruction can be linked to a failure mode (what goes wrong without it); flag instructions with no apparent failure consequence
- [ ] Policy/procedure balance — workflow steps that involve judgment use policy framing ("when X, prioritize Y because...") rather than rigid mechanical sequences
- [ ] Preconditions checked — if the skill requires input artifacts, there is an explicit check-and-fail instruction, not silent assumption
- [ ] Token-budget boundary correct — detail needed only at one decision point lives in a companion file, not inline in SKILL.md body (distinct from the baseline "progressive disclosure" check which verifies companion files exist; this checks the always-on vs on-demand split is right)

---

## Pass 2: Behavioral Loop

Requires an EVAL.md in the skill's directory with output criteria (EVAL-Oxx) and test prompts.

### The Loop

1. **Read** — Read EVAL.md test prompts and output criteria
2. **Run** — For each test prompt, spawn a subagent with the skill and capture the output
3. **Grade** — Evaluate each output against every EVAL-Oxx criterion (binary pass/fail)
4. **Trace** — For each failing criterion, identify which SKILL.md instruction caused the failure (or which instruction is missing)
5. **Fix** — Edit SKILL.md to address root causes
6. **Re-run** — Re-execute test prompts and re-grade
7. **Present** — Show score card with per-prompt, per-criterion results

### Running the Skill

For each test prompt, spawn a subagent:

```
Execute this task using the skill at [path-to-skill]:
- Task: [test prompt from EVAL.md]
- Save output to: [workspace]/run-[N]/prompt-[ID]/output/
```

If the skill's EVAL.md contains an `## Execution Criteria` section, append to the subagent prompt:

```
---
After completing the task above, append an `## Execution Trace` section to your response. Record in YAML format:
- phases_executed: list of phases that ran
- agents_dispatched: for each Agent() call, record phase, purpose, target, and model
- workflow_decisions: for each key branching decision, record what was decided, what was chosen, and why
- precondition_checks: for each input validation, record what was checked and pass/fail
- context_isolation: boolean flags for what was deliberately excluded from subagent prompts
Nesting: shallow (trace only top-level execution, not recursive subagent traces).
---
```

If no Execution Criteria section exists in EVAL.md, do not inject the trace protocol.

### Grading

For each output, evaluate every EVAL-Oxx criterion:

```markdown
| Prompt | EVAL-O01 | EVAL-O02 | EVAL-O03 | ... | Pass Rate |
|--------|----------|----------|----------|-----|-----------|
| Naive 1 | PASS | FAIL | PASS | ... | 8/10 |
| Expert 1 | PASS | PASS | PASS | ... | 10/10 |
| Adversarial 1 | FAIL | FAIL | PASS | ... | 5/10 |
```

### Execution Grading (when EVAL-E criteria exist)

For each output that includes an execution trace, evaluate every EVAL-Exx criterion:

```markdown
| Prompt | EVAL-E01 | EVAL-E02 | EVAL-E03 | ... | Pass Rate |
|--------|----------|----------|----------|-----|-----------|
| Naive 1 | PASS | PASS | N/A | ... | 2/2 |
| Expert 1 | PASS | FAIL | PASS | ... | 4/5 |
```

If the execution trace is missing (subagent did not append it), mark all EVAL-E criteria as FAIL for that prompt and note "trace missing" as the root cause.

### Tracing Failures

When an output criterion fails, trace backward:

1. **What failed?** — e.g., EVAL-O03 "traceability matrix is complete" failed for Naive 1
2. **What's in the output?** — The matrix is missing 3 requirements
3. **What instruction should have prevented this?** — The skill says "build the traceability matrix at the end" but doesn't say "verify every requirement appears"
4. **Fix** — Add verification instruction to SKILL.md

### Tracing Execution Failures

When an execution criterion fails, trace backward:

1. **What failed?** — e.g., EVAL-E02 "Phase 1 subagents use model: sonnet" failed
2. **What's in the trace?** — The trace shows model: opus for Phase 1 dispatches
3. **What instruction should have prevented this?** — The skill says "dispatch per-file agents" but doesn't specify model
4. **Fix** — Add explicit `model: sonnet` instruction to the Phase 1 dispatch section of SKILL.md

### When to Stop

- All output criteria pass across all test prompts
- OR pass rate is stable across two consecutive cycles (skill is at its ceiling for these prompts — surface remaining failures as blockers)
- After three behavioral cycles with no improvement, stop and report

---

## EVAL.md Auto-Detection

When invoked on a skill, check for `EVAL.md` in the same directory as the target SKILL.md:

- **EVAL.md exists** → use its structural criteria (EVAL-Sxx) in Pass 1, output criteria (EVAL-Oxx) and test prompts in Pass 2
- **EVAL.md does not exist** → run Pass 1 only with baseline + extended checklist, then offer:
  > "No EVAL.md found. Generate one now to enable behavioral testing? (recommended)"
  - If **yes** → dispatch `write-skill-eval` as an **isolated subagent** (model: sonnet) with only the skill path — no session context. Then proceed to Pass 2 with the generated EVAL.md.
  - If **no** → stop after Pass 1. Note: behavioral quality is unverified.

  **Why isolated subagent:** test prompts are generated blind (the generator must not have seen the SKILL.md body). Dispatching as a subagent preserves the bias control even when improve-skill has already read and modified the skill.

---

## Score Card Format

### Structural Pass

```
Structural Cycle 1: 7/11 baseline (+ 2/5 extended, + 3/4 EVAL-S)
Failing:
  - description not third-person (line 3)
  - EVAL-S02: no boundary behavior guidance (missing section)
→ fixing...

Structural Cycle 2: 11/11 (+ 5/5 extended, + 4/4 EVAL-S) → structural pass complete
```

### Behavioral Pass

```
Behavioral Cycle 1: 42/60 criteria passed across 6 prompts
Failing patterns:
  - EVAL-O03 fails on all naive prompts (traceability incomplete)
  - EVAL-O07 fails on adversarial prompt (didn't push back on compound scope)
Root causes:
  - Missing verification step for traceability
  - No instruction for scope-splitting when input is compound
→ fixing SKILL.md...

Behavioral Cycle 2: 58/60 → improving
Behavioral Cycle 3: 60/60 → behavioral pass complete
```

### Execution Pass (when EVAL-E criteria exist)

```
Execution Cycle 1: 3/5 EVAL-E criteria passed
Failing:
  - EVAL-E02: Phase 1 subagents dispatched with model: opus (should be sonnet)
  - EVAL-E05: Phase 1 prompt includes acceptance criteria (context isolation violated)
Root causes:
  - No explicit model instruction in Phase 1 dispatch
  - Phase 1 prompt template includes AC by default
→ fixing SKILL.md...

Execution Cycle 2: 5/5 → execution pass complete
```

---

## Constraints

- Do NOT change functional content — only fix items that fail criteria
- Do NOT rewrite instructions just to "improve" phrasing — conciseness is itself a quality criterion
- If a failing item requires domain knowledge the skill doesn't have, surface it as a blocker rather than guessing
- During behavioral pass, the fix is always in SKILL.md — never modify test prompts or EVAL.md criteria to make them pass
