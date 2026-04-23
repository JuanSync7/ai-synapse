# Agents Registry

Internal recipes dispatched by skills, not user-invocable. Before creating a new agent, check if one already covers the capability you need.

| Agent | Description | Consumers |
|-------|-------------|-----------|
| [skill-eval-judge](src/agents/skill-eval/skill-eval-judge.md) | Impartial judge — binary output quality criteria (EVAL-Oxx) from SKILL.md | skill-creator, write-skill-eval, improve-skill |
| [skill-eval-prompter](src/agents/skill-eval/skill-eval-prompter.md) | Blind test prompt generation across 4 personas | skill-creator, write-skill-eval |
| [skill-eval-auditor](src/agents/skill-eval/skill-eval-auditor.md) | Execution criteria for orchestration patterns (EVAL-Exx) | skill-creator, write-skill-eval |
| [protocol-eval-reviewer](src/agents/protocol-eval/protocol-eval-reviewer.md) | Signal-strength reviewer for protocol instructions | protocol-creator, write-protocol-eval |
| [docs-spec-section-writer](src/agents/docs/docs-spec-section-writer.md) | Writes one spec section from a planner brief — requirement format, acceptance criteria, traceability | write-spec-docs |
| [docs-spec-section-reviewer](src/agents/docs/docs-spec-section-reviewer.md) | Three-way evaluator — brief alignment, section quality, deviation justification | write-spec-docs |
| [docs-spec-coherence-reviewer](src/agents/docs/docs-spec-coherence-reviewer.md) | Doc-level coherence review — alignment, flow, cross-references, traceability | write-spec-docs |
