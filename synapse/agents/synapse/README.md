# synapse

Agents in the `synapse` domain — ecosystem management, README maintenance, and subdomain agents for skill, skill-eval, and protocol authoring.

## Subdomains

| Subdomain | Description |
|-----------|-------------|
| [protocol/](protocol/) | Protocol authoring and review agents |
| [skill/](skill/) | Skill authoring agents — companion-file generation |
| [skill-eval/](skill-eval/) | Skill evaluation agents — judges, prompters, auditors |

## Agents

| Agent | Role | Description |
|-------|------|-------------|
| [synapse-readme-maintainer](synapse-readme-maintainer.md) | maintainer | Maintains README-index invariant for the ancestor path of a changed synapse — adds/updates/removes rows; rewrites top-of-file one-liner only on factual drift |
