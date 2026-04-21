# ai-synapse Governance

> `synapse-gatekeeper` loads this file when issuing promotion verdicts.

This document defines what belongs in ai-synapse, the criteria a skill must meet to land here, and the lifecycle for submoduled suites. It is the authoritative reference — not loaded at runtime by individual skills except where noted.

---

## What Belongs in ai-synapse

ai-synapse is a curated library, not a scratch pad. A skill belongs here when it meets all three conditions:

1. **Reusable across projects** — the skill is not tied to a single codebase, team, or context. It solves a category of problem, not a one-off task.
2. **Has a passing EVAL.md** — an EVAL.md exists, was generated or reviewed by `/write-skill-eval`, and the skill scores ≥ 80 against it.
3. **Not a duplicate** — no existing skill in the registry already covers the same intent at the same scope. A variation in phrasing is not enough — the use case must be genuinely distinct.

### Agent Definitions

Agent definitions (`src/agents/`) are internal recipes dispatched by skills — never user-invocable. They follow the same governance rigor as skills, adapted for their role:

- **YAML frontmatter required** — `name`, `description`, `domain`, `role`, and `tags` fields, with `domain` and `role` values from `AGENT_TAXONOMY.md`
- **Gatekeeper review required** — agents land via promotion PRs reviewed by `/synapse-gatekeeper`, same as skills
- **No standalone EVAL.md** — agents are tested indirectly through the skills that dispatch them. A standalone eval format will be defined when `write-agent-eval` is built (currently a draft stub)
- **Listed in AGENTS_REGISTRY.md** — for discovery, not `SKILLS_REGISTRY.yaml`
- **Installed separately** — `scripts/install.sh agents` symlinks them to `~/.claude/agents/`

An agent belongs in `src/agents/` when it is dispatched by 1+ skills and encapsulates a distinct persona or capability (e.g., impartial judge, blind prompt author). If only one skill uses it and it's short, inline it in the skill instead.

### Protocol Definitions

Protocols (`src/protocols/`) are shared conventions and schemas injected into agents by observers — never executed directly. They define structured formats for inter-agent communication and observability.

- **YAML frontmatter required** — `name`, `description`, `domain`, `type`, and `tags` fields, with `domain` and `type` values from `PROTOCOL_TAXONOMY.md`
- **Gatekeeper review required** — protocols land via promotion PRs reviewed by `/synapse-gatekeeper`
- **No standalone EVAL.md** — protocols are evaluated via conformance testing (dispatch an agent with the protocol injected, check if output conforms to the schema). A standalone eval format will be defined when `write-protocol-eval` is built (currently a draft stub)
- **Zero-overhead design** — a protocol must have no cost when not injected. It is always externally injected by an observer, never self-loaded by the agent

A protocol belongs in `src/protocols/` when it defines a reusable convention that 2+ agents or observers need to agree on (e.g., execution trace format, inter-agent message schema).

### Draft Skills

Skills may land on `main` as **drafts** — functional but not yet gatekeeper-certified. A draft skill:

- Has a `SKILL.md` and `EVAL.md` (pre-commit hook enforced)
- Passes structural checks (Tier 1)
- Has **not** been certified by `/synapse-gatekeeper` (Tiers 2-3 pending)

Draft skills are usable but carry no quality guarantee. To track draft status, the skill's entry in `SKILLS_REGISTRY.yaml` should include `status: draft`. A skill without a `status` field is assumed certified.

**Promoting a draft:** Run `/improve-skill` until eval score ≥ 80, then `/synapse-gatekeeper`. Update `status: certified` (or remove the field) in the registry entry.

### Standalone vs. Submodule

| Type | Description | Lives in |
|------|-------------|----------|
| Standalone | One SKILL.md + EVAL.md, no shared config, no multi-skill coordination | Directly in `src/skills/<domain>/<skill-name>/` |
| Submodule suite | Multiple related skills with shared templates, config, or CI | Own repo, wired in as a git submodule |

**Keep standalone** when the skill has no infrastructure dependencies and doesn't need its own CI.

**Extract to a submodule** when the skill is part of a suite with shared infrastructure, needs its own release cycle, or is meant to be adopted independently by other teams.

---

## Promotion Criteria

A skill must clear three tiers to be approved for merge.

### Tier 1 — Structural

Checked automatically by the pre-commit hook. No LLM required.

