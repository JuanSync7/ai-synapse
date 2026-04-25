# Decision Memo — skill-creator: rewrite as flow-graph + teach flow-graph pattern

> Artifact type: skill (change request) | Source brainstorm: `2026-04-22-skill-creator-flow-graph` | Prior brainstorm: `2026-04-22-brainstorm-multi-artifact-output` (design doc at `/home/juansync7/RagWeave/.brainstorms/2026-04-22-brainstorm-multi-artifact-output/design.md`)

---

## What I want

Rewrite skill-creator's own SKILL.md as a flow-graph (eat your own dog food), then make flow-graph the universal default for every skill it produces. Move current prose content to companion files. The result is a lean ~80-line SKILL.md that is both the instructor and the first worked example of the pattern.

---

## Why Claude needs it

Without the flow-graph pattern, skill-creator produces prose-structured SKILL.md files that suffer from:
- Guardrails buried away from the actions they constrain (low attention weight at the moment they matter)
- No explicit position tracking (agent drifts without knowing which node it's in)
- No explicit edge conditions (exit paths are implicit, creating ambiguity)
- Global rules mixed with per-step rules, reducing attention priority of both

Skill-creator's own SKILL.md is 412 lines of prose — near the 500-line cap — with conventions, format specs, and examples inlined that compete for attention on every turn even when irrelevant.

---

## Injection shape

Workflow + structural pattern. Skill-creator is an enforcement agent, not a creative agent. It takes brainstorm memos (the deep thinking) and enforces best practices, design principles, and now the flow-graph structural pattern. When no memo exists, it does both jobs.

---

## What it produces

- SKILL.md files structured as flow graphs (directed graph: nodes + edges with conditions)
- Companion file sets (references/, templates/, agents/, rules/, examples/)
- Registry entries with detail sections (Consumes/Produces/Contains) when applicable
- EVAL.md via subagent dispatch

---

## Architecture details

### Skill-creator's role vs brainstorm's role

- **Brainstorm** is the deep reasoner — explores, pressure-tests, produces decision memos with intent and architecture. Does not strictly enforce structural best practices.
- **Skill-creator** is the marker/validator — takes the memo, checks against design principles, flow-graph pattern, and writing conventions. Modifies to 100% compliance. Reasons against rules, not from first principles.
- When no memo exists, skill-creator does both jobs (understand + enforce).

### Flow-graph node map

```
Entry:
  [NEW]    — fresh skill creation (decision memo check)
  [RESUME] — paused session

Flow:
  [U] Understand         — intent, triggers, output, siblings (self-loop)
  [B] Baseline Test      — conditional: skip if memo has documented baseline, else run necessity test
  [W] Write SKILL.md     — main agent writes the flow-graph SKILL.md (self-loop)
  [C] Write Companions   — main agent orchestrates, dispatches subagents for companion files in parallel
  [R] Register           — SKILL_REGISTRY.md + conditional SKILLS_REGISTRY.yaml
  [E] Eval               — dispatch 3 subagents in parallel, assemble EVAL.md
  [V] Validate           — hand off to /improve-skill or /auto-research

  [END] — summary + next steps
```

### Node details

**[U] Understand:**
- Brief: Self-loops until all gate conditions pass — same repeatable concept, no point splitting into separate nodes.
- Do:
  1. If decision memo provided, evaluate against gate conditions — fill gaps only
  2. Capture intent, identify triggers, define output, check registry for siblings
- Don't: Proceed with underspecified goal — ask specific questions
- Exit: → [U] gaps remain | → [B] trigger phrase + output artifact + no overlap + user confirmed

**[B] Baseline Test:**
- Brief: Conditional node — behavior depends on whether a decision memo exists.
- Do:
  1. If memo has documented baseline failure → use memo's gap analysis, skip to [W]
  2. If no memo → spawn subagent with user's task prompt (full domain context, no skill instructions), evaluate output
  3. Judge: is the output already correct, partially correct, or failing?
- Don't: Skip when no memo exists — "this skill is simple" is never an exemption
- Exit: → [END] output already correct (skill unnecessary) | → [W] gaps documented

**[W] Write SKILL.md:**
- Load: `references/flow-graph-pattern.md`, `references/skill-design-principles.md`, `references/writing-conventions.md`, `templates/flow-graph-skeleton.md`, `templates/flow-graph-worked-example.md`
- Brief: Core enforcement node — main agent writes SKILL.md only, not companions.
- Do:
  1. Apply flow-graph pattern to memo content — structure is universal regardless of memo format
  2. Distill core principles into MUST / MUST NOT rules
  3. Decompose into nodes — each gets Load/Brief/Do/Don't/Exit
  4. Identify all companion files needed from Load declarations
- Don't:
  - Produce prose-structured SKILL.md
  - Write companion files — that's [C]'s job
  - Proceed if design can't converge into ~80 lines — fail loudly, surface to user
- Exit: → [W] SKILL.md needs revision | → [C] SKILL.md written + companion inventory ready

**[C] Write Companions:**
- Load: `agents/skill-companion-file-writer.md`, `references/companion-dispatch-protocol.md`, `references/writing-conventions.md`
- Brief: Main agent becomes orchestrator — dispatches subagents, doesn't write companions directly.
- Do:
  1. Dispatch companion file subagents per protocol
  2. Judge coherence — does each companion serve its Load point in SKILL.md?
- Don't:
  - Silently accept subagent failures
  - Accept a companion that doesn't match its Load point
- Exit: → [C] partial failure or coherence mismatch | → [R] all companions written and coherent

**[R] Register:**
- Load: `references/registry-format.md`
- Do:
  1. Add SKILL_REGISTRY.md row
  2. Judge: is this skill pipeline-routable? If yes, add SKILLS_REGISTRY.yaml entry
  3. Judge: does this skill have non-trivial contracts or tier 2 companions? If yes, add detail sections
- Don't: Add pipeline entry for skills that don't consume/produce defined artifact types
- Exit: → [E] registered

**[E] Eval:**
- Load: `agents/skill-eval-prompter.md`, `agents/skill-eval-judge.md`, `agents/skill-eval-auditor.md`
- Brief: Dispatch three eval subagents in parallel — prompter, judge, auditor are independent.
- Do:
  1. Dispatch all three subagents in parallel
  2. Assemble outputs into EVAL.md
- Don't: Silently swallow subagent failures — retry failed dispatches, preserve successful results
- Exit: → [E] partial failure, retry | → [V] EVAL.md assembled

**[V] Validate:**
- Do:
  1. Hand off to /improve-skill for single-pass validation
  2. Judge: does this skill warrant autonomous iteration? If yes, set up SCOPE.md + test-inputs/ + PROGRAM.md, suggest /auto-research
- Exit: → [END] validation complete

### MUST / MUST NOT (skill-creator's own global rules)

**MUST:**
- Update task progress at phase transitions (harness-agnostic)
- Set model explicitly on every subagent dispatch
- Trace every [W] instruction back to a specific baseline failure from [B]

**MUST NOT:**
- Skip baseline test when no memo exists
- Proceed from [U] with underspecified goal
- Produce EVAL.md before the skill is written (post-hoc bias)
- Produce prose-structured SKILL.md — every skill follows flow-graph pattern
- Skip /improve-skill validation

### Node granularity principle (for skills skill-creator produces)

Skill-creator must teach this principle to produce good node decompositions:

**A node is a unit of response packaging for the user, not a unit of work.** The decomposition question is "what interaction unit makes sense for the user?" not "what logical steps exist?"

- Flow graphs can be ANY topology: circular, linear, pipeline, single-node, self-loop, checklist, wide-parallel-to-one, one-to-parallel. The pattern is flexible.
- Only structural invariant: every node must have an edge to somewhere, and every node must be able to reach [END] (or an exit clause).
- Self-loop when the same concept repeats (diagnostic questions in one conversational node).
- Separate nodes when genuinely different concerns each need their own Load/Do/Don't/Exit context.
- Parallel dispatch when work is independent and can run concurrently.
- A node contains everything needed to package a coherent response: pre-Do instructions (sentence, Load, Read), Do steps, Don't guardrails, Exit edges. What goes where is a judgment call.

---

## Edge cases considered

- **Decision memo from pre-flow-graph brainstorm:** [W] applies flow-graph pattern universally. Memo provides content/intent; [W] provides structure. No branching needed.
- **[W] can't converge:** fails loudly — scope too broad for ~80 lines or contradictory requirements. Surfaces the problem to user.
- **[E] partial subagent failure:** retry failed dispatch(es) while preserving successful results. Self-loop, not full restart.
- **Very simple skills (~10 lines):** flow-graph still applies, may collapse to [NEW] → single [MAIN] → [END]. Don't invent nodes for the sake of structure.
- **Skills with no persistent state:** [RESUME] entry point may be omitted. [NEW] always required.
- **Existing prose SKILL.md rework:** skill-creator converts to flow-graph preserving all behavioral logic. Structural migration, no behavioral changes.
- **[C] subagent content brief too thin:** subagent reports AGENT FAILURE with specific gaps. Main agent enriches the brief (pulls more context from memo or conversation) and retries.
- **[C] companion doesn't match Load point:** coherence review catches it — the companion exists but doesn't serve the purpose SKILL.md expects. Main agent re-dispatches with corrected brief.
- **Skill with zero companion files:** [C] is a no-op, exits immediately to [R].

---

## Companion files anticipated

### references/ — domain knowledge loaded on-demand

| File | Loaded at | Purpose |
|------|-----------|---------|
| `flow-graph-pattern.md` | [W] | **New.** Conceptual framing: LangGraph analogy ("a flow-graph SKILL.md is a state machine — if you can write a LangGraph node, you can write a flow-graph node"). Node anatomy: Load (file reads) → Brief (optional 1-2 line mental model) → Do (judgment calls only) → Don't (per-node guardrails) → Exit (edge conditions). Structural invariants (edges + reachability to [END]), packaging principle (node = coherent response unit), edge types (must/should/can), position tracking, topology freedom, three-tier constraint model (MUST/MUST NOT global → Don't per-node → rules/ companion), compact annotated snippet. **Key rule: Do steps are judgment calls only** — mechanical steps, how-tos, and what-to-include lists belong in companion files loaded at the node. |
| `skill-design-principles.md` | [W] | **Existing, unchanged.** Content principles: context injection, mental model before mechanics, policy over procedure, etc. Orthogonal to flow-graph structure. |
| `writing-conventions.md` | [W] | **New.** Extracted from current SKILL.md prose: (1) frontmatter format + good/bad description examples, (2) folder conventions table + why flat not nested, (3) companion file pointing syntax, (4) execution fence boilerplate, (5) skill directory structure, (6) line budget (~80 target, 500 cap, overflow policy), (7) voice/tone (imperative, MUST/NEVER for constraints, policy language for judgment), (8) Wrong-Tool Detection section format, (9) progress tracking convention (generic, harness-agnostic), (10) subagent model visibility, (11) verbatim annotation convention — if produced skill involves subagents reading working documents, include MUST rule for `<!-- VERBATIM -->` prefixing on structural content. |
| `companion-dispatch-protocol.md` | [C] | **New.** Dispatch protocol for companion file writing: exact input fields each subagent expects (file_path, file_type, skill_md, content_brief, writing_conventions), how to extract content briefs from memo sections, file_type behavioral differences (reference vs template vs rule vs example), retry protocol (what to enrich on failure, max retries), coherence check definition (what "matches its Load point" means concretely). |
| `registry-format.md` | [R] | **New.** SKILL_REGISTRY.md row format, SKILLS_REGISTRY.yaml entry format, detail sections (Consumes/Produces/Contains), `contains` field for tier 2 companions, pipeline-routable conditions checklist. |
| `scope-format.md` | [V] | Existing. |
| `program-format.md` | [V] | Existing. |
| `test-inputs-format.md` | [V] | Existing. |
| `research-format.md` | [V] | Existing. |

