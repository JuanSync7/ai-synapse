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

The repo serves two roles: a **home for standalone skills** (self-contained, no shared infrastructure) and a **registry that submodules skill suites** from external repos (multi-skill projects with shared config and their own CI). Both are installed the same way via `scripts/install.sh`.

### End-to-End Skill Development

AI-Synapse includes a complete lifecycle for building skills themselves — from initial idea to production-ready, certified skill:

| Stage | Skill | What it does |
|-------|-------|-------------|
| **Brainstorm** | [`/skill-brainstorm`](src/skills/skill/skill-brainstorm/) | Coaching session to shape a vague idea into a concrete skill spec — decides if it's a skill, config, or not needed |
| **Create** | [`/skill-creator`](src/skills/skill/skill-creator/) | Scaffolds SKILL.md + EVAL.md with baseline testing and design principles check |
| **Evaluate** | [`/write-skill-eval`](src/skills/skill/write-skill-eval/) | Generates or regenerates EVAL.md with output criteria and test prompts |
| **Improve** | [`/improve-skill`](src/skills/skill/improve-skill/) | Score-fix-rescore loop until quality criteria are met |
| **Research** | [`/auto-research`](src/skills/optimization/auto-research/) | Autonomous modify-measure-keep loop for any measurable target |
| **Certify** | [`/synapse-gatekeeper`](src/skills/skill/synapse-gatekeeper/) | Promotion gate — APPROVE / REVISE / REJECT verdict against governance criteria |

The flow is: **brainstorm → create → improve → certify → PR**. Each stage is optional — jump in wherever your skill is.

---

## Repository Structure

```
ai-synapse/
│
├── src/
│   ├── skills/
│   │   └── <domain>/               # Skills organized by domain (docs, code, orchestration, etc.)
│   │       └── <skill-name>/       # Each skill: SKILL.md + EVAL.md + companions
│   ├── agents/                     # Internal recipes dispatched by skills (not user-invocable)
│   ├── protocols/                  # Shared conventions/schemas (e.g., execution traces)
│   └── SKILLS_REGISTRY.yaml        # Pipeline metadata and stage dependency graph
│
├── AGENTS_REGISTRY.md              # Agent discovery table
├── SKILL_TAXONOMY.md               # Controlled vocabulary for skill domain/intent fields
├── AGENT_TAXONOMY.md               # Controlled vocabulary for agent domain/role fields
├── PROTOCOL_TAXONOMY.md            # Controlled vocabulary for protocol domain/type fields
├── GOVERNANCE.md                   # Promotion criteria, contribution workflow
├── CLAUDE.md                       # Claude Code instructions for this repo
├── scripts/
│   ├── install.sh                  # CLI for installing and managing skill/agent symlinks
│   └── zip-skills.ps1              # PowerShell ZIP packaging for Claude Desktop (Windows)
├── Makefile                        # Setup shortcuts (init, install, list, clean)
└── .githooks/pre-commit            # Structural validation on every commit
```

---

## Key Files

### [`src/SKILLS_REGISTRY.yaml`](src/SKILLS_REGISTRY.yaml)
The single source of truth for pipeline metadata. Every skill that participates in an automated pipeline is registered here with its `stage_name`, `input_type`, `output_type`, `context_type`, and dependency chain (`requires_all` / `requires_any`). The `autonomous-orchestrator` reads this file to resolve stage order, validate type compatibility, and drive end-to-end pipelines. Named presets (`full`, `feature`, `bugfix`, `docs-only`) are defined here as trusted stage sequences that bypass dependency resolution.

### [`AGENTS_REGISTRY.md`](AGENTS_REGISTRY.md)
Discovery table for agent definitions — internal recipes dispatched by skills, not user-invocable. Skills declare agent dependencies via symlinks in their `agents/` folder pointing to `src/agents/`. Check this registry before creating a new agent to see if one already covers the capability you need.

### [`SKILL_TAXONOMY.md`](SKILL_TAXONOMY.md)
Controlled vocabulary for the `domain` and `intent` frontmatter fields in every `SKILL.md`. Enforced by the pre-commit hook — committing a skill with a value not listed here will fail. When nothing in the taxonomy fits a new skill, the convention is to propose an addition here rather than invent ad hoc values. This keeps skill metadata consistent and makes routing and filtering predictable.

### [`AGENT_TAXONOMY.md`](AGENT_TAXONOMY.md)
Controlled vocabulary for the `domain` and `role` fields in agent definitions. Agents follow the `<domain>-<concern>-<role>` naming convention. Enforced by the pre-commit hook when committing changes to `src/agents/`.

### [`PROTOCOL_TAXONOMY.md`](PROTOCOL_TAXONOMY.md)
Controlled vocabulary for the `domain` and `type` fields in protocol definitions. Enforced by the pre-commit hook when committing changes to `src/protocols/`.