- [ ] `SKILL.md` exists in the skill directory
- [ ] `EVAL.md` exists alongside `SKILL.md` (**REJECT if absent**)
- [ ] Frontmatter is complete: `name`, `description`, `domain`, `intent` all present
- [ ] `domain` value exists in `SKILL_TAXONOMY.md`
- [ ] `intent` value exists in `SKILL_TAXONOMY.md`
- [ ] `tags` is a well-formed array of lowercase hyphenated strings
- [ ] `user-invocable` field is present
- [ ] `argument-hint` is present when `user-invocable: true`
- [ ] Domain `README.md` has a row for this skill
- [ ] Skill name is globally unique (no collision in `src/SKILLS_REGISTRY.yaml` or `~/.claude/skills/`)

### Tier 2 — Quality

Evaluated by `synapse-gatekeeper` against skill design principles.

- [ ] `description` is a routing contract — specifies *when* the skill fires, not what it does
- [ ] Eval score ≥ 80 (must be provided; unverified score blocks APPROVE)
- [ ] `SKILL.md` is under 500 lines
- [ ] Every instruction traces to a failure mode (no instruction without "without this, the agent does X")
- [ ] Wrong-Tool Detection section is present (redirects to sibling skills on misfire)
- [ ] `references/` is used correctly — companion files load at specific decision points, not inlined wholesale

### Tier 3 — Registry

- [ ] Pipeline-routable skills have a `pipeline:` block in `src/SKILLS_REGISTRY.yaml` with `stage_name`, `input_type`, `output_type`, `context_type`, and `requires_all`/`requires_any`
- [ ] Non-pipeline-routable skills are listed in the registry for inventory (no `pipeline:` block, with a comment explaining why)
- [ ] If registered: `stage_name` is unique across the registry
- [ ] If registered: `requires_all`/`requires_any` entries resolve to real stage names

### Agent Promotion

Agents clear two tiers. Evaluated by `synapse-gatekeeper` using `references/agent-checklist.md`.

#### Tier 1 — Structural

- [ ] Agent `.md` file exists in `src/agents/` and is non-empty
- [ ] Frontmatter complete: `name`, `description`, `domain`, `role` all present
- [ ] `domain` value exists in `AGENT_TAXONOMY.md`
- [ ] `role` value exists in `AGENT_TAXONOMY.md`
- [ ] `tags` is a well-formed array of lowercase hyphenated strings
- [ ] Name follows `<domain>-<concern>-<role>` convention
- [ ] Name is globally unique (no collision in `AGENTS_REGISTRY.md`)
- [ ] Listed in `AGENTS_REGISTRY.md` with correct description and consumer list

#### Tier 2 — Quality

- [ ] Clear persona/role description in the opening paragraph
- [ ] Every instruction traces to a failure mode
- [ ] Under 300 lines
- [ ] Consumer skills identified (which skills dispatch this agent)
- [ ] No user-facing language (agents are never user-invocable)

### Protocol Promotion

Protocols clear two tiers. Evaluated by `synapse-gatekeeper` using `references/protocol-checklist.md`.

#### Tier 1 — Structural

- [ ] Protocol `.md` file exists in `src/protocols/` and is non-empty
- [ ] Frontmatter complete: `name`, `description`, `domain`, `type` all present
- [ ] `domain` value exists in `PROTOCOL_TAXONOMY.md`
- [ ] `type` value exists in `PROTOCOL_TAXONOMY.md`
- [ ] `tags` is a well-formed array of lowercase hyphenated strings
- [ ] Schema block present (YAML or JSON — machine-parseable, not prose)
- [ ] Injection instructions present (how an observer injects the protocol)

#### Tier 2 — Conformance

- [ ] Schema is machine-parseable (can be validated programmatically)
- [ ] Injection instructions are self-contained (observer can inject without modification)
- [ ] At least one filled-in example of the protocol's output
- [ ] Zero-overhead design confirmed (no cost when not injected)

---

## REVISE vs. REJECT

**REVISE** — fixable gaps. The skill's foundation is sound; specific items need correction before merge.

Examples:
- Missing registry entry (skill is pipeline-routable but has no `pipeline:` block)
- Eval score below 80 (run `/improve-skill` to raise it)
- `description` reads as a workflow summary instead of a routing trigger
- Domain `README.md` is missing the skill's row
- `argument-hint` absent despite `user-invocable: true`
- `references/` inlined rather than loaded progressively

**REJECT** — fundamental problem. The skill cannot be promoted in its current form; the issue is not a gap to fill but a structural disqualifier.

