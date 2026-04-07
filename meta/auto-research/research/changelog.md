# auto-research — Research Changelog

## Run: 2026-04-07 — structural pass (improve-skill)

**Starting score:** 19/25 (structural checklist)
**Final score:** 25/25
**Iterations:** 2 (2 kept, 0 discarded)

### What improved
- Progress Tracking section with TaskCreate examples for both setup and run modes
- Scope boundaries section — explicit "does NOT handle" list with handoff targets
- Good/bad contrast examples for metric definition and mutable file listing
- Concrete filled-in iteration log example in run mode

### What didn't work
- N/A — single improvement pass, no reverted changes

## Run: 2026-04-07 — behavioral pass (improve-skill Pass 2)

**Prompts tested:** 4/10 (TP-02 naive, TP-04 experienced, TP-07 adversarial, TP-09 wrong-tool)
**Starting score:** 27/28 criteria
**Final score:** 27/28 (fix applied, pending re-test)

### What improved
- Strengthened "ask don't suggest" principle in Step 5 — explicitly prohibits adding strategies user didn't provide to PROGRAM.md

### What didn't work
- N/A — single targeted fix

### Remaining gaps
- 6/10 test prompts not yet tested (TP-01, TP-03, TP-05, TP-06, TP-08, TP-10)
- Run mode (EVAL-O08 through O15) untested — requires a real target with scoring mechanism
- No real-world usage yet
