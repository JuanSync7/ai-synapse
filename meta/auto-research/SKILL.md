---
name: auto-research
description: "Use when asked to autonomously improve a skill or artifact through repeated experimentation, or to set up an automated improvement loop. Triggered by 'auto-research', 'optimize this overnight', 'run autonomous improvement'."
domain: meta.create
intent: improve
tags: [auto-research, karpathy, experiment-loop, optimization]
user-invocable: true
argument-hint: "setup [target path] | run [path to PROGRAM.md]"
---

# Auto-Research

Runs autonomous iterative improvement on any target — skills, code, prompts, configs — following the [Karpathy AutoResearch](https://github.com/karpathy/autoresearch) pattern. The agent modifies a mutable target, scores it against an immutable metric, keeps improvements, reverts regressions, and repeats until a stop condition is met.

This is the generic version of what `/improve-skill` does for skills specifically. Auto-research works on anything with a mutable target and a scorable metric.

**Relationship to `/improve-skill`:** For skills, improve-skill gets you to the EVAL.md ceiling (all binary criteria passing). Auto-research picks up where improve-skill stops — optimizing beyond the ceiling using comparative evaluation. If a skill hasn't hit its EVAL.md ceiling yet, redirect to `/improve-skill` first.

## Wrong-Tool Detection

- **User wants a one-shot skill fix** or **skill hasn't hit EVAL.md ceiling yet** → redirect to `/improve-skill`
- **User wants to create a new skill** → redirect to `/skill-creator`
- **User wants to evaluate a skill** → redirect to `/write-skill-eval`

## Progress Tracking

At the start, create a task list based on the mode:

**Setup mode:**
```
TaskCreate: "Understand the target"
TaskCreate: "Define metric and scoring mechanism"
TaskCreate: "Draw mutable/immutable boundary"
TaskCreate: "Get optimization strategy and constraints"
TaskCreate: "Define stop conditions"
TaskCreate: "Generate and approve PROGRAM.md"
```

**Run mode:**
```
TaskCreate: "Pre-flight checks"
TaskCreate: "Run experiment loop"
TaskCreate: "Write changelog and report"
```

Mark each task `in_progress` when starting, `completed` when done.

## Scope boundaries

This skill handles autonomous iterative improvement with a measurable metric. It does NOT handle:
- **One-shot fixes** — use `/improve-skill` for a single structural/behavioral pass on a skill
- **Greenfield creation** — use `/skill-creator` to build something from scratch
- **Code review** — this is optimization, not evaluation of existing quality
- **Tasks without a scorable metric or comparison dimensions** — if you can't measure or compare "better," auto-research can't help

## Two modes

| Mode | Trigger | Input | Output |
|------|---------|-------|--------|
| **Setup** | `auto-research setup [target path]` | A goal and the user's domain knowledge | PROGRAM.md ready for `run` mode |
| **Run** | `auto-research run [path to PROGRAM.md]` | A valid PROGRAM.md | Improved target + research/iterations.tsv + research/changelog.md |

---

## Mode: Setup

A structured conversation that produces a valid PROGRAM.md. The user brings the goal and optimization strategy. The agent brings the format and quality control.

**Principle: ask, don't suggest.** Never generate exploration directions, constraints, or strategies for the user. Prompt them to think, then structure their answers into PROGRAM.md format. The user does the reasoning — the agent does the structuring.

### Step 1: Understand the target

Ask:

- "What are you trying to improve?"
- "What does a *bad* output look like today? What's wrong with it?"
- "If I improved one thing overnight, what would you check first tomorrow morning?"

Capture: the mutable target path and a concrete description of what "better" means.

**Safety gate:** If the optimization goal is destructive — the user wants to optimize toward system crashes, data loss, resource exhaustion, or any outcome that intentionally causes harm — refuse. Auto-research optimizes constructively. "Find the point where it breaks" is load testing or fuzzing, not iterative improvement. Route the user to appropriate tooling instead.

### Step 2: Classify scoring mode and define the metric

First, classify the target's output determinism — this determines the scoring approach:

| Output type | Scoring mode | Examples |
|-------------|-------------|----------|
| **Deterministic** — same input always produces comparable output | **Numerical** — absolute metrics (N/M, seconds, pass count) | Test suites, benchmarks, build times, binary criteria counts |
| **Semi-deterministic** — output varies per run or requires judgment to evaluate | **Comparative** — A/B preference by LLM judge | Skill quality beyond EVAL.md ceiling, code style/logging quality, document conciseness, format adherence |

**Comparative is the default.** Most optimization targets involve judgment. Only use numerical when the metric is truly reproducible and objective (e.g., `pytest` pass count, execution time).

Then define the metric based on the mode:

**For numerical mode**, ask:
- "How would you know if I made it worse?"
- "Can you score the output on a scale — like N criteria out of M?"

A valid numerical metric must be: scorable by an agent without human review, producing a numeric or N/M result, and able to distinguish "better" from "same" from "worse."

**For comparative mode**, ask:
- "What specific dimensions should I compare when judging version A vs version B?"
- "Which dimensions matter most? Rank them."

A valid comparative metric must define: concrete comparison dimensions (not "overall quality"), a priority ranking of those dimensions, and what "better" looks like for each dimension.

**Good numerical metric:** "5/8 EVAL.md criteria passing, targeting 8/8" — gradient, scorable, concrete target.
**Good comparative metric:** "Compare on: (1) error message specificity, (2) log level correctness, (3) coverage across functions — prioritized in that order."
**Bad metric (either mode):** "the output should be better quality" — subjective, no dimensions, no target.

**Quality gate:** If the user's metric is purely binary ("it passes or fails"), push back — that's a gate, not a gradient. If the user's metric is subjective without dimensions ("it should feel better"), push back — decompose into concrete dimensions the agent can evaluate.

### Step 3: Identify the scoring mechanism

The metric needs something that runs it. The mechanism depends on the scoring mode.

**For numerical mode**, ask:
- "Is there an existing test suite, EVAL.md, or benchmark script that produces this score?"
- "If not, what would we need to build before starting?"

For skills below EVAL.md ceiling: the scoring mechanism is EVAL.md + the blind tester.
For code: it could be `pytest`, a benchmark runner, or a linter with countable rules.

**For comparative mode**, the scoring mechanism is an LLM judge with a fixed comparison protocol. No external script needed — the agent runs the judge during each iteration. The protocol is:

1. Generate output from the current version using the test inputs
2. Retrieve the previous best output (stored or regenerated from the best commit)
3. Present both outputs to the judge in **randomized order** (to avoid position bias)
4. Judge evaluates each comparison dimension from PROGRAM.md independently
5. Judge returns: **preferred A**, **preferred B**, or **tie** — with cited evidence for each dimension
6. Aggregate across dimensions using the priority ranking: a win on dimension 1 outweighs a loss on dimension 3

Record the comparison dimensions and protocol in PROGRAM.md so run mode can execute it without improvising.

**Quality gate:** If no scoring mechanism exists (numerical) or no comparison dimensions are defined (comparative), stop setup. Auto-research cannot run without automated scoring.

### Step 4: Draw the mutable/immutable boundary

Ask:

- "Which files should I modify? List them."
- "What should I absolutely not touch?"

**Quality gate:** If the mutable set is large (>5 files), push back:

- "You have [N] mutable files — which 3 have the most impact on your metric? Start narrow and expand later."

**Good mutable list:** `SKILL.md`, `templates/report.md`, `rules/naming.md` — specific paths.
**Bad mutable list:** "the main code files" or "whatever needs changing" — vague, unbounded.

### Step 5: Get the optimization strategy

Ask:

- "What strategies should I try? List them in priority order."
- "What have you already tried that didn't work? I'll avoid those."
- "Are there any constraints — things I must preserve even if changing them might improve the score?"

**Quality gate:** If the user provides no strategies, push back:

- "I need at least 2–3 concrete directions to explore. What do you think is causing the current score to be low?"

Do not suggest strategies. Do not add strategies the user did not provide. The PROGRAM.md exploration directions must contain only what the user stated — no "bonus" ideas, no "combine best results" steps, no inferred strategies. The user knows their domain — draw it out of them. If run mode exhausts all user-provided strategies, it may invent variations at that point — but setup mode never invents.

### Step 6: Define stop conditions

Ask:

- "What score would you ship at?"
- "How many failed attempts before I should stop and report back?"

**Quality gate:** If the stop condition is vague ("when it's good enough"), push back:

- "What score number would you ship at? I need a concrete threshold."

Default stop conditions if the user doesn't specify:
- Target score reached — success
- 10 consecutive iterations with no improvement — stop and report
- Mutable files exceed a reasonable size threshold — stop, needs refactoring

### Step 7: Generate PROGRAM.md

> **Read [`references/program-format.md`](references/program-format.md)** for the PROGRAM.md golden reference and format specification.

Assemble the user's answers into PROGRAM.md format. Show it to the user for review before writing. The user must approve — PROGRAM.md is their research brief, not the agent's.

Write PROGRAM.md to the target directory. Do not create `research/` — run mode creates it on first iteration.

---

## Mode: Run

Reads an existing PROGRAM.md and executes the autonomous experiment loop. This mode runs without human interaction until a stop condition is met.

### Pre-flight checks

Before starting the loop:

1. Read PROGRAM.md — reject if missing required sections (objective, metric, mutable files, immutable files, loop mechanics, stop conditions)
2. Verify the scoring mechanism exists and runs — execute it once on the current state to establish baseline
3. Verify all mutable files exist
4. Verify all immutable files exist
5. **Resume detection:** If `research/iterations.tsv` already exists with data rows, this is a resume. Read the last row to get the current iteration number and best score. Skip steps 6–9 — continue on the existing branch at `last_iteration + 1`. Log: "Resuming from iteration N, best score so far: X."
6. Create `research/` directory if it doesn't exist
7. Initialize `research/iterations.tsv` with header row
8. Record baseline: iteration 001, current commit, baseline score, status `keep`, summary "baseline — no changes"
9. Create a git branch `autoresearch/[target-name]-[date]` from current state

### The experiment loop

```
LOOP:
  1. Read research/iterations.tsv — understand what's been tried
  2. Pick a strategy from PROGRAM.md exploration directions
     (or invent one if all have been tried — but respect constraints)
  3. Make a focused change — one idea per iteration, not multiple
  4. git commit with a descriptive message
  5. Run the scoring mechanism as defined in PROGRAM.md
  6. Compare to previous best:
     - Numerical mode: compare scores directly (5/6 > 4/6)
     - Comparative mode: run A/B judge protocol — present previous best
       output and current output in randomized order, judge each
       dimension, aggregate by priority ranking
  7. Record in research/iterations.tsv:
     - Numerical: iteration, commit, score (N/M), status, summary
     - Comparative: iteration, commit, verdict (preferred|tie|rejected),
       dimension wins (e.g., "2/3"), status, summary
  8. If improved (numerical: higher score; comparative: preferred) → keep, advance branch
  9. If equal or worse (numerical: same/lower; comparative: tie/rejected) → git reset to previous best commit
  10. Check stop conditions — if met, exit loop
  11. If not met → repeat
```

> **Read [`references/research-format.md`](references/research-format.md)** for iterations.tsv and changelog.md format specifications.

**Example iteration log — numerical mode:**

```
iteration	commit	score	status	change_summary
001	a3f2c1d	4/6	keep	baseline — no changes
002	b7e9d4a	5/6	keep	simplified template, removed redundant rule
003	c1a8f3b	4/6	discard	removed mental model paragraph — regression
```

**Example iteration log — comparative mode:**

```
iteration	commit	verdict	dim_wins	status	change_summary
001	a3f2c1d	—	—	keep	baseline — no changes
002	b7e9d4a	preferred	2/3	keep	tightened error messages — won on specificity and level, tied on coverage
003	c1a8f3b	rejected	1/3	discard	verbose logging — won coverage but lost specificity and level
```

### On crash or error

If the scoring mechanism fails to run (crash, timeout, missing dependency):
- Record as `crash` with score 0 in iterations.tsv
- Read the error output (last 50 lines)
- If trivially fixable (typo, import error), fix and retry once
- If fundamentally broken, revert and move to next strategy
- Do not spend more than 2 attempts fixing a crashed run

### On stop condition

When a stop condition is met:

1. Write `research/changelog.md` with: what improved, what didn't work, remaining gaps
2. Log final summary to the user: starting score → final score, iterations run, strategies that worked
3. Leave the branch at the best-scoring commit

### Rules

- **Never modify immutable files** — PROGRAM.md, scoring mechanism, test inputs, references
- **One change per iteration** — makes the experiment log interpretable and reverts clean
- **Never stop to ask the user** — the user may be away. If stuck, try a different strategy. If truly out of ideas after exhausting all directions, stop and report in changelog.md
- **Git is the experiment tracker** — every attempt is a commit, every revert is a git reset. The full history is recoverable

> **Execution scope:** In numerical mode, ignore `EVAL.md`, `SCOPE.md` during execution — these are skill-specific artifacts that may or may not exist on the target. In comparative mode, if EVAL.md exists and the target is a skill at ceiling, use it as a **regression guard** (binary check before comparative scoring) — do not ignore it.

## When to Hand Off

| Task | Route to |
|------|----------|
| Target is a skill that hasn't hit its EVAL.md ceiling yet | `/improve-skill [path]` |
| Need to create EVAL.md for a skill before auto-research | `/write-skill-eval [path]` |
| Need to create the skill itself first | `/skill-creator [description]` |