Examples:
- `EVAL.md` is missing (no certification is possible without it)
- Name collision with an existing skill in the registry or `~/.claude/skills/`
- Skill duplicates an existing skill's use case (not a distinct intent)
- Skill has significant shared infrastructure that should be in its own repo (should be a submodule, not standalone)

**Agent-specific:**
- REVISE: missing AGENTS_REGISTRY.md entry, name doesn't follow convention, consumer skills not identified
- REJECT: frontmatter absent, domain/role not in AGENT_TAXONOMY.md

**Protocol-specific:**
- REVISE: missing example, injection instructions unclear, zero-overhead not confirmed
- REJECT: frontmatter absent, domain/type not in PROTOCOL_TAXONOMY.md, no schema block

---

## Contribution Workflow

1. **Build** — use `/skill-creator` to scaffold the skill, or author it manually.
2. **Improve** — run `/improve-skill` until the eval score reaches ≥ 80.
3. **Certify** — run `/synapse-gatekeeper <skill-path> --score <score>`. Resolve any REVISE gaps.
4. **PR** — open a pull request with the APPROVE verdict pasted into the description. The pre-commit hook enforces structural checks; the GitHub Action enforces quality checks.

A PR without an APPROVE verdict in the description will not be merged.

---

## Submodule Lifecycle

### Adding a submodule suite

1. Create the external repo with the skill(s), shared config, and CI.
2. Add it as a git submodule in this repo:
   ```bash
   git submodule add <repo-url> src/skills/<domain>/<suite-name>
   ```
3. Run `make init` to configure git hooks.
4. Register the skill(s) in `src/SKILLS_REGISTRY.yaml` and the domain `README.md`.
5. `scripts/install.sh` works unchanged — it follows symlinks regardless of submodule vs. local source.

### Updating a submodule

Changes to a submoduled skill must land in the external repo first. Then update the pointer here:

```bash
git submodule update --remote src/skills/<domain>/<suite-name>
git add src/skills/<domain>/<suite-name>
git commit -m "chore: update <suite-name> submodule pointer"
```

Never edit submoduled skill files directly in this repo — the changes will be lost on the next update.

### Removing a submodule

1. Add a `# DEPRECATED:` comment to the skill's entry in `src/SKILLS_REGISTRY.yaml` and `README.md`.
2. Uninstall the symlink: `./scripts/install.sh clean` (or remove the specific symlink).
3. After one full release cycle with no active use:
   ```bash
   git submodule deinit src/skills/<domain>/<suite-name>
   git rm src/skills/<domain>/<suite-name>
   rm -rf .git/modules/src/skills/<domain>/<suite-name>
   git commit -m "chore: remove deprecated <suite-name> submodule"
   ```

---

## Change Requests

When brainstorming or improving a skill reveals that another skill, agent, or protocol needs updating, drop a change request file in the affected target's `change_requests/` folder rather than expanding scope.

- **One file per change**, named `YYYY-MM-DD-short-description.md`
- **Content:** what needs to change, why, and which brainstorm/skill triggered it. Free-form markdown — no enforced template.
- **Consumed by** `/skill-brainstorm` — it checks for `change_requests/` on entry and incorporates pending requests as context.
- **Deleted** after the change is implemented. An empty folder means no pending obligations.

---

## Naming Conventions

- **Globally unique** — skill names resolve from a flat `~/.claude/skills/` directory. No namespacing is possible at runtime.
- **Lowercase hyphenated** — `write-spec-docs`, not `WriteSpecDocs` or `write_spec_docs`.
- **Domain-prefixed when collision risk** — if the skill name is generic (e.g., `reporter`, `planner`), prefix with the domain (`jira-reporter`, `jira-planner`).
- `scripts/install.sh` warns on name collisions at install time. Never rely on last-write-wins to resolve a collision — rename the skill before promoting.

### Agent naming

- **`<domain>-<concern>-<role>`** — e.g., `skill-eval-judge`, `skill-eval-prompter`, `skill-eval-auditor`
- The domain prefix clusters related agents (all `skill-eval-*` sort together)
- The role noun communicates what the agent *is*, not what it produces (prefer `judge` over `generate-criteria`)

### Protocol naming

- **`<descriptive-name>`** — e.g., `execution-trace`, `agent-message-schema`
- Protocols live in subdirectories of `src/protocols/` organized by concern (e.g., `traces/`, `schemas/`)
- The directory name groups related protocols; the file name identifies the specific protocol
