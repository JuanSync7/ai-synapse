# Brainstorm Notes — Creating a Global SOUL.md

## Status

- **Phase:** DONE
- **Type:** exploratory
- **Anticipated shape:** Spec
- **Turn count:** 9
- **Lenses:** Stakeholder, Alternative (universal) + Constraint, Time (exploratory type-specific)

## Threads (indexed)

### T1: What is the unit of a soul
**Status:** resolved
**Lenses applied:** Stakeholder ✓ Alternative ✓
One per person. Descriptive, not prescriptive. Two consumption modes: emulate (Job 1) vs compensate (Job 2). Multi-agent: each agent reads only its own person's SOUL.md.

### T2: Identity scope
**Status:** resolved
**Lenses applied:** Stakeholder ✓ Alternative ✓
Comprehensive identity. Cross-domain bleed (SystemVerilog → software) is valuable signal.

### T3: Predict-your-takes test
**Status:** resolved
**Lenses applied:** Stakeholder ✓ Alternative ✓
Gold standard. Center of gravity, not cage. Enables both default prediction and challenge identification.

### T4: Structure — 7 sections
**Status:** resolved
**Lenses applied:** Constraint ✓ Time ✓ Stakeholder ✓ Alternative ✓
Who I Am, Worldview, Opinions, Thinking Style, Blind Spots & Growth Edges, Tensions & Contradictions, Boundaries. 500-line budget.

### T5: Portability
**Status:** resolved
**Lenses applied:** Stakeholder ✓ Alternative ✓
Plain markdown. LLM-legible. Cross-tool compatible.

### T6: Maintenance burden
**Status:** resolved
**Lenses applied:** Time ✓
Slow cadence. Fast-decaying content → MEMORY.md. Quarterly or on major shifts.

### T7: Signal density
**Status:** resolved
**Lenses applied:** Constraint ✓
500 lines / ~3-5k tokens. Acceptable for always-loaded global file.

### T8: Anti-pattern (Job 2)
**Status:** resolved
**Lenses applied:** Stakeholder ✓ Alternative ✓
Blind Spots section in soul. Same data, consuming agent decides emulate vs compensate.

### T9: stakeholder.md relationship
**Status:** resolved
**Lenses applied:** Stakeholder ✓ Alternative ✓
Independent files. Different purpose (identity vs decision proxy), different update cadence.

### T10: Distribution
**Status:** resolved
**Lenses applied:** Stakeholder ✓ Alternative ✓
identity/ directory in ai-synapse. Symlinked to ~/.claude/. Contains SOUL.md, SOUL.template.md, STAKEHOLDER.md.

### T11: Consumption mechanism
**Status:** resolved
**Lenses applied:**
Option 1: reference from global CLAUDE.md. Always loaded. One-liner reference.

## Resolution Log

- T1 resolved (turn 3) — squish A+B: one soul, two consumption modes
- T2 resolved (turn 2-5) — comprehensive identity, cross-domain signal matters
- T3 resolved (turn 2) — predict-your-takes is the gold standard
- T4 resolved (turn 5-7) — 7 sections, dropped 4 sections to other homes
- T5 resolved (turn 2) — plain markdown, full portability
- T6 resolved (turn 5) — stable sections only, slow update cadence
- T7 resolved (turn 4) — 500 lines budget
- T8 resolved (turn 3) — Blind Spots section, interpretation by consumer
- T9 resolved (turn 6) — independent from SOUL.md
- T10 resolved (turn 8) — identity/ in ai-synapse + template
- T11 resolved (turn 9) — reference from CLAUDE.md, always loaded

## Key Insights

- SOUL.md serves two jobs: emulation (be me) and compensation (challenge me) — same data, different interpretation
- stakeholder.md is already a partial soul extraction — they stay independent
- identity/ directory completes ai-synapse: skills (what Claude does) + identity (who you are)
- Fast-decaying content (current focus, interests) → MEMORY.md; stable identity → SOUL.md
- Multi-agent brainstorm room: each agent reads only its own person's SOUL.md, preserving diversity
- SOUL.md is always loaded via CLAUDE.md reference — identity is always present

## Discarded Candidates

- Model C (composable fragments) — loses cross-trait interactions
- Multiple SOUL.md files per person — one soul, multiple interpreters
- Cross-reading souls in multi-agent — each reads only its own
- SOUL.md → stakeholder.md derivation — kept independent
- Separate repo for soul files — ai-synapse is the reference implementation
- Current Focus, Vocabulary, Pet Peeves, Interests, Influences sections — moved to other homes
