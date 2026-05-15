# Agent Checklist

Loaded by synapse-router-artifact-gatekeeper when the artifact path points to `src/agents/<domain>/<agent>.md`. Agents have two tiers — no registry tier (agents are not in SKILLS_REGISTRY.yaml).

---

## Tier 1 — Structural

| Check | Pass condition |
|-------|---------------|
| Agent file exists | `.md` file is present in `src/agents/<domain>/` and non-empty |
| Frontmatter complete | `name`, `description`, `domain`, `subdomain`, `scope`, `role` all present |
| `domain` in AGENT_VOCABULARY.md | Value matches a row in the `## Domains` section of `registry/AGENT_VOCABULARY.md` |
| `subdomain` in AGENT_VOCABULARY.md | Value matches a row in the `## Subdomains` section of `registry/AGENT_VOCABULARY.md` |
| `scope` in AGENT_VOCABULARY.md | Value matches a row in the `## Scopes` section of `registry/AGENT_VOCABULARY.md` |
| `role` in AGENT_VOCABULARY.md | Value matches a row in the `## Roles` section of `registry/AGENT_VOCABULARY.md` |
| `tags` well-formed | Array of lowercase hyphenated strings |
| Name follows convention | `<domain>-<concern>-<role>` pattern (e.g., `synapse-skill-eval-judge`) |
| Name globally unique | No collision in AGENTS_REGISTRY.md |
| Listed in AGENTS_REGISTRY.md | Row exists with correct description and consumer list |
| Domain README has row | Domain `README.md` contains a row linking this agent |

---

## Tier 2 — Quality

| Check | Pass condition |
|-------|---------------|
| Clear persona | Opening paragraph describes the agent's role and mindset |
| Instructions trace to failure modes | Each instruction implies "without this, the agent does X which causes Y" |
| Under 300 lines | Line count ≤ 300 |
| Consumer skills identified | At least one skill is named that dispatches this agent |
| No user-facing language | No slash commands, no "the user can...", no interactive prompts — agents are never user-invocable |

---

## Verdict Rules

| Condition | Verdict |
|-----------|---------|
| Both tiers pass | APPROVE |
| Fixable gaps (missing registry entry, name convention violation, consumer not identified) | REVISE |
| Frontmatter absent, or any of domain/subdomain/scope/role not in AGENT_VOCABULARY.md | REJECT |
