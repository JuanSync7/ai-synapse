# Escalation Handler & Checkpoint Persistence

## ESCALATE Protocol

When stakeholder-reviewer returns ESCALATE at any gate:

### Step 1: Log the Escalation

Record in the checkpoint state:
- Which stage and iteration triggered the ESCALATE
- The `ESCALATE_REASON` — always phrase as a **specific, answerable question** that a human can resolve with a concrete decision. Never use vague phrasing like "needs review" or "design needs work".
  - **Good:** "Should caching be per-user or global? Per-user aligns with multi-tenant architecture but adds memory overhead."
  - **Bad:** "The caching approach needs further discussion."
- The full context that was being evaluated (approach options, design section, etc.)

### Step 2: Make a Provisional Call

The orchestrator picks the option most aligned with the stakeholder persona:
- Check which option best matches stated Priorities and Decision Heuristics
- Tag the choice as `provisional: true`
- Record the reasoning: "Chose [X] because [persona alignment reason]"

### Step 3: Continue the Pipeline

- All downstream stages inherit the `provisional` tag
- The checkpoint state records the branch point
- Downstream stages operate normally but their work is tagged

### Step 4: Max Provisional Limit

If the pipeline accumulates **3 or more unresolved ESCALATEs**, it pauses:
- Too many provisional decisions stacking means the goal was likely under-specified
- Better to wait for human input than build on a shaky foundation
- Pipeline status set to `escalated`

## Provisional State Format

```yaml
provisional_decisions:
  - stage: brainstorm
    iteration: 2
    question: "Should caching be per-user or global? Persona marks this as high-stakes infra."
    provisional_choice: "per-user — aligns with multi-tenant architecture in existing codebase"
    reasoning: "Codebase already has per-user scoping in auth layer, extending to cache is consistent"
    downstream_affected: [spec, design, impl, code]
```

## Checkpoint State File

Location: `.autonomous/runs/<run-id>/state.yaml`

```yaml
run_id: "2026-03-25-api-caching"
template: full
input: "add caching to the API layer"
started: "2026-03-25T22:00:00Z"
provisional_decisions: []
stages:
  brainstorm:
    status: completed
    output: "docs/superpowers/specs/2026-03-25-api-caching-sketch.md"
    verdict: APPROVE
    iterations: 2
    provisional: false
  spec:
    status: in_progress
    iterations: 1
```

### Status Values

| Status | Meaning |
|--------|---------|
| `pending` | Not yet started |
| `in_progress` | Currently executing |
| `completed` | Finished and approved by stakeholder-reviewer |
| `failed` | Error during execution (retries on resume) |
| `escalated` | 3 REVISE loops exhausted or max provisionals hit |

### Status Transitions

```
pending → in_progress → completed
                     → failed (error during execution)
                     → escalated (3 REVISE loops or max provisionals)
```

## Resume Logic

When a new session starts and finds an incomplete run:

1. Read `.autonomous/runs/` for state files with non-completed stages
2. Present the run summary to the user
3. If the user confirms, resume from the first non-completed stage

**Rules:**
- Completed stages are NOT re-run
- `in_progress` stages restart from the beginning (not mid-iteration)
- `failed` stages retry from scratch
- `escalated` stages wait for human input before proceeding

## Human Return UX

When the human returns (new session or responds to a paused pipeline):

### 1. Present Summary

```
Autonomous Orchestrator — Run: 2026-03-25-api-caching
Template: full
Goal: "add caching to the API layer"

Stages: 5/8 completed, 1 in-progress, 2 pending
  ✅ brainstorm (2 iterations, APPROVED)
  ✅ spec (1 iteration, APPROVED)
  ✅ spec-summary (1 iteration, APPROVED)
  ✅ design (3 iterations, APPROVED)
  ✅ impl (1 iteration, APPROVED)
  🔄 code (in-progress)
  ⏳ eng-guide (pending)
  ⏳ tests (pending)

Provisional decisions: 1
  ⚠️ Stage: brainstorm, iteration 2
     Question: "Should caching be per-user or global?"
     Provisional call: per-user (aligns with multi-tenant architecture)
     Affected stages: spec, design, impl, code
```

### 2. Resolve Provisionals

For each provisional decision, ask:
- **APPROVE** — keep the provisional call and all downstream work
- **OVERRIDE** — provide the correct answer; discard and re-run affected downstream stages

### 3. Resume Pipeline

After resolving provisionals and answering any pending escalations, the pipeline resumes from the first non-completed stage.

## Failure Handling

When a stage throws an error (skill invocation fails, file not found, etc.):

1. Set status to `failed` in checkpoint
2. Log the full error with context
3. Pipeline pauses

On resume:
- Failed stage restarts from scratch
- If the same stage fails **2 times consecutively**, escalate to human
