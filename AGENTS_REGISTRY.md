# Agents Registry

Internal recipes dispatched by skills, not user-invocable. Before creating a new agent, check if one already covers the capability you need.

| Agent | Description | Consumers |
|-------|-------------|-----------|
| [skill-eval-judge](src/agents/skill-eval-judge.md) | Impartial judge — binary output quality criteria (EVAL-Oxx) from SKILL.md | skill-creator, write-skill-eval, improve-skill |
| [skill-eval-prompter](src/agents/skill-eval-prompter.md) | Blind test prompt generation across 4 personas | skill-creator, write-skill-eval |
| [skill-eval-auditor](src/agents/skill-eval-auditor.md) | Execution criteria for orchestration patterns (EVAL-Exx) | skill-creator, write-skill-eval |
