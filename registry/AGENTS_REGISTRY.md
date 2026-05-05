# Agents Registry

Internal recipes dispatched by skills, not user-invocable. Before creating a new agent, check if one already covers the capability you need.

| Agent | Description | Consumers |
|-------|-------------|-----------|
| [synapse-skill-eval-judge](synapse/agents/synapse/skill-eval/synapse-skill-eval-judge.md) | Impartial judge — binary output quality criteria (EVAL-Oxx) from SKILL.md | skill-creator, write-synapse-eval, improve-skill |
| [synapse-skill-eval-prompter](synapse/agents/synapse/skill-eval/synapse-skill-eval-prompter.md) | Blind test prompt generation across 4 personas | skill-creator, write-synapse-eval |
| [synapse-skill-eval-auditor](synapse/agents/synapse/skill-eval/synapse-skill-eval-auditor.md) | Execution criteria for orchestration patterns (EVAL-Exx) | skill-creator, write-synapse-eval |
| [synapse-protocol-signal-reviewer](synapse/agents/synapse/protocol/synapse-protocol-signal-reviewer.md) | Signal-strength reviewer for protocol instructions | protocol-creator, write-synapse-eval |
| [synapse-skill-companion-writer](synapse/agents/synapse/skill/synapse-skill-companion-writer.md) | Writes a single companion file (reference or template) for a skill | skill-creator, improve-skill |
| [synapse-readme-maintainer](synapse/agents/synapse/synapse-readme-maintainer.md) | Maintains README-index invariant for the ancestor path of a changed synapse — adds/updates/removes rows; rewrites top-of-file one-liner on factual drift | skill-creator, agent-creator, protocol-creator, improve-skill |
| [synapse-skill-anatomy-reviewer](synapse/agents/synapse/skill/synapse-skill-anatomy-reviewer.md) | Binary anatomy gate — checks SKILL.md structural anatomy against canonical spec before eval generation (status: draft) | synapse-skill-signal-reviewer, synapse-creator, improve-skill |
| [synapse-skill-companion-auditor](synapse/agents/synapse/skill/synapse-skill-companion-auditor.md) | Audits references/ and templates/ companion files — load triggers, no body duplication, size-fit-purpose, template concreteness, reference modularity. **Status: draft** | synapse-skill-signal-reviewer, improve-skill |
| [synapse-skill-design-judge](synapse/agents/synapse/skill/synapse-skill-design-judge.md) | Graded design-quality judge — scores a SKILL.md on six design-principle dimensions (1-5) and emits fix suggestions for dimensions below threshold (status: draft) | synapse-skill-signal-reviewer |
