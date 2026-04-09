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

A **central library** for [Claude Code](https://claude.ai/code) skills — standalone skills and submoduled skill suites, organized by domain, installed as symlinks into `~/.claude/skills/`.

Skills range from single-file utilities to full autonomous pipelines that chain scope -> spec -> design -> implementation -> engineering guide -> test docs -> test code, with multi-agent orchestration at every stage.

## Quick Start

```bash
git clone https://github.com/JuanSync7/ai-synapse.git
cd ai-synapse
make init                                    # configure git hooks
./install.sh install all                     # install all skills
./install.sh install docs code/build-plan    # or pick specific domains/skills
```

## Skills

### docs — Document Authoring Pipeline

| Skill | Description |
|-------|-------------|
| `write-scope-docs` | Scope definition, phase planning, open questions tracking |
| `write-architecture-docs` | System-level architecture decisions, component boundaries |
| `write-spec-docs` | Full FR/NFR specification with acceptance criteria |
| `write-spec-summary` | Concise spec digest with tech-agnostic system overview |
| `write-design-docs` | Task decomposition, code contracts, dependency graph |
| `write-implementation-docs` | Implementation source-of-truth with Phase 0 contracts |
| `write-engineering-guide` | Post-build module reference and data flow documentation |
| `write-test-docs` | Test planning document derived from engineering guide |
| `doc-authoring` | Router — detects doc intent and dispatches to the right skill |

### code — Code Generation & Testing

| Skill | Description |
|-------|-------------|
| `build-plan` | Implementation planning with dependency graph |
| `write-module-tests` | pytest implementation from test doc specifications |
| `test-runner` | Automated test execution and failure analysis |

### orchestration — Multi-Agent Coordination

| Skill | Description |
|-------|-------------|
| `autonomous-orchestrator` | End-to-end pipeline execution with review gates |
| `parallel-agents-dispatch` | Fan-out/fan-in agent coordination |
| `stakeholder-reviewer` | Human-in-the-loop review gate |

### meta — Skill Development

| Skill | Description |
|-------|-------------|
| `skill-creator` | Create new skills with eval criteria |
| `improve-skill` | Score-fix loop against EVAL.md |
| `write-skill-eval` | Generate EVAL.md for a skill |
| `skill-router` | Route user intent to the right skill |
| `generate-test-prompts` | Generate behavioral test prompts |
| `generate-output-criteria` | Generate output quality criteria |

### optimization — Research & Improvement

| Skill | Description |
|-------|-------------|
| `auto-research` | Karpathy-style modify-measure-keep loop |

### frameworks — Technology-Specific

| Skill | Description |
|-------|-------------|
| `langgraph-architect` | LangGraph application architecture |

### creative — Visual & Interactive

| Skill | Description |
|-------|-------------|
| `create-animation-page` | Animated HTML/CSS/JS pages |

### integration — External Services

| Skill | Description |
|-------|-------------|
| `jira-reporter` | Jira issue reporting and management |

---

## The Doc Pipeline

```
write-scope-docs -> write-architecture-docs -> write-spec-docs -> write-spec-summary
                                                     |
                                               write-design-docs
                                                     |
                                           write-implementation-docs
                                                     |
                                              implement-code
                                                     |
                                           write-engineering-guide
                                                     |
                                              write-test-docs
                                                     |
                                            write-module-tests
```

Each stage produces a document that the next stage consumes. The `autonomous-orchestrator` can drive this end-to-end with stakeholder review gates between stages.

## Architecture

```
<domain>/
  <skill-name>/
    SKILL.md                # Skill definition (frontmatter + body)
    EVAL.md                 # Test prompts + output criteria
    references/             # Companion files loaded on-demand
    templates/              # Output templates
```

**Two kinds of skills:**
- **Standalone** — self-contained SKILL.md + EVAL.md, no shared infra. Live directly in this repo.
- **Submoduled suites** — multi-skill projects with shared config and CI. Live in their own repos, wired in as git submodules.

**Root files:**
- `SKILLS_REGISTRY.yaml` — pipeline metadata and stage dependencies
- `TAXONOMY.md` — controlled vocabulary for `domain` and `intent` fields
- `GOVERNANCE.md` — cross-skill rules for the doc-authoring suite
- `install.sh` — CLI for installing/managing skill symlinks

## CLI

```bash
./install.sh install all                  # install everything
./install.sh install docs code/build-plan # install specific domains or skills
./install.sh list                         # show installed skills
./install.sh available                    # show all available skills
./install.sh clean                        # remove all symlinks
```

Target directory: `$CLAUDE_SKILLS_DIR` (default: `~/.claude/skills/`).

---

<p align="center">
  <sub>Built with Claude Code</sub>
</p>
