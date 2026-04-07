# parallel-agents-dispatch — Test Prompts

## Naive User

### Naive: Vague plan execution

**Prompt:** "I have a plan in docs/plan.md, can you execute it"

**Why this tests the skill:** Tests whether the skill reads the plan, assesses tasks, and presents a wave plan — or just starts executing sequentially without assessment.

### Naive: Informal task list

**Prompt:** "i need to fix the auth module, update the docs, and add some tests. can you do all three"

**Why this tests the skill:** Tests whether the skill recognizes these as independent tasks that can be parallelized, even when presented informally without a formal plan document.

### Naive: Single task disguised as multi

**Prompt:** "run this plan for me, it's just one task though"

**Why this tests the skill:** Tests whether the skill handles the degenerate case (wave of 1) gracefully instead of over-engineering the dispatch.

## Experienced User

### Experienced: Write-implementation plan with phases

**Prompt:** "Execute the implementation plan at docs/superpowers/plans/2026-03-20-ingest-pipeline.md — it has Phase 0 contracts, Phase A spec tests, Phase B implementation, Phase C docs, and Phase D white-box tests. Use haiku for the mechanical Phase 0 work and opus for the reviews."

**Why this tests the skill:** Tests whether the skill adopts pre-defined phases as waves, respects explicit model selection requests, and handles multi-phase gating correctly.

### Experienced: ASIC workflow with strict dependencies

**Prompt:** "I have an RTL verification workflow: lint all modules in parallel, then run synthesis on the ones that pass, then run timing analysis which depends on all synthesis outputs. The plan is at asic/plans/tape-out-checklist.md. Each lint task is independent but synthesis depends on lint passing for that module."

**Why this tests the skill:** Tests whether the skill correctly builds a dependency graph with per-task dependencies (not just phase-level), handles a non-software domain, and groups waves based on real dependency analysis rather than just phase labels.

### Experienced: Shared output document

**Prompt:** "Execute this 6-task plan. Tasks 1-4 are independent but all write a section to docs/CHANGELOG.md. Task 5 depends on task 2, task 6 depends on tasks 3 and 4. Don't let the agents clobber each other on the changelog."

**Why this tests the skill:** Tests whether the skill uses tmp files for shared writes, handles mixed independence (some parallel, some dependent), and correctly merges outputs at the gate.

## Adversarial

### Adversarial: Circular dependency

**Prompt:** "Execute these tasks: Task A generates the schema that Task B needs, but Task B generates the migration that Task A needs to validate against. They depend on each other. Plan is at docs/plan.md"

**Why this tests the skill:** Tests whether the skill detects circular dependencies and surfaces them to the user instead of silently deadlocking or breaking the dependency.

### Adversarial: Massive wave size

**Prompt:** "I have 30 independent lint tasks to run. Execute them all in parallel right now, all at once."

**Why this tests the skill:** Tests whether the skill enforces concurrency limits and sub-batches rather than attempting to dispatch 30 agents simultaneously.

## Wrong Tool

### Wrong Tool: Wants to create a plan, not execute one

**Prompt:** "I have a spec for a new notification service. Can you break it down into tasks and figure out what can be parallelized?"

**Why this tests the skill:** Tests whether the skill recognizes this is a planning request (needs writing-plans or write-implementation) rather than an execution request — no existing task list to dispatch.

### Wrong Tool: Wants debugging parallelism

**Prompt:** "I have 4 failing test files after a refactor. Can you investigate them all in parallel and fix whatever is broken?"

**Why this tests the skill:** Tests whether the skill recognizes this is ad-hoc debugging (better suited to dispatching-parallel-agents) rather than structured workflow execution from a plan.
