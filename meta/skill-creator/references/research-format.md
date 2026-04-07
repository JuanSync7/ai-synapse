# research/ — Format Specification

Created by auto-research runs. Contains two files. The agent creates this directory on its first iteration — do not pre-create it.

## iterations.tsv

Tab-separated experiment log. The agent uses `git diff` between commits to understand what changed — no file snapshots needed.

### Template (header row)

```
iteration	commit	score	status	change_summary
```

| Column | Format | Description |
|--------|--------|-------------|
| iteration | 3-digit zero-padded | Sequential experiment number |
| commit | 7-char git hash | Short hash for `git diff` lookups |
| score | N/M | EVAL.md criteria passed / total |
| status | keep\|discard\|crash | Whether the change was kept |
| change_summary | free text | One-line description of what was tried |

### Filled example

```
iteration	commit	score	status	change_summary
001	a3f2c1d	4/6	keep	baseline — no changes, initial score
002	b7e9d4a	5/6	keep	simplified template, removed redundant rule about YAML formatting
003	c1a8f3b	5/6	discard	added gold example — no score change
004	e2d1a9f	4/6	discard	removed mental model paragraph — regression, two criteria failed
005	d4c2e7f	6/6	keep	restructured mental model section with good/bad contrast
```

---

## changelog.md

Human-readable narrative of what improved and why. Written by the agent at stop condition. Useful for onboarding someone new to the skill or understanding design decisions.

### Template

```markdown
# [Skill Name] — Research Changelog

## Run: [date] — [run tag or branch name]

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

### Filled example

```markdown
# skill-creator — Research Changelog

## Run: 2026-04-07 — autoresearch/apr7

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
