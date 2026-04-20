# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A **central library** for Claude Code skills — both a home for standalone skills and a registry that submodules skill suites from external repos. Skills are organized into domain directories and installed as symlinks into `~/.claude/skills/`.

Two kinds of skills live here:
- **Standalone skills** — self-contained SKILL.md + EVAL.md with no shared infrastructure. These live directly in this repo.
- **Submoduled suites** — multi-skill projects with shared config, templates, and CI. These live in their own repos and are wired in as git submodules.

## Repository Layout

```
identity/                     # Personal identity files (SOUL.md, STAKEHOLDER.md)
src/
  skills/
    <domain>/
      <skill-name>/           # git submodule OR local skill directory
        SKILL.md              # The skill definition (frontmatter + body)
        EVAL.md               # Test prompts + output criteria (optional)
        references/           # Companion files loaded on-demand during specific phases
        templates/            # Output templates
        agents/               # Symlinks to src/agents/ definitions used by this skill
  agents/                     # Internal recipes dispatched by skills (not user-invocable)
  protocols/                  # Shared conventions/schemas injected into agents by observers
  SKILLS_REGISTRY.yaml        # Pipeline metadata and stage dependencies
```

**Identity files (`identity/`):**
- `SOUL.md` — personal identity file: background, worldview, opinions, thinking style, blind spots, tensions, boundaries
- `SOUL.template.md` — blank skeleton with guidance for creating your own SOUL.md
- `STAKEHOLDER.md` — decision proxy persona: priorities, expertise map, heuristics, red flags, escalation triggers

**Root files:**
- `AGENTS_REGISTRY.md` — human-readable agent discovery table
- `TAXONOMY.md` — controlled vocabulary for skill `domain` and `intent` metadata fields
- `GOVERNANCE.md` — repo-level governance: promotion criteria, contribution workflow, naming conventions
- `install.sh` — CLI for installing/managing skill symlinks
- `Makefile` — repo setup (`make init` configures git hooks)
- `.githooks/` — git hooks for structural validation on commit

## Submodule Architecture

Skill suites with shared infrastructure (multiple related skills, shared templates, suite-specific CI) live in their own repos and are wired in as git submodules. This makes them portable — a team can adopt `jira-suite` without pulling all of ai-synapse.

**When to keep a skill in ai-synapse:** It's standalone — one SKILL.md + EVAL.md, no shared config, no multi-skill coordination.

**When to extract to its own repo:** The skill is part of a suite with shared infrastructure, needs its own CI, or is meant to be adopted independently by other teams.

**Adding a submoduled suite:**
1. Create a standalone repo with the skill(s), shared config, and its own CI
2. Add it as a git submodule under the appropriate domain directory in this repo
3. Register the skill(s) in `src/SKILLS_REGISTRY.yaml` and domain `README.md` as usual
4. `install.sh` works the same — it follows symlinks regardless of whether the source is a submodule or local directory

**Modifying a submoduled skill:**
- Make changes in the skill's own repo, not here
- Update the submodule pointer in this repo after the external change lands

**Registration is intentional, not automatic.** Skills land in ai-synapse only after review (`/skill-creator` or `/improve-skill`), with an EVAL.md, via a PR that adds the submodule + registry entry. Standalone repos are where free iteration happens; ai-synapse is where you promote to. Anything in this repo is trusted quality.

## Setup

After cloning, run `make init` to configure git hooks.

## Install Commands

```bash
./install.sh install all                          # install everything
./install.sh install src/skills/docs src/skills/code/build-plan # install specific domains or skills
./install.sh identity                             # install identity files (SOUL.md, stakeholder.md)
./install.sh list                                 # show installed skills
./install.sh available                            # show all available skills
./install.sh clean                                # remove all symlinks
```

Target directory: `$CLAUDE_SKILLS_DIR` (default: `~/.claude/skills/`).

## Skill Anatomy

Every SKILL.md has YAML frontmatter followed by a markdown body:

```yaml
---
name: skill-name
description: "Trigger conditions — when this skill fires (not a workflow summary)"
domain: docs.spec           # from TAXONOMY.md
intent: write               # from TAXONOMY.md
tags: [lowercase, hyphenated]
user-invocable: true
argument-hint: "[args]"
---
```

The `description` field is a **routing contract**: it specifies when the skill fires, not what it does. If the description could replace reading the body, it's too broad.

## Pipeline System

The autonomous orchestrator drives end-to-end pipelines using stages defined in `src/SKILLS_REGISTRY.yaml`. Each stage has typed inputs/outputs and dependency chains (`requires_all`/`requires_any`). Named presets (e.g., `full`, `feature`, `bugfix`) are trusted stage sequences that bypass dependency resolution. A stakeholder-reviewer gates stage transitions.

## Skill Design Principles

These are the core principles for writing and modifying skills (full reference: `src/skills/skill/skill-creator/references/skill-design-principles.md`):

1. **Context injection, not programming** — only include what the agent can't derive from training. Token bloat degrades output quality.
2. **Mental model before mechanics** — lead with a conceptual framing paragraph, then rules.
3. **Policy over procedure** — teach judgment ("when X, prioritize Y over Z because...") not step-by-step mechanics.
4. **Progressive disclosure** — SKILL.md carries always-on info; companion files in `references/` load at specific decision points.
5. **Every instruction traces to a failure mode** — no instruction without "without this, the agent does X which causes Y."
6. **Loud failure on preconditions** — check inputs and fail clearly; never proceed silently with bad data.

## After Modifying a Skill

Whenever any file inside a skill directory changes (SKILL.md, references/, templates/, EVAL.md, or companion files), two layers of validation apply:

### Layer 1: Structural checks (enforced by pre-commit hook)

These run automatically on every commit — no LLM needed:

- SKILL.md frontmatter has required fields (`name`, `description`, `domain`, `intent`)
- `domain` and `intent` values exist in `TAXONOMY.md`
- Domain README.md has a row matching the skill
- EVAL.md exists alongside SKILL.md

### Layer 2: Quality evaluation (enforced by GitHub Action on PR)

The evaluation tier depends on the type of change:

- **New skill or external import** → run `/skill-creator` (full pipeline: baseline test, design principles, eval generation, improvement loop)
- **Modified existing skill** (SKILL.md, references/, templates/) → run `/improve-skill` (score-fix loop against existing EVAL.md)
- **Trivial changes** (typos, formatting-only) → Layer 1 is sufficient

## Conventions

- **Skill names must be globally unique.** Claude discovers skills from a flat `~/.claude/skills/` directory — no namespacing is possible. Use domain-prefixed names (e.g., `jira-reporter`, `jira-planner`) to avoid collisions across repos. `install.sh` warns on name collisions.
- Skills with 3+ phases include a **Progress Tracking** section with `TaskCreate` examples.
- **Wrong-Tool Detection** sections redirect to sibling skills when the user's intent doesn't match.
- EVAL.md files are generated artifacts containing structural criteria, output criteria, and test prompts.
- Pipeline-routable skills must be registered in `src/SKILLS_REGISTRY.yaml` with `stage_name`, `input_type`, `output_type`, `context_type`, and `requires_*`.
- Domain and intent values must come from `TAXONOMY.md`. If nothing fits, propose an addition there — don't invent ad hoc values.
