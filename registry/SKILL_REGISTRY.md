# Skills Registry

Full inventory of all skills. Before creating a new skill, check if one already covers the capability you need. Pipeline-routable skills are also registered in `synapse/SKILLS_REGISTRY.yaml` with their stage metadata.

| Skill | Description | Domain | Pipeline Stage | Status |
|-------|-------------|--------|----------------|--------|
| [synapse-creator](../synapse/skills/synapse-creator/SKILL.md) | Router-based unified creator for new skills, protocols, agents, or tools — type-specific flows load on demand | synapse | — | stable |
| [synapse-brainstorm](../synapse/skills/synapse-brainstorm/SKILL.md) | Generalized brainstorm for any artifact type — coaching, pressure-testing, N memos | synapse | — | draft |
| [write-synapse-eval](../synapse/skills/write-synapse-eval/SKILL.md) | Router-based unified EVAL.md generator for skills, protocols, agents, and tools — type-specific flows load on demand | synapse | — | draft |
| [synapse-gatekeeper](../synapse/skills/synapse-gatekeeper/SKILL.md) | Certifies skill promotion readiness (APPROVE/REVISE/REJECT) against governance criteria | synapse | — | draft |
| [synapse-external-validator](../synapse/skills/synapse-external-validator/SKILL.md) | Suite-level structural conformance sweep — validates all artifacts in an external submodule before it is wired into ai-synapse | synapse | — | draft |
| [improve-skill](../synapse/skills/improve-skill/SKILL.md) | Karpathy-style score-fix-rescore loop for skill quality | synapse | — | draft |
