# PROGRAM.md — Format Specification

Research directions for auto-research loops (Karpathy AutoResearch pattern). Only create this when a target is entering automated improvement.

PROGRAM.md is human-written and **immutable** during the auto-research loop — the agent reads it for direction but never modifies it. This is the equivalent of Karpathy's `program.md` in [autoresearch](https://github.com/karpathy/autoresearch).

## Scoring Modes

Auto-research supports two scoring modes. The mode is determined during setup based on the target's output determinism:

| Mode | When to use | Decision logic |
|------|------------|----------------|
| **Numerical** | Output is deterministic and reproducible (test counts, benchmarks, binary criteria) | Compare absolute scores: 5/6 > 4/6 |
| **Comparative** | Output is semi-deterministic or requires judgment to evaluate (skill quality, code style, document quality) | A/B judge: preferred > tie > rejected |

**Comparative is the default.** Most targets involve judgment calls. Only use numerical when the metric is truly reproducible and objective.

## Golden Reference — Numerical Mode

```markdown
# [Target Name] — Auto-Research Program

## Objective

Maximize EVAL.md pass rate across all test inputs. Current baseline: 4/6 criteria passing.

## Scoring mode

Numerical

## Metric

Score = number of EVAL.md output criteria passed out of total, averaged across all
test-inputs/. A run scores 0 on crash or timeout.

## Mutable files

Only modify these — everything else is locked:
- SKILL.md (instructions, judgment calls, structure)
- templates/*.md (output skeletons)
- rules/*.md (hard constraints)
- examples/*.md (worked examples)

## Immutable files (DO NOT MODIFY)

- EVAL.md — the scoring criteria
- PROGRAM.md — this file
- test-inputs/ — fixed stimulus
- references/ — domain knowledge (modify only if factually wrong)

## Exploration directions

Try these strategies, roughly in priority order:
1. Simplify instructions — remove lines that don't change output (test by deleting and scoring)
2. Add a gold example — concrete input/output pairs anchor model behavior more than rules
3. Restructure the mental model section — a better conceptual framing helps edge cases
4. Reduce template rigidity — over-specified templates cause the model to force-fit bad output
5. Split large rules into smaller, testable statements — easier to trace failures

## Constraints

- SKILL.md must stay under 500 lines
- Do not change the output format or section headings (downstream consumers depend on them)
- Do not add dependencies on tools/MCPs the skill doesn't already use
- Preserve the execution fence comment
- Keep language imperative and opinionated — no hedging ("consider", "you might")

## Loop mechanics

1. Read current git state and iterations.tsv for context on what's been tried
2. Pick a strategy from exploration directions (or invent one if all have been tried)
3. Make a focused change — one idea per iteration, not multiple
4. git commit with a descriptive message
5. Run the scoring mechanism against test inputs
6. Compare score to previous best numerically
7. Record in research/iterations.tsv: iteration, commit hash, score, status, one-line description
8. If score improved → keep (advance branch)
9. If score equal or worse → git reset to previous best
10. Repeat — do not stop or ask for permission

## Stop conditions

- All EVAL.md criteria pass on all test inputs (6/6) — success, stop
- 10 consecutive iterations with no improvement — stop, log conclusion in changelog.md
- SKILL.md exceeds 500 lines — stop, the skill needs structural refactoring first
```

## Golden Reference — Comparative Mode

```markdown
# [Target Name] — Auto-Research Program

## Objective

Optimize [target] beyond binary criteria ceiling. Current state: EVAL.md 23/23 (ceiling reached), but output quality has room for improvement on [specific dimensions].

## Scoring mode

Comparative

## Comparison dimensions

Ranked by priority (dimension 1 outweighs dimension 3 in conflicts):
1. [Dimension 1] — [what "better" looks like for this dimension]
2. [Dimension 2] — [what "better" looks like]
3. [Dimension 3] — [what "better" looks like]

## Comparison protocol

1. Generate output from current version using test inputs
2. Retrieve previous best output (from best commit)
3. Present both to judge in randomized order (avoid position bias)
4. Judge evaluates each dimension independently, citing evidence
5. Verdict: preferred (current wins majority by priority), tie, or rejected

## Mutable files

Only modify these — everything else is locked:
- SKILL.md (instructions, judgment calls, structure)
- templates/*.md (output skeletons)

## Immutable files (DO NOT MODIFY)

- EVAL.md — binary criteria (ceiling already reached, used as regression guard)
- PROGRAM.md — this file
- test-inputs/ — fixed stimulus
- references/ — domain knowledge

## Exploration directions

Try these strategies, roughly in priority order:
1. [Strategy 1 — user-provided]
2. [Strategy 2 — user-provided]
3. [Strategy 3 — user-provided]

## Constraints

- [Constraint 1]
- [Constraint 2]
- EVAL.md criteria must not regress — run binary check as a guard before comparative scoring

## Loop mechanics

1. Read current git state and iterations.tsv for context on what's been tried
2. Pick a strategy from exploration directions (or invent one if all have been tried)
3. Make a focused change — one idea per iteration, not multiple
4. git commit with a descriptive message
5. Regression guard: verify EVAL.md binary criteria still pass (if applicable)
6. Run A/B comparison: judge current output vs previous best on each dimension
7. Record in research/iterations.tsv: iteration, commit, verdict, dimension wins, status, summary
8. If preferred → keep (advance branch)
9. If tie or rejected → git reset to previous best
10. Repeat — do not stop or ask for permission

## Stop conditions

- [N] consecutive iterations with no improvement — stop, log conclusion in changelog.md
- All exploration directions exhausted with no improvement — stop and report
- Mutable files exceed size threshold — stop, needs refactoring
```

## Adapting for your target

The golden references above are templates. When writing a PROGRAM.md:

- **Scoring mode**: determined during setup — comparative (default) or numerical
- **Objective**: replace the baseline with your actual current state
- **Mutable files**: list only the files that exist in your target directory
- **Exploration directions**: tailor to what you think is weak — these come from the user, not the agent
- **Constraints**: add domain-specific constraints (e.g., "signal naming must follow IEEE 1800 conventions")
- **Stop conditions**: adjust thresholds based on target complexity
- **Comparative mode**: the comparison dimensions and priority ranking are critical — vague dimensions produce noisy judging. "Error message specificity" is good; "overall quality" is bad
- **Regression guard**: for skills that have hit EVAL.md ceiling, always include the binary criteria check as a guard rail before comparative scoring

## Living example

See `../../PROGRAM.md` (skill-creator's own) for a filled-in, real-world PROGRAM.md (numerical mode).
