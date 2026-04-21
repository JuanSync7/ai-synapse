---
name: agent-creator
description: "Use when asked to create a new agent definition, build an agent for X, or write an agent recipe."
domain: agent.create
intent: write
tags: [agent, creation, scaffolding]
user-invocable: true
argument-hint: "<agent-name> [--domain <domain>]"
---

# Agent Creator

> **Status: Draft stub.** This skill will be built when 5+ agents exist in `src/agents/`. See GOVERNANCE.md for agent promotion criteria.

Creates new agent definitions (`src/agents/*.md`) with proper frontmatter, taxonomy alignment, and AGENTS_REGISTRY.md entry.

## Wrong-Tool Detection

- **User wants to create a skill** → redirect to `/skill-creator`
- **User wants to improve an existing agent** → redirect to `/improve-skill` (adapt for agents when `/improve-agent` exists)
- **User wants to create a protocol** → redirect to `/protocol-creator`
