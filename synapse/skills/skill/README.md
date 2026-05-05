# skill

End-to-end skill development lifecycle — brainstorm, create, evaluate, improve, and certify Claude Code skills.

## Skills

| Skill | Intent | Description |
|-------|--------|-------------|
| [skill-brainstorm](skill-brainstorm/) | plan | **Deprecated** — superseded by synapse-brainstorm |
| [synapse-brainstorm](synapse-brainstorm/) | plan | Generalized brainstorm for any artifact type with multi-artifact output |
| [skill-creator](skill-creator/) | write | Scaffolds new skills with SKILL.md and EVAL.md |
| [improve-skill](improve-skill/) | improve | Score-fix-rescore loop to improve skill quality |
| [write-skill-eval](write-skill-eval/) | route | **Deprecated** — superseded by `/write-synapse-eval skill <path>` (same agent dispatch + assembly under the unified router) |
| [write-synapse-eval](write-synapse-eval/) | write | Router-based unified EVAL.md generator for skills, protocols, agents, and tools |
| [synapse-gatekeeper](synapse-gatekeeper/) | validate | Certifies promotion readiness — APPROVE / REVISE / REJECT verdict against governance criteria |

> Skill evaluation logic — `skill-eval-judge`, `skill-eval-prompter`, `skill-eval-auditor` — lives as agents under [`synapse/agents/skill-eval/`](../../agents/skill-eval/), dispatched by `skill-creator`, `write-synapse-eval` (skill flow), and `improve-skill`.
