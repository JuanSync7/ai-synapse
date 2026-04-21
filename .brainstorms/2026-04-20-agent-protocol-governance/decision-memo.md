# Decision Memo — Agent & Protocol Governance

## What we decided

Extend ai-synapse's governance framework to treat agents and protocols as first-class artifacts with taxonomy, structural validation, gatekeeper review, and lifecycle tooling — all built upfront before scale demands it.

## Why this matters

Without governance, agents and protocols accumulate without consistent metadata, naming, or quality checks. The skill-creator lesson: at n=1 the framework feels premature, but at n=10 without it you're retrofitting misaligned artifacts. Agents are reusable recipes dispatched inside pipelines — harder to observe than skills, so governance matters more, not less.

## Decisions

### D1: Taxonomy split
TAXONOMY.md → three files: SKILL_TAXONOMY.md, AGENT_TAXONOMY.md, PROTOCOL_TAXONOMY.md. Each artifact type gets its own controlled vocabulary. SKILL_TAXONOMY.md also carries `agent.*` and `protocol.*` domains for lifecycle skills (skills that operate on agents/protocols).

**Status: Implemented.** All references updated across 9 production files.

### D2: Protocol governance — full, including conformance testing
Protocols get structural governance (frontmatter, taxonomy match) AND conformance testing as the eval model. Conformance test = dispatch an agent with the protocol injected, check if output conforms to the protocol's schema. Binary pass/fail.

Built upfront at n=1 to establish the pattern. Framework-first.

### D3: One gatekeeper, three flows
synapse-gatekeeper stays as a single skill but detects artifact type and dispatches to type-specific checklists stored in `references/`. Each flow reads its own taxonomy file. GOVERNANCE.md rewritten to require full gatekeeper review for agents and protocols (reversing the prior auto-generated "no review" for agents).

**Implementation needs:**
- `references/agent-checklist.md` — structural + quality checks for agents
- `references/protocol-checklist.md` — structural + conformance checks for protocols
- GOVERNANCE.md agent section rewritten
- GOVERNANCE.md protocol section added

### D4: Pre-commit hook extended
Separate validation paths per artifact type:
- **Skills** (existing): frontmatter fields, domain/intent in SKILL_TAXONOMY.md, EVAL.md exists, README row
- **Agents** (`src/agents/*.md`): frontmatter has name/domain/role, values in AGENT_TAXONOMY.md
- **Protocols** (`src/protocols/*/`): frontmatter has name/domain/type, values in PROTOCOL_TAXONOMY.md

EVAL.md and README checks deferred for agents/protocols until lifecycle skills exist.

### D5: Four lifecycle skill stubs
Create stubs (frontmatter + placeholder body, `status: draft` in registry) for:
1. `agent-creator` (domain: `agent.create`)
2. `write-agent-eval` (domain: `agent.eval`)
3. `protocol-creator` (domain: `protocol.create`)
4. `write-protocol-eval` (domain: `protocol.eval`)

Dropped: improve-agent, improve-protocol — trivial to derive from improve-skill when needed.

**Build trigger:** Stubs become real skills when 5+ agents or 3+ protocols exist.

### D6: Parallel hierarchy domains
SKILL_TAXONOMY.md uses `skill.*`, `agent.*`, `protocol.*` as separate domain hierarchies with matching subdomains (`.create`, `.eval`). Parallel naming communicates family relationship without an artificial umbrella domain.

**Status: Implemented.** Domains added to SKILL_TAXONOMY.md.

## Implementation sequence

```
Phase 1 (done): Taxonomy split + domain additions
Phase 2: GOVERNANCE.md rewrite (agent + protocol sections)
Phase 3: Pre-commit hook extension (parallel — independent of Phase 2)
Phase 4: Gatekeeper references (agent-checklist.md, protocol-checklist.md)
Phase 5: Lifecycle skill stubs (4 stubs)
Phase 6: synapse-gatekeeper SKILL.md update (artifact type detection + dispatch)
```

## Open questions

- **Agent EVAL.md format:** What does an agent eval look like? Agents don't have test prompts in the same way skills do — they're dispatched with specific inputs by parent skills. Deferred until agent-creator is built.
- **Protocol conformance test harness:** Which agent gets dispatched for conformance testing? The protocol's own `test-agent` field? A generic harness? Deferred until protocol-creator is built.
- **AGENTS_REGISTRY.md:** Currently only lists agents. Should there be a PROTOCOLS_REGISTRY.md? Or extend to ARTIFACTS_REGISTRY.md? Low priority — revisit at n≥3 protocols.
