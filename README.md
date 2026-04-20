<p align="center">
  <picture>
    <img src="https://raw.githubusercontent.com/JuanSync7/ai-synapse/main/assets/banner.svg" alt="AI-Synapse Banner" width="100%"/>
  </picture>
</p>

<p align="center">
  <b>A skill orchestration framework for Claude Code</b><br/>
  <sub>Composable skills for autonomous doc authoring, code generation, testing, and multi-agent pipelines</sub>
</p>

---

## What is AI-Synapse?

AI-Synapse is a central library of [Claude Code](https://claude.ai/code) skills — reusable, composable units of agent behavior that can be invoked by name from any conversation. Skills are installed as symlinks into `~/.claude/skills/` and discovered automatically by Claude Code. Once installed, invoking a skill is as simple as `/write-spec-docs` or `/autonomous-orchestrator` in any Claude Code session.

The repo serves two roles: a **home for standalone skills** (self-contained, no shared infrastructure) and a **registry that submodules skill suites** from external repos (multi-skill projects with shared config and their own CI). Both are installed the same way via `install.sh`.

### End-to-End Skill Development

AI-Synapse includes a complete lifecycle for building skills themselves — from initial idea to production-ready, certified skill:

| Stage | Skill | What it does |
|-------|-------|-------------|
| **Brainstorm** | [`/skill-brainstorm`](src/skill/skill-brainstorm/) | Coaching session to shape a vague idea into a concrete skill spec — decides if it's a skill, config, or not needed |
| **Create** | [`/skill-creator`](src/skill/skill-creator/) | Scaffolds SKILL.md + EVAL.md with baseline testing and design principles check |
| **Evaluate** | [`/write-skill-eval`](src/skill/write-skill-eval/) | Generates or regenerates EVAL.md with output criteria and test prompts |
| **Improve** | [`/improve-skill`](src/skill/improve-skill/) | Score-fix-rescore loop until quality criteria are met |
| **Research** | [`/auto-research`](src/optimization/auto-research/) | Autonomous modify-measure-keep loop for any measurable target |
| **Certify** | [`/synapse-gatekeeper`](src/skill/synapse-gatekeeper/) | Promotion gate — APPROVE / REVISE / REJECT verdict against governance criteria |

The flow is: **brainstorm → create → improve → certify → PR**. Each stage is optional — jump in wherever your skill is.

---

## Repository Structure

```
ai-synapse/
│
├── src/                            # All skills, organized by domain
│   ├── docs/                       # Documentation authoring pipeline
│   ├── code/                       # Code generation and test execution
│   ├── orchestration/              # Multi-agent coordination
│   ├── skill/                      # Skill lifecycle: brainstorm, create, evaluate, improve, certify
│   ├── meta/                       # Framework utilities: routing, discovery
│   ├── optimization/               # Iterative improvement loops
│   ├── frameworks/                 # Technology-specific skills
│   ├── creative/                   # Visual and interactive output
│   └── integration/                # External service integrations (submodules)
│
├── skill-creator  ->  src/skill/skill-creator/       # root symlink — framework tool
├── improve-skill  ->  src/skill/improve-skill/       # root symlink — framework tool
├── auto-research  ->  src/optimization/auto-research/ # root symlink — framework tool
│
├── src/SKILLS_REGISTRY.yaml         # Pipeline metadata and stage dependency graph
├── src/AGENTS_REGISTRY.md           # Human-readable agent discovery table
├── TAXONOMY.md                     # Controlled vocabulary for domain/intent fields
├── GOVERNANCE.md                   # Promotion criteria, contribution workflow, naming conventions
├── CLAUDE.md                       # Claude Code instructions for this repo
├── install.sh                      # CLI for installing and managing skill symlinks
├── Makefile                        # Setup shortcuts (init, install, list, clean)
└── .githooks/pre-commit            # Structural validation on every commit
```

---

## Root Files

### [`src/SKILLS_REGISTRY.yaml`](src/SKILLS_REGISTRY.yaml)
The single source of truth for pipeline metadata. Every skill that participates in an automated pipeline is registered here with its `stage_name`, `input_type`, `output_type`, `context_type`, and dependency chain (`requires_all` / `requires_any`). The `autonomous-orchestrator` reads this file to resolve stage order, validate type compatibility, and drive end-to-end pipelines. Named presets (`full`, `feature`, `bugfix`, `docs-only`) are defined here as trusted stage sequences that bypass dependency resolution.

### [`src/AGENTS_REGISTRY.md`](src/AGENTS_REGISTRY.md)
Human-readable discovery table for agent definitions — internal recipes dispatched by skills, not user-invocable. Check here before creating a new agent to see if one already covers the capability you need.

### [`TAXONOMY.md`](TAXONOMY.md)
Controlled vocabulary for the `domain` and `intent` frontmatter fields in every `SKILL.md`. Enforced by the pre-commit hook — committing a skill with a value not listed here will fail. When nothing in the taxonomy fits a new skill, the convention is to propose an addition here rather than invent ad hoc values. This keeps skill metadata consistent and makes routing and filtering predictable.

### [`GOVERNANCE.md`](GOVERNANCE.md)
Authoritative rules for the doc-authoring skill suite — layer hierarchy, cross-skill coherence gates, and propagation rules for when specs change. Not loaded at runtime; it is the human-readable source from which rules are inlined into each doc skill's `SKILL.md`. When a rule changes, update `GOVERNANCE.md` first, then propagate to each affected skill. This separation keeps skills self-contained (no runtime file dependency) while providing a single place to reason about suite-level consistency.

### [`CLAUDE.md`](CLAUDE.md)
Project-level instructions for Claude Code. Explains the repo structure, submodule architecture, skill anatomy, and the two-layer validation model (pre-commit structural checks + PR-time quality evaluation). Claude reads this automatically when working in this repo. Changes here affect how Claude interprets tasks and structures contributions.

### [`.githooks/pre-commit`](.githooks/pre-commit)
Runs automatically on every commit touching a skill directory. Checks: required frontmatter fields present, `domain` and `intent` values exist in `TAXONOMY.md`, the domain `README.md` has a row for the skill, and `EVAL.md` exists alongside every `SKILL.md`. Fails loudly with actionable errors. Activated via `make init`.

---

## Architecture

### Skill anatomy

Every skill lives at `src/<domain>/<skill-name>/` and follows this layout:

```
src/<domain>/<skill-name>/
  SKILL.md        # (required) YAML frontmatter + behavior body — the skill definition
  EVAL.md         # (required) Test prompts and pass/fail output criteria for quality evaluation
  references/     # Companion files loaded on-demand during specific phases
  templates/      # Output templates referenced by the skill
```

`SKILL.md` is the install discovery marker — `install.sh` walks `src/` looking for files with that name, so any directory without one is invisible to the installer. The file must exist; contents are not validated at install time (that happens at commit via the pre-commit hook). `EVAL.md` is also required by the pre-commit hook, which will reject a skill directory missing it. `references/` and `templates/` are optional.

`SKILL.md` frontmatter carries routing metadata:

```yaml
---
name: skill-name
description: "Trigger conditions — when this skill fires (not a workflow summary)"
domain: docs.spec       # from TAXONOMY.md
intent: write           # from TAXONOMY.md
tags: [lowercase, hyphenated]
user-invocable: true
argument-hint: "[args]"
---
```

The `description` field is a **routing contract**: it specifies when the skill fires, not what it does. Claude Code matches user intent against this field to select the right skill.

### Two kinds of skills

- **Standalone** — self-contained `SKILL.md` + `EVAL.md`, no shared infrastructure. Lives directly in this repo under `src/<domain>/`.
- **Submoduled suites** — multi-skill projects with shared config and their own CI. Live in external repos, wired in as git submodules under `src/<domain>/`. `install.sh` follows symlinks regardless of source — standalone and submoduled skills install identically. The `integration/jira-suite` is the current example.

Submoduled suites are portable: a team can adopt `jira-suite` without pulling all of ai-synapse. Changes to a submoduled skill are made in the skill's own repo; this repo only tracks the submodule pointer.

### Registration is intentional, not automatic

Skills land in ai-synapse only after review — via `/skill-creator` or `/improve-skill` — with an `EVAL.md`, via a PR that adds the submodule (or local directory) and a `SKILLS_REGISTRY.yaml` entry. Standalone repos are where free iteration happens; ai-synapse is where you promote to. Anything in this repo is trusted quality.

### Framework tools

Three root-level symlinks point at skills for working **on the framework itself**, not skills in the library. They are aliased at the root for quick access:

| Tool | Path | Description |
|------|------|-------------|
| `/skill-creator` | [`src/skill/skill-creator/`](src/skill/skill-creator/) | Full pipeline for creating a new skill — baseline test, design principles check, eval generation, improvement loop. Produces a PR-ready skill with `EVAL.md` and a `SKILLS_REGISTRY.yaml` entry. |
| `/improve-skill` | [`src/skill/improve-skill/`](src/skill/improve-skill/) | Score-fix-rescore loop against an existing `EVAL.md` until quality criteria are met. |
| `/auto-research` | [`src/optimization/auto-research/`](src/optimization/auto-research/) | Autonomous modify-measure-keep loop for skills, code, prompts, or any measurable target. |

### Two-layer validation

Every commit touching a skill directory runs two layers of checks:

1. **Pre-commit (structural)** — frontmatter fields, taxonomy values, domain README entry, EVAL.md presence. Fast, no LLM.
2. **PR-time (quality)** — new skills run `/skill-creator`; modified skills run `/improve-skill`. Trivial changes (typos, formatting) need only layer 1.

---

## Quick Start

```bash
git clone https://github.com/JuanSync7/ai-synapse.git
cd ai-synapse
make init            # configure git hooks + initialize submodules (first-time only)
make install         # install all skills to ~/.claude/skills/
```

---

## Install

`install.sh` is the full CLI. `make` provides shortcuts for the common cases.

```bash
make install                       # install all skills
make install docs                  # install src/docs domain only
make install docs code             # install multiple domains
make install meta/skill-creator    # install a single skill
make list                          # show installed skills
make available                     # show all available skills
make clean                         # remove all installed symlinks
```

`make` with no args prints a help message. Discovery is automatic — any directory under `src/` containing a `SKILL.md` is a valid install target. No config needed when adding new skills or domains.

Install target: `$CLAUDE_SKILLS_DIR` (default: `~/.claude/skills/`).

### Claude Desktop (ZIP packaging)

For team members using Claude Desktop instead of Claude Code CLI, skills can be packaged as `.zip` files and uploaded via Claude Desktop's skill upload:

```bash
# Mac / Linux
make zip                           # package all skills
make zip docs/patch-docs           # package one skill

# Windows (PowerShell)
.\zip-skills.ps1                   # package all skills
.\zip-skills.ps1 patch-docs       # package one skill
```

Zips are output to `dist/` (gitignored). Each skill gets its own `.zip` containing only execution files — EVAL.md and research artifacts are excluded.

→ See **[src/README.md](src/README.md)** for the full skill catalog with per-domain tables.

---

<p align="center">
  <sub>Built with Claude Code</sub>
</p>
