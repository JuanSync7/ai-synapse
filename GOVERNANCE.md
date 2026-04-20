# ai-synapse Governance

> `synapse-gatekeeper` loads this file when issuing promotion verdicts.

This document defines what belongs in ai-synapse, the criteria a skill must meet to land here, and the lifecycle for submoduled suites. It is the authoritative reference — not loaded at runtime by individual skills except where noted.

---

## What Belongs in ai-synapse

ai-synapse is a curated library, not a scratch pad. A skill belongs here when it meets all three conditions:

1. **Reusable across projects** — the skill is not tied to a single codebase, team, or context. It solves a category of problem, not a one-off task.
2. **Has a passing EVAL.md** — an EVAL.md exists, was generated or reviewed by `/write-skill-eval`, and the skill scores ≥ 80 against it.
3. **Not a duplicate** — no existing skill in the registry already covers the same intent at the same scope. A variation in phrasing is not enough — the use case must be genuinely distinct.

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
- [ ] `domain` value exists in `TAXONOMY.md`
- [ ] `intent` value exists in `TAXONOMY.md`
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
5. `install.sh` works unchanged — it follows symlinks regardless of submodule vs. local source.

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
2. Uninstall the symlink: `./install.sh clean` (or remove the specific symlink).
3. After one full release cycle with no active use:
   ```bash
   git submodule deinit src/skills/<domain>/<suite-name>
   git rm src/skills/<domain>/<suite-name>
   rm -rf .git/modules/src/skills/<domain>/<suite-name>
   git commit -m "chore: remove deprecated <suite-name> submodule"
   ```

---

## Naming Conventions

- **Globally unique** — skill names resolve from a flat `~/.claude/skills/` directory. No namespacing is possible at runtime.
- **Lowercase hyphenated** — `write-spec-docs`, not `WriteSpecDocs` or `write_spec_docs`.
- **Domain-prefixed when collision risk** — if the skill name is generic (e.g., `reporter`, `planner`), prefix with the domain (`jira-reporter`, `jira-planner`).
- `install.sh` warns on name collisions at install time. Never rely on last-write-wins to resolve a collision — rename the skill before promoting.
