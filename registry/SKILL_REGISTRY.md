# Skills Registry

Full inventory of all skills. Before creating a new skill, check if one already covers the capability you need. Pipeline-routable skills are also registered in `synapse/SKILLS_REGISTRY.yaml` with their stage metadata.

| Skill | Description | Domain | Pipeline Stage | Status |
|-------|-------------|--------|----------------|--------|
| [parallel-agents-dispatch](../synapse/skills/orchestration/parallel-agents-dispatch/SKILL.md) | Execute implementation plan via parallel subagents | orchestration | `code` | draft |
| [skill-brainstorm](../synapse/skills/skill/skill-brainstorm/SKILL.md) | **Deprecated** — superseded by synapse-brainstorm | skill | — | deprecated |
| [synapse-brainstorm](../synapse/skills/skill/synapse-brainstorm/SKILL.md) | Generalized brainstorm for any artifact type — coaching, pressure-testing, N memos | skill | — | draft |
| [skill-creator](../synapse/skills/skill/skill-creator/SKILL.md) | Creates new skills with EVAL.md and registry entry | skill | — | draft |
| [improve-skill](../synapse/skills/skill/improve-skill/SKILL.md) | Karpathy-style score-fix-rescore loop for skill quality | skill | — | draft |
| [write-skill-eval](../synapse/skills/skill/write-skill-eval/SKILL.md) | Generates EVAL.md with output criteria and test prompts | skill | — | draft |
| [write-synapse-eval](../synapse/skills/skill/write-synapse-eval/SKILL.md) | Router-based unified EVAL.md generator for skills, protocols, agents, and tools — type-specific flows load on demand | skill | — | stable |
| [synapse-gatekeeper](../synapse/skills/skill/synapse-gatekeeper/SKILL.md) | Certifies skill promotion readiness (APPROVE/REVISE/REJECT) against governance criteria | skill | — | draft |
| [agent-creator](../synapse/skills/agent/agent-creator/SKILL.md) | Creates new agent definitions with frontmatter and taxonomy alignment | agent | — | draft |
| [write-agent-eval](../synapse/skills/agent/write-agent-eval/SKILL.md) | Generates evaluation criteria for agent definitions | agent | — | draft |
| [protocol-creator](../synapse/skills/protocol/protocol-creator/SKILL.md) | Creates new protocol definitions with frontmatter and taxonomy alignment | protocol | — | draft |
| [write-protocol-eval](../synapse/skills/protocol/write-protocol-eval/SKILL.md) | Generates conformance testing criteria for protocol definitions | protocol | — | draft |
| [skill-router](../synapse/skills/meta/skill-router/SKILL.md) | Routes user intent to the right skill based on domain matching | meta | — | draft |
| [autonomous-orchestrator](../synapse/skills/orchestration/autonomous-orchestrator/SKILL.md) | Fully autonomous dev pipeline with stakeholder gates | orchestration | — | draft |
| [stakeholder-reviewer](../synapse/skills/orchestration/stakeholder-reviewer/SKILL.md) | Evaluates decisions against stakeholder persona (APPROVE/REVISE/ESCALATE) | orchestration | — | draft |
| [synapse-creator](../synapse/skills/synapse/synapse-creator/SKILL.md) | Router-based unified creator for new skills, protocols, agents, or tools — type-specific flows load on demand | synapse | — | stable |
