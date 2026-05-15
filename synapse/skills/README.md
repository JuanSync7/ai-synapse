# synapse/skills

Framework skills — the meta-tools used to build, evaluate, and govern artifacts. All skills live flat at this level (no per-type subdirs).

| Skill | Role | Description |
|-------|------|-------------|
| [synapse-router-artifact-creator](synapse-router-artifact-creator/) | creator | Router-based unified creator for new skills, protocols, agents, or tools — type-specific flows load on demand |
| [synapse-router-artifact-brainstormer](synapse-router-artifact-brainstormer/) | brainstormer | Generalized brainstorm for any artifact type — coaching, pressure-testing, N memos |
| [synapse-router-eval-writer](synapse-router-eval-writer/) | writer | Router-based unified EVAL.md generator for skills, protocols, agents, and tools |
| [synapse-router-artifact-gatekeeper](synapse-router-artifact-gatekeeper/) | gatekeeper | Certifies artifact promotion readiness (APPROVE/REVISE/REJECT) against governance criteria |
| [synapse-router-suite-validator](synapse-router-suite-validator/) | validator | Suite-level structural sweep — validates every artifact in an external submodule before it is wired into ai-synapse |
| [synapse-skill-skill-improver](synapse-skill-skill-improver/) | improver | Karpathy-style score-fix-rescore loop for skill quality |