### templates/ — output format skeletons

| File | Loaded at | Purpose |
|------|-----------|---------|
| `flow-graph-skeleton.md` | [W] | **New.** Structural template for produced SKILL.md files — the skeleton skill-creator fills in. Has placeholder Load lines, MUST/MUST NOT sections, Entry/Flow structure. |
| `flow-graph-worked-example.md` | [W] | **New.** Full synapse-brainstorm flow graph as concrete example. Frozen snapshot — shows the pattern, not latest version. |

### agents/ — subagent definitions

| File | Loaded at | Purpose |
|------|-----------|---------|
| `skill-companion-file-writer.md` | [C] | **New.** Writes a single companion file for a skill. Receives: file path, file type, SKILL.md content, content brief, writing conventions. One generic agent — file_type parameter changes behavior (references teach patterns with annotated examples, templates are skeletons with placeholders, rules state hard constraints, examples show complete worked output). Reports AGENT FAILURE with specific gaps if content brief is insufficient. |
| `skill-eval-prompter.md` | [E] | Existing. Generates test prompts. |
| `skill-eval-judge.md` | [E] | Existing. Generates output criteria. |
| `skill-eval-auditor.md` | [E] | Existing. Generates execution criteria. |

---

## Dependencies

| Artifact | Role | Required? | Notes |
|----------|------|-----------|-------|
| `flow-graph-pattern.md` | Pattern definition reference | Yes | **Pre-created** at `references/flow-graph-pattern.md` — ready for consumption |
| `writing-conventions.md` | Convention reference | Yes | New file — extracted from current SKILL.md |
| `registry-format.md` | Registry format reference | Yes | New file — extracted from current SKILL.md Phase 2.5 |
| `companion-dispatch-protocol.md` | Dispatch protocol for [C] | Yes | New file — how to compose and manage subagent dispatches |
| `skill-companion-file-writer.md` | Subagent for companion writing | Yes | New agent — dispatched by [C] for each companion file |
| `flow-graph-skeleton.md` | Template for produced skills | Yes | New file |
| `flow-graph-worked-example.md` | Concrete example | Yes | New file — synapse-brainstorm flow graph from design doc |
| `skill-design-principles.md` | Content principles | Yes | Existing, unchanged |
| Prior change request memo | Context | No | At `skill-creator/change_requests/2026-04-22-brainstorm-multi-artifact-output.md` — **this memo fully supersedes it.** All content from the old memo has been absorbed: flow-graph pattern → `flow-graph-pattern.md`, registry detail sections + tier model → `registry-format.md`, verbatim convention → `writing-conventions.md`, worked example → `flow-graph-worked-example.md`. Implementation details (exact table formats, YAML snippets) belong in the reference files, not the memo. |

---

## Follow-up tasks (not part of this change request)

1. Regenerate skill-creator's EVAL.md after rewrite (`/write-skill-eval`)
2. Run `/improve-skill` against the rewritten skill-creator
3. Apply the improve-skill change request (artifact 3 from the prior brainstorm) — teach improve-skill to recognize and maintain flow-graph structure

---

## Open questions

None. All threads resolved during brainstorm.
