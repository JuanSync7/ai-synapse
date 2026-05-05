# skill-creator — Auto-Research Program

## Objective

Maximize EVAL.md pass rate across all test inputs. Improve the quality of skills that skill-creator produces — measured by whether created skills pass their own EVAL.md on first generation.

## Metric

Score = number of EVAL.md output criteria passed out of total, averaged across all test-inputs/. A run scores 0 on crash or timeout.

## Mutable files

Only modify these — everything else is locked:
- SKILL.md (workflow, principles, phase instructions)
- references/skill-design-principles.md (principle explanations and examples)
- references/improvement-artifacts.md (artifact format specs and golden references)

## Immutable files (DO NOT MODIFY)

- EVAL.md — the scoring criteria
- PROGRAM.md — this file
- test-inputs/ — fixed stimulus

## Exploration directions

Try these strategies, roughly in priority order:
1. Sharpen the execution fence — test whether created skills properly ignore improvement artifacts during execution
2. Improve the SCOPE.md generation guidance — test whether created skills produce actionable capability profiles
3. Simplify Phase 2 instructions — remove lines that don't change the quality of created skills
4. Add a gold example of a complete skill directory to examples/ — concrete reference beats abstract rules
5. Tighten the three-loop framing — test whether the loop separation improves created skill structure
6. Improve the PROGRAM.md generation guidance — test whether created skills produce usable research programs

## Constraints

- SKILL.md must stay under 500 lines
- Do not merge the three loops back into a flat phase list
- Do not remove the baseline test (Phase 1.5) — it prevents unnecessary skills
- Do not change the EVAL.md generation pipeline (Phases 3-5) — that's owned by write-synapse-eval (skill flow)
- Keep language imperative and opinionated — no hedging ("consider", "you might")
- Preserve the execution fence pattern

## Loop mechanics

1. Read current git state and research/iterations.tsv for context on what's been tried
2. Pick a strategy from exploration directions (or invent one if all have been tried)
3. Make a focused change — one idea per iteration, not multiple
4. git commit with a descriptive message
5. Run `/skill-creator` against each prompt in test-inputs/, score the created skill against EVAL.md
6. Record in research/iterations.tsv: iteration, commit hash, score, one-line description
7. If score improved → keep (advance branch)
8. If score equal or worse → git reset to previous best
9. Repeat — do not stop or ask for permission. If out of ideas, revisit failed strategies with a different angle.

## Stop conditions

- All EVAL.md criteria pass on all test inputs — success, stop
- 10 consecutive iterations with no improvement — stop, log conclusion in research/changelog.md
- SKILL.md exceeds 500 lines — stop, the skill needs structural refactoring first
