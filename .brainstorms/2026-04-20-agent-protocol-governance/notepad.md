# Brainstorm Notes — Agent & Protocol Governance

## Status

- **Phase:** B → Done Signal
- **Type:** decision
- **Anticipated shape:** Decision
- **Turn count:** 9

## Threads (indexed)

### T1: Should TAXONOMY.md expand to cover agents and protocols?
**Status:** resolved (implemented)
**Depends on:** —
**Lenses applied:** N/A (executed directly)

Decision: Split into 3 files: SKILL_TAXONOMY.md, AGENT_TAXONOMY.md, PROTOCOL_TAXONOMY.md. All references updated across 9 files.

### T2: What governance model do protocols need?
**Status:** resolved
**Depends on:** —
**Lenses applied:** Robustness, Maintenance, Preciseness

Decision: Full governance including conformance testing, built upfront. User rationale: same as skill-creator at n=1 — if you wait until n=10 protocols to define the rules, you get misaligned protocols that need retrofitting. Build the framework now so everything after follows a repeatable pattern. Conformance testing model: dispatch agent with protocol injected, check output conforms to schema.

### T3: Should synapse-gatekeeper evaluate agents and/or protocols?
**Status:** resolved
**Depends on:** T1, T2
**Lenses applied:** Boundary, Robustness

Decision: One gatekeeper, three flows. synapse-gatekeeper detects artifact type and dispatches to type-specific checklists stored in `references/`. Each artifact type gets its own checklist file and reads its own taxonomy. Keeps the skill under 500 lines while supporting all three types. GOVERNANCE.md rewritten to require full gatekeeper review for agents and protocols (reversing the auto-generated "no review" for agents).

### T4: Pre-commit hook scope — extend to agents/protocols?
**Status:** resolved
**Depends on:** T1
**Lenses applied:** Robustness, Preciseness

Decision: YES. Separate validation paths per artifact type with reduced checks initially. Agents (flat files in src/agents/): frontmatter has name/domain/role, values in AGENT_TAXONOMY.md. Protocols (directories in src/protocols/): frontmatter has name/domain/type, values in PROTOCOL_TAXONOMY.md. Skip EVAL.md and README checks for agents/protocols until lifecycle skills exist.

### T5: Namespace collision risk across artifact types
**Status:** discarded
**Depends on:** —
**Lenses applied:**

Moot with T1.

### T6: Governance weight vs. artifact count
**Status:** resolved (guiding principle)
**Depends on:** T1, T2, T3, T4
**Lenses applied:** N/A (philosophical anchor)

Decision: Framework-first. Build governance guardrails before artifacts arrive. Same rationale as skill-creator at n=1: alignment from the start prevents retrofitting.

### T7: Creator/eval suite for agents and protocols
**Status:** resolved
**Depends on:** T1
**Lenses applied:** Maintenance, Preciseness

Decision: 4 stubs (trimmed from 6): agent-creator, write-agent-eval, protocol-creator, write-protocol-eval. Dropped improve-agent and improve-protocol — trivial to build from improve-skill pattern when needed. Build stubs into real skills when 5+ agents or 3+ protocols exist.

### T8: Taxonomy domain structure for lifecycle skills
**Status:** resolved (implemented)
**Depends on:** T1, T7
**Lenses applied:** N/A (executed directly)

Decision: Option C — parallel hierarchy. `skill.*`, `agent.*`, `protocol.*` as separate domains with matching subdomains (.create, .eval). Parallel naming communicates family relationship without artificial umbrella.

Current SKILL_TAXONOMY.md domains after this decision:
- skill.create → skill-creator, skill-brainstorm + stubs: agent-creator, protocol-creator
  WAIT — Option C means agent-creator gets `agent.create`, NOT `skill.create`
- skill.create → skill-creator, skill-brainstorm
- skill.eval → write-skill-eval, improve-skill, synapse-gatekeeper
- agent.create → agent-creator (stub)
- agent.eval → write-agent-eval, improve-agent (stubs)
- protocol.create → protocol-creator (stub)
- protocol.eval → write-protocol-eval, improve-protocol (stubs)

But wait: agent-creator is a SKILL (lives in src/skills/, has SKILL.md). Its domain in SKILL_TAXONOMY.md is `agent.create`. That means SKILL_TAXONOMY.md needs `agent.*` and `protocol.*` domains added to it — these are domains that skills can belong to, describing what domain of work the skill operates in.

AGENT_TAXONOMY.md is different — it defines domains/metadata for the agents THEMSELVES (the .md files in src/agents/).

This is clean: SKILL_TAXONOMY.md describes what skills do. Some skills work on agents → domain `agent.*`. AGENT_TAXONOMY.md describes what agents are.

## Connections

- T1 ↔ T4: separate taxonomy files means hook reads different file per artifact type
- T1 ↔ T7 ↔ T8: taxonomy structure drives where stubs land and what frontmatter they get
- T8 clarifies: SKILL_TAXONOMY.md gets `agent.*` and `protocol.*` domains (for skills that operate on those artifact types). AGENT_TAXONOMY.md is for agent metadata.

## Resolution Log

- T5 discarded (turn 4) — already separate namespaces

## Key Insights

- Parallel naming IS the grouping — no umbrella needed
- SKILL_TAXONOMY.md needs agent.* and protocol.* domains for lifecycle skills
- AGENT_TAXONOMY.md is for agent self-description, not for skills-about-agents
- User sees skill/agent/protocol as the framework's core — lifecycle tooling reflects that

## Tensions

- (resolved) Natural growth vs. grouping → Option C resolves both

## Discarded Candidates (Moves, Framings, Options)

- "Light governance for agents" — discarded
- "Single TAXONOMY.md with sections" — discarded
- "Protocol eval Option B/C" — discarded
- "Path 2: parameterize existing skills" — discarded
- "Build lifecycle skills now" — deferred, stubs instead
- "Option A: natural growth (no visible grouping)" — superseded by C
- "Option B: umbrella domain (framework.*)" — discarded, confuses routing
- "Defer conformance testing until n≥3 protocols" — user overruled, framework-first
- "6 lifecycle stubs" — trimmed to 4, improve-* variants cut
- "Separate gatekeepers per artifact type" — one gatekeeper, three flows

## Phase A Misses (if any)
