# research/ — Format Specification

Created by auto-research runs. Contains two files. The agent creates this directory on its first iteration — do not pre-create it.

## iterations.tsv

Tab-separated experiment log. The agent uses `git diff` between commits to understand what changed — no file snapshots needed.

The format depends on the scoring mode defined in PROGRAM.md.

### Numerical mode

```
iteration	commit	score	status	change_summary
```

| Column | Format | Description |
|--------|--------|-------------|
| iteration | 3-digit zero-padded | Sequential experiment number |
| commit | 7-char git hash | Short hash for `git diff` lookups |
| score | N/M | Criteria passed / total (or other numeric metric) |
| status | keep\|discard\|crash | Whether the change was kept |
| change_summary | free text | One-line description of what was tried |

**Filled example:**

```
iteration	commit	score	status	change_summary
001	a3f2c1d	4/6	keep	baseline — no changes, initial score
002	b7e9d4a	5/6	keep	simplified template, removed redundant rule about YAML formatting
003	c1a8f3b	5/6	discard	added gold example — no score change
004	e2d1a9f	4/6	discard	removed mental model paragraph — regression, two criteria failed
005	d4c2e7f	6/6	keep	restructured mental model section with good/bad contrast
```

### Comparative mode

```
iteration	commit	verdict	dim_wins	status	change_summary
```

| Column | Format | Description |
|--------|--------|-------------|
| iteration | 3-digit zero-padded | Sequential experiment number |
| commit | 7-char git hash | Short hash for `git diff` lookups |
| verdict | preferred\|tie\|rejected\|— | A/B judge result (— for baseline) |
| dim_wins | X/Y or — | Dimensions won / total (— for baseline) |
| status | keep\|discard\|crash | Whether the change was kept |
| change_summary | free text | One-line description including which dimensions won/lost |

**Filled example:**

```
iteration	commit	verdict	dim_wins	status	change_summary
001	a3f2c1d	—	—	keep	baseline — no changes
002	b7e9d4a	preferred	2/3	keep	tightened error messages — won on specificity and level, tied on coverage
003	c1a8f3b	rejected	1/3	discard	verbose logging — won coverage but lost specificity and level
004	d9e4f2a	tie	1/3	discard	restructured log format — won level, lost specificity, tied coverage
005	e7c3a1b	preferred	3/3	keep	targeted specificity fixes — won all three dimensions
```

---

## changelog.md

Human-readable narrative of what improved and why. Written by the agent at stop condition. Useful for onboarding someone new to the target or understanding design decisions.

### Template — Numerical mode

```markdown
# [Target Name] — Research Changelog

## Run: [date] — [run tag or branch name]

**Scoring mode:** Numerical
**Starting score:** N/M
**Final score:** N/M
**Iterations:** X (Y kept, Z discarded)

### What improved
- [Change that helped and why it worked]

### What didn't work
- [Change that was tried and reverted, and why it failed]

### Remaining gaps
- [Criteria still failing, if any, and hypotheses for why]
```

### Template — Comparative mode

```markdown
# [Target Name] — Research Changelog

## Run: [date] — [run tag or branch name]

**Scoring mode:** Comparative
**Comparison dimensions:** [dim1] > [dim2] > [dim3]
**Iterations:** X (Y preferred, Z rejected, W ties)

### What improved
- [Change that was preferred and which dimensions it won on]

### What didn't work
- [Change that was rejected and which dimensions it lost on]

### Remaining gaps
- [Dimensions that proved hard to improve and hypotheses for why]
```

### Filled example — Numerical

```markdown
# skill-creator — Research Changelog

## Run: 2026-04-07 — autoresearch/apr7

**Scoring mode:** Numerical
**Starting score:** 4/6
**Final score:** 6/6
**Iterations:** 5 (3 kept, 2 discarded)

### What improved
- Removing the YAML formatting rule (iteration 002) — it was noise, Claude already formats YAML correctly
- Adding good/bad contrast to the mental model section (iteration 005) — anchored the agent's interpretation of "opinionated"

### What didn't work
- Adding a gold example without removing other instructions (iteration 003) — token budget was already full, example added noise instead of signal
- Removing the mental model paragraph entirely (iteration 004) — the agent lost the conceptual framing and fell back to mechanical rule-following

### Remaining gaps
- None — all 6 criteria pass. Next run should target model migration (test on mid-tier).
```

### Filled example — Comparative

```markdown
# auto-research — Research Changelog

## Run: 2026-04-07 — autoresearch/scoring-quality

**Scoring mode:** Comparative
**Comparison dimensions:** error specificity > log level correctness > coverage
**Iterations:** 5 (2 preferred, 2 rejected, 1 tie)

### What improved
- Tightened error messages with contextual variable values (iteration 002) — won on specificity and level
- Targeted specificity fixes in edge case handlers (iteration 005) — won all three dimensions

### What didn't work
- Blanket verbose logging (iteration 003) — improved coverage but degraded specificity and level correctness
- Restructuring log format (iteration 004) — lateral move, no clear winner across dimensions

### Remaining gaps
- Coverage dimension proved hard to improve without regressing specificity — may need a structural refactor to separate error paths from info logging
```
