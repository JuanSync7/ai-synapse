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
- No real-world usage yet

## Run: 2026-04-07 — full behavioral pass (all 10 test prompts)

**Prompts tested:** 10/10
**Starting score:** 27/28 criteria
**Final score:** 28/28 (two fixes applied)

### What improved
- Safety gate added to Step 1 — refuses destructive optimization goals (e.g., "optimize until crash"). Routes to load testing/fuzzing instead. (TP-08 fix)
- Resume detection added to pre-flight step 5 — if `research/iterations.tsv` exists, skips baseline/branch creation and continues from last iteration. (TP-06 fix)

### What didn't work
- N/A — both fixes were targeted at specific gaps found in testing

### Test results
- TP-01 (naive): 7/7 PASS — setup mode worked correctly
- TP-02 (naive): 7/7 PASS — after prior fix to ask-dont-suggest
- TP-03 (naive): 7/7 PASS — prompt optimization recognized as valid target
- TP-04 (experienced): 7/7 PASS — clean PROGRAM.md generation
- TP-05 (experienced run): 5/5 PASS — ran mock experiment loop, 7/10 → 10/10
- TP-06 (experienced resume): PASS after fix — resume detection now in pre-flight
- TP-07 (adversarial): PASS — correctly refused overly broad scope
- TP-08 (adversarial crash): PASS after fix — safety gate now catches destructive goals
- TP-09 (wrong-tool): PASS — correctly refused code review request
- TP-10 (wrong-tool): PASS — correctly refused greenfield creation
