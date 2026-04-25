# Flow-Graph SKILL.md Skeleton

Fill in placeholders. Remove sections that don't apply. Keep SKILL.md under ~80 lines.

---

```markdown
---
name: <skill-name>
description: "<trigger conditions — phrases a USER would say>"
domain: <from SKILL_TAXONOMY.md>
intent: <from SKILL_TAXONOMY.md>
tags: [<lowercase>, <hyphenated>]
user-invocable: <true|false>
argument-hint: "<expected arguments>"
---

<1-2 sentence mental model — what this skill does and why it exists.>

> **Execution scope:** Ignore `research/`, `EVAL.md`, `PROGRAM.md`, `SCOPE.md`, and `test-inputs/` during execution — these are used only by improvement and migration workflows.

## MUST (every turn)
- <global invariant — applies regardless of which node is active>
- Record position: `Position: [node-id] — <context>`

## MUST NOT (global)
- <global guardrail — never do this, any node, any turn>

## Wrong-Tool Detection
- **User wants X** → redirect to `/<sibling-skill>`
- **User wants Y** → not this skill; suggest Z instead

## Entry

### [NEW] Fresh session
<Load: ... (optional)>
Do: <initialization steps>
Don't: <entry guardrails>
Exit: → [<first-flow-node>]

### [RESUME] Paused session
<!-- Include only if skill has persistent state across sessions -->
Do: <re-read state, determine position>
Don't: Assume previous context — always re-read fresh.
Exit: → <resume at last active node>

## Flow

### [<ID>] <Node Name>
<Load: references/x.md, templates/y.md>
<Brief: 1-2 line mental model for this node. (optional)>
Do:
  1. <Judgment call — what to decide, not how to do it>
  2. <Judgment call>
Don't:
  - <Per-node guardrail — co-located for attention weight>
Exit:
  → [<ID>] : <self-loop condition>
  → [<NEXT>] : <forward condition>

<!-- Repeat for each node. Any topology: linear, branching, parallel, circular. -->
<!-- Only invariant: every node has edges, every node can reach [END]. -->

### [END]
Do:
  1. <Present final output summary to user>
  2. <Suggest next steps (prose, not deterministic routing)>
Don't:
  - End without presenting results
  - Auto-route to next skill
```
