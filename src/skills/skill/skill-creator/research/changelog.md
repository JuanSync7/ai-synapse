# skill-creator — Research Changelog

## Run: 2026-04-07 — manual improvement session

**Starting score:** 19/25 (structural checklist)
**Final score:** 25/25
**Iterations:** 2 (2 kept, 0 discarded)

### What improved
- Three-loop workflow (Build/Eval/Improve) — made the decoupled lifecycle of each loop explicit, which clarifies when auto-research takes over
- Improvement artifacts (SCOPE.md, PROGRAM.md, test-inputs/, research/) — added to directory structure with execution fence so models don't load them during skill execution
- rules/ as a recognized companion folder — distinguished from references/ (always-on constraints vs on-demand knowledge)
- Split improvement-artifacts.md into per-artifact reference files — progressive disclosure, agent only loads what it needs
- Auto-research handoff in Phase 7 with artifact generation steps

### What didn't work
- N/A — single improvement pass, no reverted changes

### Remaining gaps
- Behavioral pass (Pass 2) not yet run — structural quality is verified but output quality against EVAL.md test prompts is untested
- EVAL.md not updated to reflect new artifacts (SCOPE.md, PROGRAM.md generation criteria)
