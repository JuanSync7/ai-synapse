# Agents Registry

Internal recipes dispatched by skills, not user-invocable. Before creating a new agent, check if one already covers the capability you need.

| Agent | Description | Consumers |
|-------|-------------|-----------|
| [skill-eval-judge](synapse/agents/skill-eval/skill-eval-judge.md) | Impartial judge — binary output quality criteria (EVAL-Oxx) from SKILL.md | skill-creator, write-skill-eval, improve-skill |
| [skill-eval-prompter](synapse/agents/skill-eval/skill-eval-prompter.md) | Blind test prompt generation across 4 personas | skill-creator, write-skill-eval |
| [skill-eval-auditor](synapse/agents/skill-eval/skill-eval-auditor.md) | Execution criteria for orchestration patterns (EVAL-Exx) | skill-creator, write-skill-eval |
| [protocol-eval-reviewer](synapse/agents/protocol-eval/protocol-eval-reviewer.md) | Signal-strength reviewer for protocol instructions | protocol-creator, write-protocol-eval |
| [docs-spec-section-writer](src/agents/docs/docs-spec-section-writer.md) | Writes one spec section from a planner brief — requirement format, acceptance criteria, traceability | write-spec-docs |
| [docs-spec-section-reviewer](src/agents/docs/docs-spec-section-reviewer.md) | Three-way evaluator — brief alignment, section quality, deviation justification | write-spec-docs |
| [docs-spec-coherence-reviewer](src/agents/docs/docs-spec-coherence-reviewer.md) | Doc-level coherence review — alignment, flow, cross-references, traceability | write-spec-docs |
| [skill-companion-file-writer](synapse/agents/skill/skill-companion-file-writer.md) | Writes a single companion file (reference or template) for a skill | skill-creator, improve-skill |
| [docs-epic-writer](src/agents/docs/docs-epic-writer.md) | Writes epic.md cross-cutting deltas + vocab.md (declarative-only) | docs-write-story |
| [docs-fr-decomposer](src/agents/docs/docs-fr-decomposer.md) | Decomposes brainstorm memo into FR roster + per-FR atomic tmp context files | docs-write-story |
| [docs-story-writer](src/agents/docs/docs-story-writer.md) | Vertical-slice writer — story.md + design.md + impl.md + test.md for one FR from a single tmp file | docs-write-story |
| [docs-eng-guide-writer](src/agents/docs/docs-eng-guide-writer.md) | Regenerates engineering_guide.md from touches: union (stable skeleton, FR-free primary content) | docs-write-story |
| [docs-eng-guide-reviewer](src/agents/docs/docs-eng-guide-reviewer.md) | Drift-checks regenerated eng-guide vs prior — emits clean/reconcile/escalate verdict | docs-write-story |
