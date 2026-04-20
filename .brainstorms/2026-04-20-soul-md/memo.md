# Decision Memo — Creating a Global SOUL.md

**Shape:** Spec
**Type:** exploratory
**Session:** `2026-04-20-soul-md`

---

## What to build

A global `SOUL.md` file that defines your identity — who you are, how you think, your blind spots — consumed by AI agents across all tools. The soul serves two jobs: **emulation** (agents that act like you) and **compensation** (agents that challenge your weaknesses). Same file, different interpretation by the consuming agent or skill.

Inspired by [Aaron Mars' soul.md framework](https://github.com/aaronjmars/soul.md) and the [OpenClaw SOUL.md concept](https://docs.openclaw.ai/concepts/soul), adapted for dual-use (emulation + compensation) and integrated into the ai-synapse skill ecosystem.

## Requirements

### Functional

- **7 sections:**
  1. **Who I Am** — background, what shapes your thinking (hardware→software bridge, cross-domain influences)
  2. **Worldview** — core beliefs, specific enough to be wrong
  3. **Opinions** — professional/technical domains, real takes with reasoning
  4. **Thinking Style** — how you approach problems, learn, make decisions
  5. **Blind Spots & Growth Edges** — self-aware weaknesses; enables Job 2 (compensation) by consuming agents
  6. **Tensions & Contradictions** — where your beliefs conflict with each other (real people are inconsistent)
  7. **Boundaries** — hard limits on what you won't delegate or accept

- **Always loaded:** Referenced from global `~/.claude/CLAUDE.md` so it's present in every session
- **Two consumption modes:** Agents/skills decide whether to emulate the soul or compensate for its blind spots — the soul is descriptive, interpretation is the reader's job
- **Template provided:** `SOUL.template.md` with section guidance and quality checklist alongside the filled personal version

### Non-functional

- **~500 lines max** (~3,000–5,000 tokens) — acceptable budget for an always-loaded global file
- **Plain markdown** — no tool-specific syntax; portable across Claude Code, Cursor, Windsurf, OpenClaw
- **LLM-legible** — written for agent consumption, not human stranger readability
- **Stable cadence** — updates quarterly or on major life/career shifts, not weekly
- **Predict-your-takes test** — quality bar: someone (or an agent) reading the soul should be able to predict your position on a new topic

## Constraints

- **Independent from stakeholder.md.** SOUL.md = identity (who you are). stakeholder.md = decision proxy (how you evaluate). They overlap in values/priorities but serve different consumers with different update cadences. Neither derives from the other.
- **Fast-decaying content lives elsewhere:**
  - Current Focus → MEMORY.md (temporal, per-conversation)
  - Interests → MEMORY.md
  - Vocabulary → project-level CLAUDE.md (context-dependent)
  - Pet Peeves → stakeholder.md Red Flags (operational overlap)
  - Influences → absorbed into Worldview and Opinions sections
- **No secrets.** The file is meant to be shared and version-controlled.

## Audience / users

1. **You** — primary. The soul shapes every Claude interaction across all projects.
2. **Your agents** — consume the soul in two modes: emulate (write like you, review like you) or compensate (push back where you're weak, be thorough where you're impatient).
3. **Multi-agent brainstorm rooms** (future) — each agent reads only its own person's SOUL.md, preserving diversity. Agents can swap between Job 1 and Job 2 mid-session.
4. **Other users** — the template and your filled example in ai-synapse show others how to create their own.

## Acceptance criteria

- [ ] `identity/` directory exists in ai-synapse with: `SOUL.md`, `SOUL.template.md`, `STAKEHOLDER.md`
- [ ] `SOUL.md` has all 7 sections filled with personal content
- [ ] `SOUL.template.md` has all 7 sections with guidance comments and quality checklist
- [ ] File is ≤500 lines
- [ ] Global `~/.claude/CLAUDE.md` references `~/.claude/SOUL.md` for always-on loading
- [ ] `install.sh` updated to symlink `identity/SOUL.md` → `~/.claude/SOUL.md`
- [ ] Passes the predict-your-takes test: an agent reading the soul can reasonably predict your stance on a new technical question

---

## What surfaced along the way

- **The anti-pattern insight** (T8) was the most important discovery: SOUL.md isn't just "make agents be like me" — it's "give agents enough self-awareness about me to know when to push back." The Blind Spots section is what makes this more than a personality clone.
- **stakeholder.md is already a partial soul extraction** — Priorities, Expertise Map, Decision Heuristics are identity-adjacent. Keeping them independent avoids coupling but means some natural overlap. That's fine.
- **Multi-agent SOUL ecosystem** is a compelling future vision: brainstorm rooms where agents carrying different people's SOULs collaborate with HITL. Out of scope for initial implementation but the architecture supports it.
- **Aaron Mars' framework** ([github.com/aaronjmars/soul.md](https://github.com/aaronjmars/soul.md)) is the closest prior art. Key adaptations: added Blind Spots (Job 2), dropped immersion framing (this isn't "be this person" — it's "understand this person"), dropped fast-decaying sections.

## Open questions

- **install.sh scope:** Should `install.sh` handle identity/ symlinks as a new category alongside skills, or should identity files be manually symlinked?
- **CLAUDE.md reference syntax:** Exact wording for the always-load reference — does Claude Code reliably follow "Read ~/.claude/SOUL.md at session start" instructions?
- **Multi-agent consumption:** When/if the brainstorm skill or other skills should explicitly load SOUL.md for Job 2 (compensation), vs. relying on it being in context from the CLAUDE.md reference.

## You might consider next

If you want to build the template and fill in your personal SOUL.md, this is a creative writing + self-reflection task — not a coding task. You could start by taking your diagnostic answers from this session (T2) as raw material and expanding them into the 7 sections. The `identity/` directory and `install.sh` changes are straightforward implementation that could follow.

## Artifacts

- Notepad: `.brainstorms/2026-04-20-soul-md/notepad.md`
- Meta: `.brainstorms/2026-04-20-soul-md/meta.yaml`
