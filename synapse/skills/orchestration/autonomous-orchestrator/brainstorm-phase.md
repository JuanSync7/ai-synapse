# Autonomous Brainstorming Phase

The built-in first stage of the orchestrator. Replaces human Q&A with self-answering, self-critique, and stakeholder validation.

## 4a. Context Gathering (no gate)

Before generating anything, build a comprehensive picture of the project:

1. **Project overview** — read root `README.md` and directory structure
2. **Codebase summaries** — read `@summary` blocks from relevant source files
3. **Existing documentation** — scan `docs/` for specs, designs, engineering guides
4. **Recent history** — check recent git commits for active work and patterns
5. **Stakeholder persona** — load global (`~/.claude/stakeholder.md`) + project-level (`<project-root>/stakeholder.md`)
6. **Parse goal** — extract the objective from the free text input or structured brief

**Output:** An internal context summary (not saved as an artifact). This feeds into the exploration phase.

## 4b. Exploration & Approach Selection (gated)

### Generate Clarifying Questions

Think about what a human brainstorming partner would ask to understand this goal. Generate 3-7 clarifying questions covering:

- **Scope:** What's in and out? Where does this start and end?
- **Constraints:** Performance requirements? Compatibility? Technology restrictions?
- **Integration:** How does this connect to existing components?
- **Success criteria:** How do we know it's done and working?
- **Users/consumers:** Who or what uses this?

### Self-Answer from Context

For each question, answer it using the context gathered in 4a:

1. Check if the answer is directly stated in the goal/brief
2. Check if it can be inferred from the codebase (existing patterns, README, configs)
3. Check if the stakeholder persona provides guidance (priorities, heuristics)
4. If none of the above, state the assumption explicitly

### Smell-Test Each Answer

For each self-answer, ask:
- "Is this the obvious choice? What's the case against it?"
- "Am I assuming this because it's easy, or because it's right?"
- "Would someone with good taste push back on this?"

If the smell test raises doubts, note the alternative and include it in the approach options.

### Constraint Conflict Check

Before producing approaches, scan the constraints and requirements for contradictions:

1. **Identify tension pairs** — requirements that pull in opposite directions (e.g., "real-time" vs "offline-only", "zero cost" vs "high availability")
2. **Test for mutual exclusivity** — can both constraints be satisfied simultaneously? If not, the pair is a hard conflict.
3. **If hard conflicts exist** — do NOT proceed to approach generation. Instead, surface each conflict as a specific escalation question: "Constraints X and Y are mutually contradictory. Which takes priority, or should one be relaxed?" Submit these to the stakeholder-reviewer gate. Each unresolvable conflict becomes an ESCALATE.

### Scope Feasibility Check

Evaluate whether the goal is too large for a single pipeline run:

1. **Count distinct deliverables** — if the goal contains 3+ independent systems/services, it is likely compound scope.
2. **Test decomposability** — can each deliverable be built and validated independently?
3. **If compound scope** — recommend splitting into multiple sequential pipeline runs, each targeting one deliverable. Present the proposed split as an approach option (e.g., "Approach A: tackle all five systems in one run. Approach B: split into 3 focused runs targeting [X], [Y], [Z] respectively."). Flag the single-run approach with a clear warning about risk and scope creep.

### Produce 2-3 Approaches

For each approach:

1. **Name and summary** — one sentence describing the approach
2. **Recommendation reasoning** — why this approach (if recommended)
3. **Devil's advocate** — the strongest argument AGAINST this approach
4. **Trade-offs** — what you gain and what you give up
5. **Persona alignment** — which priorities/heuristics support this approach

Lead with your recommended approach. Explain why despite the devil's advocate case.

### Gate: Stakeholder-Reviewer

Submit the approaches to stakeholder-reviewer with:
- `context_type: approach_selection`
- Include all approaches with full reasoning
- Include self-answered questions and any assumptions made

The reviewer will:
- Check alignment with persona priorities and heuristics
- Probe alternatives (step 3b) — check if non-recommended options better match any heuristic
- Return APPROVE, REVISE (with feedback to reconsider an alternative), or ESCALATE

## 4c. Design Sketch Production (gated)

After approach selection is approved, produce a **design sketch** — not a full technical design.

### Sketch Contents

1. **Goal statement** — one paragraph, what this builds and why
2. **Chosen approach** — which approach was selected and the key reasoning
3. **Key decisions** — 3-5 architectural decisions with brief rationale for each
4. **Component/module list** — what pieces need to exist, one line each with responsibility
5. **Scope boundary** — explicit in-scope and out-of-scope lists
6. **Open questions** — anything the brainstormer couldn't resolve (these may become ESCALATEs)

### What This Is NOT

The design sketch is the "what and why." It is NOT:
- A full technical design (that's the `write-design` skill, later in the pipeline)
- A spec with formal requirements (that's `write-spec-docs`)
- An implementation plan with code (that's `build-plan`)

The sketch is a lightweight artifact that gives the next stage enough context to produce its formal output.

### Smell-Test the Sketch

Before submitting to stakeholder-reviewer:
- "Does this feel over-engineered for the stated goal?"
- "Is there a simpler version that still solves the problem?"
- "Are there components listed that aren't strictly necessary? (YAGNI)"

### Gate: Stakeholder-Reviewer

Submit with `context_type: design_approval`. The reviewer checks:
- Does the sketch align with persona priorities?
- Are there red flags (scope creep, unnecessary complexity, missing boundaries)?
- Are the key decisions consistent with decision heuristics?

### Output

Save the approved sketch to: `docs/superpowers/specs/<date>-<topic>-sketch.md`

This file becomes the input for the next pipeline stage (usually `spec` or `design`).

## Self-Critique Protocol

This applies to EVERY submission to stakeholder-reviewer throughout the orchestrator, not just the brainstorming phase.

Before submitting:

1. **State the recommendation** — what you're proposing and why
2. **State the strongest counter-argument** — the best reason NOT to do this
3. **Defend or adjust** — explain why the recommendation stands despite the counter-argument, or adjust if the counter-argument is actually stronger

This is the "taste" mechanism. It forces every recommendation to be earned, not assumed. If the counter-argument is stronger than the recommendation, switch — don't defend a weaker position just because you proposed it first.

### Anti-Pattern: Rubber-Stamping

Do NOT submit to stakeholder-reviewer with:
- "This is the only reasonable approach" (there's always an alternative)
- "No significant trade-offs" (there are always trade-offs)
- Counter-arguments that are straw men ("the alternative would be to do nothing")

A real counter-argument names a specific alternative and a specific advantage it has.
