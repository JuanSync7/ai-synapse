# synapse/skills

Framework skills — the meta-tools used to build, evaluate, and govern artifacts. All skills live flat at this level (no per-type subdirs).

| Skill | Intent | Description |
|-------|--------|-------------|
| [synapse-creator](synapse-creator/) | write | Router-based unified creator for new skills, protocols, agents, or tools — type-specific flows load on demand |
| [synapse-brainstorm](synapse-brainstorm/) | brainstorm | Generalized brainstorm for any artifact type — coaching, pressure-testing, N memos |
| [write-synapse-eval](write-synapse-eval/) | write | Router-based unified EVAL.md generator for skills, protocols, agents, and tools |
| [synapse-gatekeeper](synapse-gatekeeper/) | validate | Certifies artifact promotion readiness (APPROVE/REVISE/REJECT) against governance criteria |
| [synapse-external-validator](synapse-external-validator/) | validate | Suite-level structural sweep — validates every artifact in an external submodule before it is wired into ai-synapse |
| [improve-skill](improve-skill/) | improve | Karpathy-style score-fix-rescore loop for skill quality |
| [skill-router](skill-router/) | route | Routes user intent to the right skill based on domain matching |
| [autonomous-orchestrator](autonomous-orchestrator/) | orchestrate | Fully autonomous dev pipeline with stakeholder gates |
| [parallel-agents-dispatch](parallel-agents-dispatch/) | orchestrate | Execute implementation plan via parallel subagents |
| [stakeholder-reviewer](stakeholder-reviewer/) | validate | Evaluates decisions against stakeholder persona (APPROVE/REVISE/ESCALATE) |