### [`GOVERNANCE.md`](GOVERNANCE.md)
Authoritative rules for the doc-authoring skill suite — layer hierarchy, cross-skill coherence gates, and propagation rules for when specs change. Not loaded at runtime; it is the human-readable source from which rules are inlined into each doc skill's `SKILL.md`. When a rule changes, update `GOVERNANCE.md` first, then propagate to each affected skill. This separation keeps skills self-contained (no runtime file dependency) while providing a single place to reason about suite-level consistency.

### [`CLAUDE.md`](CLAUDE.md)
Project-level instructions for Claude Code. Explains the repo structure, submodule architecture, skill anatomy, and the two-layer validation model (pre-commit structural checks + PR-time quality evaluation). Claude reads this automatically when working in this repo. Changes here affect how Claude interprets tasks and structures contributions.

### [`.githooks/pre-commit`](.githooks/pre-commit)
Runs automatically on every commit touching a skill directory. Checks: required frontmatter fields present, `domain` and `intent` values exist in `SKILL_TAXONOMY.md`, the domain `README.md` has a row for the skill, and `EVAL.md` exists alongside every `SKILL.md`. Fails loudly with actionable errors. Activated via `make init`.

---

## Architecture

### Skill anatomy

Every skill lives at `src/skills/<domain>/<skill-name>/` and follows this layout:

```
src/skills/<domain>/<skill-name>/
  SKILL.md        # (required) YAML frontmatter + behavior body — the skill definition
  EVAL.md         # (required) Test prompts and pass/fail output criteria for quality evaluation
  references/     # Companion files loaded on-demand during specific phases
  templates/      # Output templates referenced by the skill
```

`SKILL.md` is the install discovery marker — `scripts/install.sh` walks `src/` looking for files with that name, so any directory without one is invisible to the installer. The file must exist; contents are not validated at install time (that happens at commit via the pre-commit hook). `EVAL.md` is also required by the pre-commit hook, which will reject a skill directory missing it. `references/` and `templates/` are optional.

`SKILL.md` frontmatter carries routing metadata:

```yaml
---
name: skill-name
description: "Trigger conditions — when this skill fires (not a workflow summary)"
domain: docs.spec       # from SKILL_TAXONOMY.md
intent: write           # from SKILL_TAXONOMY.md
tags: [lowercase, hyphenated]
user-invocable: true
argument-hint: "[args]"
---
```

The `description` field is a **routing contract**: it specifies when the skill fires, not what it does. Claude Code matches user intent against this field to select the right skill.

### Agents and protocols

Beyond skills, two supporting concepts live under `src/`:

- **Agent definitions** (`src/agents/`) — internal recipes dispatched by skills, not user-invocable. Skills declare agent dependencies via symlinks in their `agents/` folder. See [`AGENTS_REGISTRY.md`](AGENTS_REGISTRY.md) for discovery.
- **Protocols** (`src/protocols/`) — shared conventions and schemas injected into agent prompts by observers. The first protocol is the [execution trace](src/protocols/traces/execution-trace.md) — a self-reported observability format that skills like `improve-skill` inject when grading workflow behavior.

### Two kinds of skills

- **Standalone** — self-contained `SKILL.md` + `EVAL.md`, no shared infrastructure. Lives directly in this repo under `src/skills/<domain>/`.
- **Submoduled suites** — multi-skill projects with shared config and their own CI. Live in external repos, wired in as git submodules under `src/skills/<domain>/`. `scripts/install.sh` follows symlinks regardless of source — standalone and submoduled skills install identically. The `integration/jira-suite` is the current example.

Submoduled suites are portable: a team can adopt `jira-suite` without pulling all of ai-synapse. Changes to a submoduled skill are made in the skill's own repo; this repo only tracks the submodule pointer.

### Registration is intentional, not automatic

Skills land in ai-synapse only after review — via `/skill-creator` or `/improve-skill` — with an `EVAL.md`, via a PR that adds the submodule (or local directory) and a `src/SKILLS_REGISTRY.yaml` entry. Standalone repos are where free iteration happens; ai-synapse is where you promote to. Anything in this repo is trusted quality.

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

`scripts/install.sh` is the full CLI. `make` provides shortcuts for the common cases.

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
.\scripts\zip-skills.ps1                   # package all skills
.\scripts\zip-skills.ps1 patch-docs       # package one skill
```

Zips are output to `dist/` (gitignored). Each skill gets its own `.zip` containing only execution files — EVAL.md and research artifacts are excluded.

→ See **[src/README.md](src/README.md)** for the full skill catalog with per-domain tables.

---

<p align="center">
  <sub>Built with Claude Code</sub>
</p>
