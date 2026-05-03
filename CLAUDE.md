# CLAUDE.md

Project-level guidance for Claude Code working in ai-synapse. For repo layout, install commands, and architecture overview, see [`README.md`](README.md). This file covers only the load-bearing judgment Claude can't derive from inspection.

## What This Repo Is

A central library of composable artifacts (skills, agents, protocols, tools) for Claude Code and other AI coding harnesses. Three artifact homes:

- **`synapse/`** — framework artifacts (the meta-tools that build/evaluate/govern other artifacts: skill-creator, gatekeeper, eval generators, orchestration).
- **`src/`** — adopter artifacts owned by this repo. May be empty in a pure framework distribution.
- **`external/`** — externally-owned submodule suites with their own CI and shared config.

**Decision rule:** keep an artifact in `src/` if it's standalone. Extract to `external/` if it's part of a multi-artifact suite, needs its own CI, or is meant to be adopted independently. Registration is intentional, not automatic — adding an external suite means adding a submodule + a registry entry in the same PR.

## Setup

`make init` after cloning configures git hooks. Use `./cortex help` for the install/scaffold/validate CLI — see [`README.md`](README.md) for the full command catalog and [`docs/cli/`](docs/cli/) for per-command docs.

## After Modifying an Artifact

Two layers of validation apply. Layer 1 is automatic; Layer 2 is on you.

**Layer 1 — pre-commit hook.** Structural checks run on every commit: frontmatter fields, taxonomy values, registry rows, domain README rows, EVAL.md presence. No LLM. Fails loudly with the specific missing item — fix what it tells you.

**Layer 2 — quality evaluation.** Pick by change type:

| Change | Run |
|--------|-----|
| New skill or external import | `/skill-creator` (full pipeline) → `/synapse-gatekeeper` |
| Modified existing skill (SKILL.md, references/, templates/) | `/improve-skill` (score-fix loop against existing EVAL.md) |
| New or modified agent / protocol / tool / pathway | `/synapse-gatekeeper <artifact-path>` |
| Trivial changes (typos, formatting-only) | Layer 1 is sufficient |

**New artifacts must be certified before merging to `main`.** Include the gatekeeper APPROVE verdict in the PR description. If not ready, mark `status: draft` in the appropriate registry — this is tracked and must be resolved before the artifact is considered production-ready. See [`GOVERNANCE.md`](GOVERNANCE.md) for full promotion criteria.

## Pipeline System

The autonomous orchestrator drives end-to-end pipelines using stages defined in [`synapse/SKILLS_REGISTRY.yaml`](synapse/SKILLS_REGISTRY.yaml). Each stage has typed inputs/outputs and dependency chains (`requires_all` / `requires_any`). Named presets (`full`, `feature`, `bugfix`) are trusted stage sequences that bypass dependency resolution. A stakeholder-reviewer gates stage transitions.

## Skill Design Principles

Apply when writing or modifying skills. Full reference: [`synapse/skills/skill/skill-creator/references/skill-design-principles.md`](synapse/skills/skill/skill-creator/references/skill-design-principles.md).

1. **Context injection, not programming** — only include what the agent can't derive from training. Token bloat degrades output quality.
2. **Mental model before mechanics** — lead with a conceptual framing paragraph, then rules.
3. **Policy over procedure** — teach judgment, not step-by-step mechanics.
4. **Progressive disclosure** — SKILL.md carries always-on info; companion files in `references/` load at specific decision points.
5. **Every instruction traces to a failure mode** — no instruction without "without this, the agent does X which causes Y."
6. **Loud failure on preconditions** — check inputs and fail clearly; never proceed silently with bad data.

## Directory README Convention

Every directory in the repo must have a README.md (exceptions: dot-directories and generated/transient directories like `dist/`).

**READMEs are enforced indexes, not freeform docs.** They are the same class of artifact as taxonomy files — authoritative, structural, validated by the pre-commit hook. The hook checks that domain README.md tables have a row for every artifact in that directory. A missing or stale row is a structural error, not a documentation gap.

- **Leaf directory** (contains artifact files directly): one-line domain description + catalog table of every artifact in the folder.
- **Parent directory** (contains subdirectories): one-line description + summary table per artifact class, one row per subdirectory linking to its README. No content duplication — the parent row is a pointer, not a copy.

**The two-touch rule:** if you add a new artifact or domain, you update exactly two READMEs — the directory it lives in, and its parent. Nothing higher up changes; the summary propagates by link traversal.

## Conventions

- **Skill names must be globally unique.** Claude Code discovers skills from a flat `~/.claude/skills/` directory — no namespacing is possible. Use domain-prefixed names (e.g., `jira-reporter`, `jira-planner`) to avoid collisions. `./cortex install` warns on collisions.
- **Description is a routing contract.** Frontmatter `description` specifies *when* a skill fires, not *what* it does. If the description could replace reading the body, it's too broad.
- **Skills with 3+ phases** include a **Progress Tracking** section with `TaskCreate` examples.
- **Wrong-Tool Detection** sections redirect to sibling skills when intent doesn't match.
- **EVAL.md files are generated artifacts** containing structural criteria, output criteria, and test prompts. Run `/write-skill-eval`, `/write-agent-eval`, or `/write-protocol-eval` to regenerate.
- **Pipeline-routable skills** register a stage entry in [`synapse/SKILLS_REGISTRY.yaml`](synapse/SKILLS_REGISTRY.yaml) with `stage_name`, `input_type`, `output_type`, `context_type`, and `requires_*`. Non-pipeline skills only need a row in [`registry/SKILL_REGISTRY.md`](registry/SKILL_REGISTRY.md).
- **Taxonomy values** must come from the controlled vocabularies in [`taxonomy/`](taxonomy/). If nothing fits, propose an addition there — don't invent ad hoc values.

## Multi-Harness Note

SKILL.md is the universal authoring format across Claude Code, Codex CLI, and Gemini CLI. Extra Claude-specific frontmatter fields are ignored by other harnesses. See [`references/harness-mappings.yaml`](references/harness-mappings.yaml) for the compatibility table.
