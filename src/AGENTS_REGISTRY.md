# Agents Registry

Internal recipes dispatched by skills, not user-invocable. Before creating a new agent, check if one already covers the capability you need.

| Agent | Description | Consumers |
|-------|-------------|-----------|
| [generate-output-criteria](src/agents/generate-output-criteria.md) | Impartial judge — binary output quality criteria (EVAL-Oxx) from SKILL.md | skill-creator, write-skill-eval, improve-skill |
| [generate-test-prompts](src/agents/generate-test-prompts.md) | Blind test prompt generation across 4 personas | skill-creator, write-skill-eval |
| [generate-execution-criteria](src/agents/generate-execution-criteria.md) | Execution criteria for orchestration patterns (EVAL-Exx) | skill-creator, write-skill-eval |
