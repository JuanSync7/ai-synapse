# Brainstorm Notes — generic-brainstorm-skill

## Status
Phase: DONE
Outcome: skill (memo produced, hand off to /skill-creator)
Final artifacts: notepad.md (this file) + memo.md + meta.yaml

## Resolved
- Idea is skill-worthy — validated in framing conversation before invocation.
- Relationship to `/skill-brainstorm`: independent siblings (Option B). Reason: outcome taxonomy differs (7 shapes vs 3), done signal differs, lens sets differ. Duplication accepted over chassis coupling.
- Trigger scope: broad topic coverage (features, writing, architecture, research, career/work decisions, hypothesis generation), sharp trigger phrases ("help me think through," "I'm debating," "should I," "I have an idea for," "I'm not sure how to approach"). Does NOT fire on factual questions, implementation requests, or domains with specialized sibling brainstorms.
- Coach voice: Socratic, pressure-testing (per user's global CLAUDE.md default), honest about abandonment, mentor-style ("enough for today"). Professional, not drip-feeder.
- No-artifact exits (Abandon, Defer) are first-class outcomes.
- **Taxonomy spine = constrained type × shape matrix (Option C).** Types and shapes are two dimensions; Phase A outputs a `(type, shape)` cell. Cell influences which *moves* dominate in Phase B and which lens subset fires.
- **CORRECTED FRAME (replacing earlier "3 archetypes" model):** Phase B is not one of N mutually exclusive phase structures. Instead, Phase B has a small set of *moves* — **Generate / Pressure-test / Agree / Reframe / Decompose / Circle-back / Pause** (7 moves) — and any session uses a mix. Type classification biases which moves dominate but does not restrict them. This matches how real brainstorms work: multiple threads open simultaneously, coach moves between them, must circle back to close every thread.
- **Pause is a first-class move.** The mentor circuit breaker has a diagnostic ("sense diminishing returns") and an action (Pause: save state, set `meta.yaml` status to `paused`, end session cleanly). Without Pause as a named move, circuit breaker is theater. Pause is also what makes resume work — without a clean suspend point, sessions can't be continued tomorrow.
- **Notepad template uses indexed thread IDs (`T1`, `T2`, ...) from day one.** Scales to long sessions; Connections reference by ID; Resolution log becomes scannable. Minor overhead on short sessions, major payoff on long ones.
- **Built-in `brainstorm` stage collision: Coexist (A).** User-facing `/brainstorm` skill + orchestrator's internal built-in stage share a name but not an implementation. Document in SKILL.md. Unify (B) flagged as follow-up registry refactor.
- **`/agent-brainstorm` is a separate future sibling skill.** Agent ↔ agent, no user, invoked by other skills. Different Done Signal (agent consensus). Out of scope for this brainstorm; flagged in memo's future work.
- **Coach role framing (user-originated):** coach = board member / team member that the user must reach *agreement* with. This is why **Agree** is a first-class move — without it, the coach pressure-tests forever; the move is the explicit convergent counterweight. Operationalizes the "Agree When Convinced" rule from coaching-policy.md.
- **Negative moves fold into existing ones.** Rejecting an option = Pressure-test outcome landing in `discarded` state. No separate Reject/Kill move. Thread state transitions encode the polarity.
- **Thread states (5):** `open` / `resolved` / `discarded` / `deferred` / `decomposed`. At Done Signal, no thread may be `open`. Decomposed parents must have at least one resolved/discarded/deferred child.
- **Classification isn't sticky.** If user's topic drifts mid-session (e.g., decision → reframe), coach updates (type, shape) + lens subset + notes the shift. Explicit permission, not a bug.
- **Phase A Gate (distinct from Done Signal).** Coach has classified (type, shape) + Opening Inventory complete + user has responded to the map (agree/amend/disagree) + feedback incorporated. Coach announces transition explicitly: "Phase A complete. Entering Phase B — threads: [list]." Makes the boundary visible.
- **Circle-back is available anytime in Phase B, not only at Done Signal.** All 6 moves are valid chess moves. Coach uses circle-back whenever thread-tracking feels cloudy (after long Generate burst, after Decompose spawn, mid-session drift). A *final* circle-back is mandatory before Done Signal; mid-session uses are discretionary.
- **Phase A failure admission protocol.** When a first-order concern surfaces in Phase B, coach: (a) names the miss explicitly ("I should have caught this in Phase A"), (b) adds to inventory, (c) **sweeps prior decisions that may be invalidated by the new concern and flags them for re-examination**, (d) continues. Step (c) is essential — a late-surfacing concern can break earlier choices; skipping the sweep leaves invalid decisions in the memo.
- **Circle-back is the non-negotiable move.** Before Done Signal, coach walks the notepad thread-by-thread and confirms status (resolved / deferred / discarded / hanging). Prevents the "threads lost in drift" failure.
- **Lens selection = 2 universal + 2 type-specific = 4 per session.** Universal: Stakeholder, Alternative. Type-specific: decision→Reversibility+Failure-mode; exploratory→Constraint+Time; problem→Failure-mode+Reversibility; creative→Constraint+Cost; planning→Time+Cost. All 7 generic lenses still used, just not all per session.
- **Mentor circuit breaker is LLM judgment + user prompt, not hardcoded thresholds.** Coach senses diminishing returns subjectively, surfaces the observation to user ("feels like we're going in circles on X — fresh angle, or is this the point to pause?"). User decides. No numeric thresholds.
- **Handoff is simple: memo at end + prose "you might consider X next" suggestion.** No shape→skill map. User does whatever they want with the memo.
- **Lens selection: per-session, not per-turn.** Phase A classifies type/shape, selects fixed lens subset (3–4 lenses), coach rotates that subset in Phase B. Other lenses pulled in ad-hoc only if user asks.
- **Persistence: project-local `.brainstorms/` default when in a git repo, `~/.claude/brainstorms/` otherwise. Coach asks once if topic is clearly non-project (career/life). Scope recorded in `meta.yaml`.** No perfect solution; this is a pragmatic default.
- **Opening Inventory vs one-question-at-a-time reconciled.** Inventory = coach's self-enumerated concern list (exhaustive, one message, Phase A boundary). Questions = pressure-testing questions the coach asks the user (one at a time, Phase B drilling). Different things, different phases. Not contradictory.
- **Side observation (not this brainstorm's scope):** The "drip-feed" failure pattern (LLM gives a few answers, user asks "anything else," gets more) is a general LLM behavior outside brainstorms. Worth a CLAUDE.md rule ("exhaustively enumerate on first pass for discovery questions"). Noted as a separate improvement, not absorbed into `/brainstorm`.

## Open Threads
- **Circle-back mechanism specifics.** Is it an automatic sweep the coach runs before Done Signal (exhaustive walk), or triggered by user saying "are we done?" Probably automatic — trust the user to override if they want to skip.
- **Thread status vocabulary in notepad.** resolved / deferred / discarded / hanging — are these the right 4? Is "hanging" distinct from "open"? Maybe: open (in-progress) → resolved/deferred/discarded. "Hanging" at Done Signal = failure state that circle-back must escalate.
- **Done Signal precondition.** No thread in `hanging` status + circle-back complete + coach has no fresh concerns from final lens pass.
- **Lightweight mode trigger.** Coach-decided after Phase A classification (inventory thin + single-question scope → offer quick mode).

## Key Insights
- **Opening Inventory rule (user-originated).** By end of Phase A, all major concerns named. Phase B refines, does not discover. Acknowledge explicitly if a new first-order concern surfaces in Phase B as a Phase A miss. This is the anti-drip-feed rule.
- **Mentor circuit breaker (user-originated).** Diminishing returns detector + session fatigue signal + pushback budget. The novel contribution vs superpowers `/brainstorming` and other brainstorm skills.
- **Dogfooding as validation.** Using `.brainstorms/<YYYY-MM-DD-slug>/` convention for this brainstorm itself — if the convention feels right here, that's a signal.

## Tensions
- **Inventory upfront vs Socratic drilling.** These are opposite philosophies. Likely resolution: Inventory = enumeration (list all concerns, shallow), Drilling = one-at-a-time (deep on selected concern). But rule needs explicit arbitration.
- **Type-based phase structure vs uniform phase structure.** If creative brainstorms need divergent-then-prune and decision brainstorms need pressure-test, the phase shape is type-dependent. This is heavier design than "same phase structure, different lenses."
- **Mentor voice wants to stop vs Opening Inventory wants to be exhaustive.** Circuit breaker says "call it." Inventory rule says "surface more." Resolution lives in Phase B: inventory caps at Phase A boundary; Phase B is refinement only.

## Discarded
- Chassis + overlay refactor (Option A). Rejected by user because outcome taxonomy and done signal differ materially between generic and skill brainstorm.
- Mandatory "implementation follows" gate (copied from superpowers). Rejected — generic brainstorm shouldn't mandate a next skill; the memo is the artifact, user decides.
- Fires-on-any-creative-work trigger. Rejected as routing trap (confirmed via superpowers issue #178).
- LLM-based handoff routing. Rejected in favor of deterministic shape→skill map; later further simplified to "no map, just prose next-steps suggestion in memo."
- Deterministic shape→skill handoff map. Rejected in favor of simpler "memo at end + prose suggestion" — keeps skill small, avoids rigidity of 1:1 mapping.
- **Three phase-structure archetypes as mutually exclusive (Pressure-test / Generate-prune / Decompose-sequence).** Rejected after user correction — archetypes conflated moves with phase structures. Real brainstorms use a mix of moves within a single Phase B, and the critical discipline is circle-back, not archetype selection.
- Hardcoded numeric thresholds for mentor circuit breaker. Rejected in favor of LLM-judgment + user-prompt.
- 7 lenses fire every session. Rejected in favor of 4-per-session (2 universal + 2 type-specific).

## Lens Notes
<!-- Phase B only. Populated after lens rotation. -->
### Usability
Passes. Resolutions:
- Description uses explicit trigger phrases ("help me think through," "should I," "I'm debating," "I have an idea for," "I'm not sure how to approach") + explicit exclusions (factual Q, implementation, skill-design).
- Output shape (internal memo structure) previewed at Phase A Gate so user knows what memo format to expect.
- Resume uses exact slug match only. `/brainstorm` with no topic → list recent sessions.
- Residual risk: description-routing reliability (universal risk), mitigated by trigger phrase explicitness.

### Robustness
Passes. Resolutions:
- **Thread relationships tracked lightweight in notepad `Connections` section.** Coach populates opportunistically during Reframe/Circle-back. Not a full graph — just observed links between threads. Ties to admission protocol's "sweep downstream effects" step.
- **Cheerleader drift prevented structurally.** Thread `open → resolved` requires prior application of the 2 universal lenses (Stakeholder + Alternative). Agreement without lens gate = rejected by coach itself. Makes cheerleading impossible, not just discouraged.
- **Global vs local default = invocation context.** In git repo → `.brainstorms/`, otherwise `~/.claude/brainstorms/`. No topic-based auto-override. User overrides explicitly.
- **Session-state corruption handled loudly.** Notepad = source of truth; coach trusts manual edits between turns. Missing/corrupt `meta.yaml` → offer fresh start or reconstruct from notepad. Never silent data loss.
- **Coach failure modes named explicitly.** Premature convergence prevented by Circle-back reopening any thread that closed without lens rotation. Memo-before-Done-Signal prevented by existing coaching-policy.md rule ("Never Produce the Memo Prematurely").

### Maintenance
Passes. Resolutions:
- **Connections section in notepad is prose cross-references, NOT a formal knowledge graph.** Format: "Thread X ↔ Thread Y: brief reason." No typed edges. Coach reads like footnotes.
- **No mid-session handoff.** `/skill-brainstorm` referenced only in Phase A wrong-tool detection (pre-skill redirect). No other mid-session skill coupling.
- **Dropped `/skill-router` reference entirely.** Not useful for `/brainstorm`.
- **`meta.yaml` schema-versioned from day one** (`schema_version: 1`). Upgrade-in-place on older versions; loud refusal on newer.
- **SKILL.md body lean.** Move set, type taxonomy, lens catalog all live in dedicated `references/*.md` files. Body refers by name only, loaded on-demand.
- **Trigger phrase drift detected via `EVAL.md`.** Not preventable; acceptable long-tail managed through eval-driven refresh.
- **Pipeline integration with `/autonomous-orchestrator` out of scope** for initial skill. If added later, memo output becomes typed stage input — future refactor.

### Preciseness
### Preciseness
Passes. Resolutions:
- **All 7 moves earn their place.** Vocabulary test passed this session — every coach activity mapped to a named move.
- **5 brainstorm types kept.** Exploratory vs planning boundary: planning has options known upfront (sequencing question); exploratory has options unknown (divergent first). Different Phase B move mixes. Worth the extra type; revisit if practice shows overlap.
- **7 outcome shapes kept.** Defer (revisit later) vs Abandon (done for good) are genuinely distinct. Decompose (multi-session outcome) vs Plan (single-session sequencing) are distinct.
- **7 generic lenses kept.** 4 per session (2 universal + 2 type-specific); all 7 used across the 5 types.
- **SKILL.md body stays lean (~80-120 lines).** Mental model + phase overview + pointers to 9 companion files:
  - `references/moves.md`, `references/brainstorm-types.md`, `references/lens-catalog.md`, `references/coaching-policy.md`, `references/wrong-tool-detection.md`, `references/mentor-circuit-breaker.md`
  - `templates/notepad.md`, `templates/memo.md` (with 7 shape variants), `templates/meta.yaml`
- **9 companion files accepted as reasonable spread.** Loaded on-demand; each ~50-100 lines.

### Boundary
Passes. Resolutions:
- **`/brainstorm` vs `/skill-brainstorm` boundary explicit.** Skill-shaped topics (mentions "skill," "SKILL.md," slash command, agentic behavior) redirect.
- **`/brainstorm` vs implementation skills boundary explicit.** Skill stops at memo; does not produce code, specs, or plans directly. Prose suggestions for next steps.
- **CORRECTED rule for implementation boundary:** direction-based, not verb-based. `/brainstorm` fires when user lacks clear direction, regardless of verb used ("build," "write," "implement" are not exclusion triggers). Exclusion trigger is *specificity* — user has clear spec/plan already = not brainstorm.
- **`/brainstorm` vs default collaborative thinking boundary explicit in description.** Invoke only when problem is big enough for structured pressure-test, multi-turn thread tracking, memo artifact, or pause/resume.
- **`/brainstorm` vs `/autonomous-orchestrator` boundary explicit.** `/brainstorm` = interactive ad-hoc; orchestrator = multi-stage pipelines. Parallel, not subsumed.
- **Wrong-Tool Detection covers 5 collision points:** skill-shaped, implementation-ready, factual Q, specific bug, pipeline end-to-end.
- **"Out of scope" section in SKILL.md — confirmed explicit.** Lists: no formal decision analysis (MCDA), no multi-stakeholder facilitation, no external research synthesis, no artifact production (stops at memo), no end-to-end pipeline drive.
- **Agent-to-agent brainstorm flagged as future question, out of scope for initial design.** Would require both sides empowered to pressure-test, no pause-for-consent gates, different Done Signal (agent consensus).

## Companion Files Anticipated
### references/ — domain knowledge to load on-demand
- `brainstorm-types.md` — the 5 types (decision / exploratory / problem / creative / planning) with diagnostic questions for classification.
- `lens-catalog.md` — the 7 generic lenses with diagnostic questions, selection guidance by type.
- `phase-structures.md` — if different types need different phase flows (unresolved — see tensions).
- `mentor-circuit-breaker.md` — heuristics for diminishing-returns detection, session fatigue, pushback budget.
- `coaching-policy.md` — adapted from skill-brainstorm, shifted to generic voice.
- `wrong-tool-detection.md` — heuristics for detecting when to redirect (skill topic → skill-brainstorm; factual Q → just answer; bug → debug).

### templates/ — output format skeletons
- `notepad.md` — scratchpad format (adapted from skill-brainstorm template).
- `memo.md` — decision memo with shape-specific sections + deterministic handoff row.
- `meta.yaml` — session metadata (status, topic, type, shape, last-updated).

### rules/ — hard constraints
- Maybe: `do-not-drift.md` — rules against opening new concerns in Phase B.

### examples/ — worked examples
- At least one per brainstorm type (5 examples) showing full session arc.
