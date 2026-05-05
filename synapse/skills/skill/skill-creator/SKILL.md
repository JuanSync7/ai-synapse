---
name: skill-creator
description: Use when asked to create a new skill, build a skill, or edit an existing skill's SKILL.md and companions.
domain: synapse
intent: write
tags: [skill, skill-md, scaffold]
user-invocable: true
argument-hint: "[what the skill should do]"
---

Enforcement agent for skill creation and editing. Two modes: **creation** takes brainstorm memos
and produces compliant SKILL.md + companion files; **edit** applies targeted changes to existing
skills while respecting structural rules. Both enforce design principles, flow-graph structure,
and writing conventions.

> **Execution scope:** Ignore `research/`, `EVAL.md`, `PROGRAM.md`, `SCOPE.md`, and `test-inputs/` during execution — these are used only by improvement and migration workflows.

## MUST (every turn)
- Update task progress at phase transitions
- Set model explicitly on every subagent dispatch
- Trace every [W] instruction back to a specific baseline failure from [B]
- Record position: `Position: [node-id] — <context>`

## MUST NOT (global)
- Skip baseline test when no memo exists ("this skill is simple" is not an exemption)
- Proceed from [U] with underspecified goal
- Produce EVAL.md before the skill is written (post-hoc bias)
- Produce prose-structured SKILL.md — every skill follows flow-graph pattern
- Skip /improve-skill validation ("the skill looks correct" is not validation)

## Wrong-Tool Detection
- **User wants to improve an existing skill (score-fix loop)** → redirect to `/improve-skill [path]`
- **User wants to evaluate or re-evaluate a skill** → redirect to `/write-synapse-eval skill [path]`
- **User wants to run a skill** → invoke the skill directly, not skill-creator

## Entry

### [NEW] Fresh session
Do:
  1. Check for wrong-tool redirects
  2. Determine mode:
     - **Target skill exists on disk** + edit description provided → **edit mode** → [ED]
     - **Target skill does not exist** → **creation mode** → check for decision memo from `/synapse-brainstorm`, evaluate against [U] gate conditions — fill gaps only → [U]
Don't: Skip wrong-tool check.
Exit:
  → [ED] : skill exists + edit description
  → [U] : new skill

### [RESUME] Paused session
Do: Read task list for position + progress state.
Don't: Assume previous context — always re-read task state fresh.
Exit: → resume at last active node

## Flow

### [ED] Edit
Load: references/flow-graph-pattern.md, references/skill-design-principles.md, references/writing-conventions.md, references/companion-dispatch-protocol.md
Brief: Apply targeted changes to an existing skill while respecting structural rules.
Do:
  1. Read existing SKILL.md + all companion files in the skill directory
  2. Apply described changes — use structure-preserving edit rules for flow-graph targets
  3. If companion files are affected by the edit, dispatch `skill-companion-file-writer` (model: sonnet; Load: `agents/skill-companion-file-writer.md`)
  4. Re-validate against structural checklist — confirm no rules broken by the edit
  5. If edit changes registry-relevant metadata (name, domain, intent, pipeline status) → update registry entries
  6. If edit changes behavior that invalidates existing EVAL.md criteria → flag for user ("EVAL.md may need updating — run `/write-synapse-eval skill <path>` to regenerate")
Don't:
  - Rewrite content beyond the described edit — touch only what was requested
  - Skip structural re-validation after applying changes
  - Auto-regenerate EVAL.md — flag and let user decide
Exit:
  → [ED] : structural validation found issues from the edit — fix and re-check
  → [V] : edit applied, structure valid

### [U] Understand
Brief: Self-loops until all gate conditions pass.
Do:
  1. If memo provided, evaluate against gates — fill gaps only
  2. If memo contains VERBATIM blocks (flow graphs, node specs, notepad architecture), use them as the starting point — they've been pressure-tested during brainstorming. Validate against design principles and adjust where needed, but don't re-derive from scratch.
  3. Capture intent, identify triggers, define output, check registry for siblings
Don't: Proceed with underspecified goal — ask specific questions.
Exit:
  → [U] : gaps remain (trigger phrase, output artifact, overlap, or user confirmation missing)
  → [B] : all gates pass

### [B] Baseline Test
Brief: Conditional — skip if memo has documented baseline failure.
Do:
  1. If memo with baseline failure → use gap analysis, skip to [W]
  2. If no memo → spawn subagent with task prompt (full context, no skill instructions), evaluate
  3. Judge: output correct, partial, or failing?
Don't: Skip when no memo exists.
Exit:
  → [END] : output already correct (skill unnecessary — inform user)
  → [W] : gaps documented

### [W] Write SKILL.md
Load: references/flow-graph-pattern.md, references/skill-design-principles.md, references/writing-conventions.md, templates/flow-graph-skeleton.md, templates/flow-graph-worked-example.md
Brief: Core enforcement — main agent writes SKILL.md only, not companions.
Do:
  1. Apply flow-graph pattern — structure is universal regardless of memo format
  2. Distill principles into MUST / MUST NOT rules
  3. Decompose into nodes — each gets Load/Brief/Do/Don't/Exit
  4. Identify all companion files from Load declarations
Don't:
  - Produce prose-structured SKILL.md
  - Write companion files — that's [C]
  - Proceed if design can't converge into ~80 lines — fail loudly
Exit:
  → [W] : needs revision
  → [C] : SKILL.md written + companion inventory ready

### [C] Write Companions
Load: agents/skill-companion-file-writer.md, references/companion-dispatch-protocol.md, references/writing-conventions.md
Brief: Main agent becomes orchestrator — dispatches subagents, doesn't write directly.
Do:
  1. Dispatch companion file subagents per protocol
  2. Judge coherence — does each companion serve its Load point in SKILL.md?
Don't:
  - Silently accept subagent failures
  - Accept a companion that doesn't match its Load point
Exit:
  → [C] : partial failure or coherence mismatch
  → [R] : all companions written and coherent

### [R] Register
Load: references/registry-format.md
Do:
  1. Add SKILL_REGISTRY.md row
  2. Judge: pipeline-routable? If yes, add SKILLS_REGISTRY.yaml entry
  3. Judge: non-trivial contracts or tier 2 companions? If yes, add detail sections
Don't: Add pipeline entry for skills that don't consume/produce defined artifact types.
Exit: → [E]

### [E] Eval
Load: agents/skill-eval-prompter.md, agents/skill-eval-judge.md, agents/skill-eval-auditor.md
Brief: Three independent subagents — dispatch in parallel.
Do:
  1. Dispatch prompter + judge + auditor in parallel
  2. Assemble outputs into EVAL.md
Don't: Silently swallow failures — retry failed dispatches, preserve successful results.
Exit:
  → [E] : partial failure, retry
  → [V] : EVAL.md assembled

### [V] Validate
Do:
  1. Hand off to /improve-skill for single-pass validation
  2. Judge: warrants autonomous iteration? If yes, set up SCOPE.md + test-inputs/ + PROGRAM.md, suggest /auto-research
Exit: → [END]

### [END]
Do:
  1. Present summary: skill directory path, files created, registry entries, EVAL.md status
  2. Suggest next steps (prose, not deterministic routing)
Don't:
  - End without presenting full output summary
  - Auto-route to next skill — suggest, don't dispatch
