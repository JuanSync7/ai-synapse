# parallel-agents-dispatch — Evaluation Criteria

## Structural Criteria

(From improve-skill's baseline checklist — evaluated during structural pass)

## Output Criteria

### Wave Plan

- [ ] **EVAL-O01:** Wave plan is presented before any agent dispatch
  - **Test:** Search the output for the wave plan block (listing waves, task assignments, and dependencies). Verify it appears before the first Agent tool call.
  - **Fail signal:** First Agent dispatch occurs without a preceding wave plan, or wave plan is missing entirely.

- [ ] **EVAL-O02:** Dependency analysis is consistent with task inputs/outputs
  - **Test:** For each pair of tasks in the same wave, verify neither reads the other's output and they don't write to the same file. For each task in Wave N+1, verify at least one of its inputs comes from a Wave N task.
  - **Fail signal:** Two tasks in the same wave have a read-write dependency, or a task is placed in a later wave despite having no dependency on earlier waves.

- [ ] **EVAL-O03:** Circular dependencies are detected and surfaced
  - **Test:** If the input contains tasks with mutual dependencies (A needs B's output, B needs A's output), verify the controller identifies the cycle and surfaces it to the user instead of proceeding.
  - **Fail signal:** Controller assigns mutually dependent tasks to waves without flagging the cycle, or silently drops one dependency.

### Agent Dispatch

- [ ] **EVAL-O04:** Every Agent dispatch includes an explicit `model:` parameter
  - **Test:** Inspect every Agent tool call in the output. Each must include a `model:` parameter set to one of haiku, sonnet, or opus.
  - **Fail signal:** Any Agent tool call lacks a `model:` parameter or uses a default/inherited model.

- [ ] **EVAL-O05:** Model selection matches task type
  - **Test:** Cross-reference each Agent dispatch's `model:` value against the model selection table. Mechanical/doc tasks should use haiku, integration/test tasks should use sonnet, review tasks should use opus.
  - **Fail signal:** A mechanical single-file task dispatched with opus, or a review task dispatched with haiku.

- [ ] **EVAL-O06:** Agent prompts contain inlined file contents, not file path references
  - **Test:** Inspect the prompt text of each Agent dispatch. File contents referenced by the task should appear as pasted text within the prompt, not as instructions to read a file path.
  - **Fail signal:** Agent prompt contains directives like "read file X" or "look at contracts/types.py" without the actual file contents pasted inline.

- [ ] **EVAL-O07:** Each agent receives only its own task context
  - **Test:** Verify no agent prompt contains the full plan text, other tasks' descriptions, or other tasks' file contexts.
  - **Fail signal:** An agent prompt includes the complete plan document or another task's requirements/code.

- [ ] **EVAL-O08:** Agent prompts include explicit exclusion statements
  - **Test:** Each agent prompt contains a section or list of files/directories the agent must NOT access.
  - **Fail signal:** Agent prompt omits exclusion constraints entirely — it only includes what to do, not what to avoid.

### Gate Enforcement

- [ ] **EVAL-O09:** No Wave N+1 agent is dispatched before all Wave N agents are reviewed and approved
  - **Test:** Trace the sequence of Agent dispatches and review results. Every agent in Wave N must have a completed spec review (and code quality review if applicable) before any Wave N+1 agent is dispatched.
  - **Fail signal:** A Wave 2 agent is dispatched while a Wave 1 agent still has an open or failing review.

- [ ] **EVAL-O10:** Spec compliance review is dispatched before code quality review for each agent
  - **Test:** For each agent that receives both reviews, verify the spec compliance review completes and passes before the code quality review is dispatched.
  - **Fail signal:** Code quality review dispatched for an agent whose spec compliance review has not yet passed.

- [ ] **EVAL-O11:** Gate tracker is maintained with per-agent status
  - **Test:** After a wave's agents complete, verify a gate checklist is presented showing each task's review status (spec pass/fail, quality pass/fail).
  - **Fail signal:** No gate tracker is shown, or the tracker omits tasks that were dispatched in the wave.

### Shared Write Handling

- [ ] **EVAL-O12:** Tasks writing to the same file use tmp file pattern
  - **Test:** If two or more agents in the same wave would write to the same output file, verify each agent is directed to write to a unique tmp file path under `.parallel-dispatch-tmp/`.
  - **Fail signal:** Two agents in the same wave are directed to write to the same output file path directly.

### Boundary Behavior

- [ ] **EVAL-O13:** Concurrency limit is enforced for large waves
  - **Test:** If a wave contains more than 8 tasks, verify the controller sub-batches into groups of 8 or fewer per dispatch.
  - **Fail signal:** A single Agent tool call dispatches more than 8 agents simultaneously.

- [ ] **EVAL-O14:** Wrong-tool requests are recognized and redirected
  - **Test:** If the input is a planning request (no existing tasks to execute) or a debugging request (ad-hoc failures, no plan), verify the controller redirects to the appropriate skill rather than attempting wave dispatch.
  - **Fail signal:** Controller attempts to assess independence and dispatch waves when there are no existing tasks to execute.

## Test Prompts

### Naive User

#### Naive: Vague plan execution

**Prompt:** "I have a plan in docs/plan.md, can you execute it"

**Why this tests the skill:** Tests whether the skill reads the plan, assesses tasks, and presents a wave plan — or just starts executing sequentially without assessment.

#### Naive: Informal task list

**Prompt:** "i need to fix the auth module, update the docs, and add some tests. can you do all three"

**Why this tests the skill:** Tests whether the skill recognizes these as independent tasks that can be parallelized, even when presented informally without a formal plan document.

#### Naive: Single task disguised as multi

**Prompt:** "run this plan for me, it's just one task though"

**Why this tests the skill:** Tests whether the skill handles the degenerate case (wave of 1) gracefully instead of over-engineering the dispatch.

### Experienced User

#### Experienced: Write-implementation plan with phases

**Prompt:** "Execute the implementation plan at docs/superpowers/plans/2026-03-20-ingest-pipeline.md — it has Phase 0 contracts, Phase A spec tests, Phase B implementation, Phase C docs, and Phase D white-box tests. Use haiku for the mechanical Phase 0 work and opus for the reviews."

**Why this tests the skill:** Tests whether the skill adopts pre-defined phases as waves, respects explicit model selection requests, and handles multi-phase gating correctly.

#### Experienced: ASIC workflow with strict dependencies

**Prompt:** "I have an RTL verification workflow: lint all modules in parallel, then run synthesis on the ones that pass, then run timing analysis which depends on all synthesis outputs. The plan is at asic/plans/tape-out-checklist.md. Each lint task is independent but synthesis depends on lint passing for that module."

**Why this tests the skill:** Tests whether the skill correctly builds a dependency graph with per-task dependencies (not just phase-level), handles a non-software domain, and groups waves based on real dependency analysis rather than just phase labels.

#### Experienced: Shared output document

**Prompt:** "Execute this 6-task plan. Tasks 1-4 are independent but all write a section to docs/CHANGELOG.md. Task 5 depends on task 2, task 6 depends on tasks 3 and 4. Don't let the agents clobber each other on the changelog."

**Why this tests the skill:** Tests whether the skill uses tmp files for shared writes, handles mixed independence (some parallel, some dependent), and correctly merges outputs at the gate.

### Adversarial

#### Adversarial: Circular dependency

**Prompt:** "Execute these tasks: Task A generates the schema that Task B needs, but Task B generates the migration that Task A needs to validate against. They depend on each other. Plan is at docs/plan.md"

**Why this tests the skill:** Tests whether the skill detects circular dependencies and surfaces them to the user instead of silently deadlocking or breaking the dependency.

#### Adversarial: Massive wave size

**Prompt:** "I have 30 independent lint tasks to run. Execute them all in parallel right now, all at once."

**Why this tests the skill:** Tests whether the skill enforces concurrency limits and sub-batches rather than attempting to dispatch 30 agents simultaneously.

### Wrong Tool

#### Wrong Tool: Wants to create a plan, not execute one

**Prompt:** "I have a spec for a new notification service. Can you break it down into tasks and figure out what can be parallelized?"

**Why this tests the skill:** Tests whether the skill recognizes this is a planning request (needs writing-plans or build-plan) rather than an execution request — no existing task list to dispatch.

#### Wrong Tool: Wants debugging parallelism

**Prompt:** "I have 4 failing test files after a refactor. Can you investigate them all in parallel and fix whatever is broken?"

**Why this tests the skill:** Tests whether the skill recognizes this is ad-hoc debugging (better suited to dispatching-parallel-agents) rather than structured workflow execution from a plan.
