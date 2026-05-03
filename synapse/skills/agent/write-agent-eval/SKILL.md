---
name: write-agent-eval
description: "Use when asked to generate evaluation criteria for an agent definition, or to create an EVAL.md for an agent."
domain: synapse
intent: generate
tags: [agent, eval, quality-assessment]
user-invocable: true
argument-hint: "<agent-path>"
---

# Write Agent Eval

> **Status: Draft stub.** This skill will be built when 5+ agents exist in `src/agents/`. See GOVERNANCE.md for agent promotion criteria.

Generates evaluation criteria for agent definitions. Agents are tested indirectly through the skills that dispatch them — this skill defines what "good" looks like for the agent itself.

## Wrong-Tool Detection

- **User wants to evaluate a skill** → redirect to `/write-skill-eval`
- **User wants to evaluate a protocol** → redirect to `/write-protocol-eval`
- **User wants to improve an agent** → redirect to `/improve-skill` (adapt for agents when `/improve-agent` exists)
