# Flow-Graph Pattern

A flow-graph SKILL.md is a state machine. If you can write a LangGraph node, you can write a flow-graph node.

```python
# LangGraph node                          # Flow-graph node
def write_companions(state):              # ### [C] Write Companions
    """Orchestrator — dispatches,          # Brief: Orchestrator — dispatches,
       doesn't write directly."""          #   doesn't write directly.
    
    protocol = Read("refs/dispatch.md")   # Load: refs/dispatch.md
    
    dispatch_all(state.companions)        # Do: 1. Dispatch per protocol
    judge_coherence(state.results)        # Do: 2. Judge coherence
    
    if any_failure(state.results):        # Don't: silently accept failures
        raise Retry(...)                  
    
    return route(state)                   # Exit: → [C] retry | → [R] done
```

The mapping is 1:1. Every flow-graph construct has a code equivalent.

---

## Structural Invariants

Two rules. Everything else is flexible.

1. **Every node must have at least one outgoing edge.** No dead ends.
2. **Every node must be able to reach [END]** (or an explicit exit clause). No unreachable terminals.

---

## Node Anatomy

```
### [ID] Name
Load: references/x.md, agents/y.md
Brief: 1-2 line mental model for this node. (optional)
Do:
  1. Judgment call A
  2. Judgment call B
Don't:
  - Per-node guardrail X
  - Per-node guardrail Y
Exit:
  → [X] : condition
  → [Y] : condition
```

### What goes where

| Section | Contains | Rule |
|---------|----------|------|
| **Load** | File read declarations | Mechanical — which companion files to read before acting |
| **Brief** | Mental model framing | Optional, 1-2 lines. Use when agent's role changes or behavior is conditional |
| **Do** | **What the agent does** | "What to do," not "how to do it." Decisions, actions, evaluations — not procedures, format specs, or detailed instructions |
| **Don't** | Per-node guardrails | Co-located with the action for attention weight at the exact moment they matter |
| **Exit** | Edge conditions | When and where to transition. Every edge has an explicit condition |

### The Do rule

Do steps describe what the agent does at this node — decisions, actions, checks, evaluations. Procedures, format specs, and detailed instructions for how to carry out those actions belong in companion files loaded at the node.

**Good Do:** "Score SKILL.md against baseline checklist" (what to do — the checklist items themselves live in a companion)
**Good Do:** "Judge coherence — does each companion serve its Load point in SKILL.md?" (evaluation)
**Good Do:** "Opening inventory — exhaustive shallow list of all concerns" (action with intent)
**Bad Do:** "Extract companion file list from SKILL.md Load declarations, compose dispatch with file_path + file_type + content_brief, send to subagent" (procedure — how to do it)

The bad example is a procedure. It belongs in a reference file loaded at the node. The Do step becomes: "Dispatch companion file subagents per protocol."

---

## Three-Tier Constraint Model

Constraints live at three levels, each with a different scope and attention behavior:

| Tier | Section | Scope | When it fires |
|------|---------|-------|---------------|
| 1 | **MUST / MUST NOT** | Global — every turn, every node | Always in view at top of SKILL.md |
| 2 | **Don't** (per-node) | This node only | Co-located — high attention weight at the moment it matters |
| 3 | **rules/** (companion) | Domain-wide, not node-specific | Loaded when relevant, shared across nodes |

Don't is NOT a companion file candidate. The whole point is co-location — "Don't skip the coherence check" only matters at [C], and it matters right then.

---

## Node Decomposition

**A node is a unit of response packaging for the user, not a unit of work.**

The decomposition question is: "What interaction unit makes sense for the user?" Not: "What logical steps exist?"

- **Self-loop** — same concept repeating. Four diagnostic questions in one conversational node, not four separate nodes asking one at a time.
- **Separate nodes** — genuinely different concerns that each need their own Load/Brief/Do/Don't/Exit context.
- **Parallel dispatch** — independent work that can run concurrently from a single orchestrator node.

### Topology freedom

Any topology is valid. The pattern does not prescribe graph shape:

- Circular, linear, pipeline, single-node
- Self-loop, checklist-style
- Wide-parallel-to-one, one-to-parallel
- Any combination

The only structural requirement is the two invariants: edges exist, [END] is reachable.

---

## Edge Types

Every edge has a condition. Three types:

| Type | Meaning | When to use |
|------|---------|-------------|
| **must** | Only valid transition | Single exit path — no alternatives |
| **should** | Conditional — taken when condition is met | Default path with explicit condition |
| **can** | Optional — agent may choose | Discretionary transitions |

Self-loops are explicit edges, not implicit. Write them out:
```
Exit:
  → [U] : gaps remain (self-loop)
  → [B] : all gate conditions met
```

---

## Position Tracking

Agent records position each turn:

```
Position: [C] — dispatched 4/6 companion subagents, awaiting results
```

The position string carries granularity. Sub-node progress goes in the string, not in sub-nodes:

```
Position: [W] — SKILL.md draft 2, revising MUST NOT section
```

---

## Entry Points

Every skill has at least one entry point. Two standard types:

- **[NEW]** — fresh session. Always required.
- **[RESUME]** — paused session with persistent state. Only if the skill has state across sessions (notepad, meta.yaml, etc.). If no persistent state, omit [RESUME].

Entry points have the same anatomy as flow nodes (Load/Brief/Do/Don't/Exit) but live under `## Entry`, not `## Flow`.

---

## [END] Node

[END] is a real node, not just a marker. It has:
- Do steps (final output, cleanup, summary to user)
- Don't guardrails (don't end without presenting results, don't auto-route to next skill)
- No Exit (session ends)

---

## SKILL.md Line Budget

SKILL.md must stay lean — **~80 lines target, 500 hard cap.** Every line is always-loaded and competes for attention every turn. If the skill approaches the cap, content that isn't always-on moves to companion files.

On-demand loading is about **attention weight recency**, not token saving. Content loaded at the moment it's needed gets higher attention priority than content loaded many turns ago.

---

## Verbatim Convention

When a skill writes structural content (directory trees, schemas, flow graphs, code blocks) to a working document that subagents later read:

- Prefix the block with `<!-- VERBATIM -->` in the working document
- Subagents must copy annotated blocks as-is, never compress or summarize

This convention only applies to skills that write to persistent working documents consumed by subagents. Skills without working documents don't need it.
