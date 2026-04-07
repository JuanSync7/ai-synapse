# PROGRAM.md — Format Specification

Research directions for auto-research loops (Karpathy AutoResearch pattern). Only create this when a skill is entering automated improvement.

PROGRAM.md is human-written and **immutable** during the auto-research loop — the agent reads it for direction but never modifies it. This is the equivalent of Karpathy's `program.md` in [autoresearch](https://github.com/karpathy/autoresearch).

## Golden Reference

```markdown
# [Skill Name] — Auto-Research Program

## Objective

Maximize EVAL.md pass rate across all test inputs. Current baseline: 4/6 criteria passing.

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

1. Read current git state and results.tsv for context on what's been tried
2. Pick a strategy from exploration directions (or invent one if all have been tried)
3. Make a focused change — one idea per iteration, not multiple
4. git commit with a descriptive message
5. Run the skill against each file in test-inputs/ using the blind tester
6. Score against EVAL.md output criteria
7. Record in research/iterations.tsv: iteration, commit hash, score, one-line description
8. If score improved → keep (advance branch)
9. If score equal or worse → git reset to previous best
10. Repeat — do not stop or ask for permission. If out of ideas, revisit failed strategies
    with a different angle.

## Stop conditions

- All EVAL.md criteria pass on all test inputs (6/6) — success, stop
- 10 consecutive iterations with no improvement — stop, log conclusion in changelog.md
- SKILL.md exceeds 500 lines — stop, the skill needs structural refactoring first
```

## Adapting for your skill

The golden reference above is a template. When writing a PROGRAM.md for a specific skill:

- **Objective**: replace the baseline score with your actual current score
- **Mutable files**: list only the files that exist in your skill directory
- **Exploration directions**: tailor to what you think is weak — if the skill already has good examples but bad rules, prioritize rule restructuring over adding examples
- **Constraints**: add domain-specific constraints (e.g., "signal naming must follow IEEE 1800 conventions")
- **Stop conditions**: adjust thresholds — a complex skill might accept 5/6, a simple one should hit 6/6

## Living example

See `../../PROGRAM.md` (skill-creator's own) for a filled-in, real-world PROGRAM.md.
