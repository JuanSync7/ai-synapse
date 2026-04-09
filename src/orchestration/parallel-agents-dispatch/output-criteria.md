# parallel-agents-dispatch — Output Criteria

## Wave Plan

- [ ] **EVAL-O01:** Wave plan is presented before any agent dispatch
  - **Test:** Search the output for the wave plan block (listing waves, task assignments, and dependencies). Verify it appears before the first Agent tool call.
  - **Fail signal:** First Agent dispatch occurs without a preceding wave plan, or wave plan is missing entirely.

- [ ] **EVAL-O02:** Dependency analysis is consistent with task inputs/outputs
  - **Test:** For each pair of tasks in the same wave, verify neither reads the other's output and they don't write to the same file. For each task in Wave N+1, verify at least one of its inputs comes from a Wave N task.
  - **Fail signal:** Two tasks in the same wave have a read-write dependency, or a task is placed in a later wave despite having no dependency on earlier waves.

- [ ] **EVAL-O03:** Circular dependencies are detected and surfaced
  - **Test:** If the input contains tasks with mutual dependencies (A needs B's output, B needs A's output), verify the controller identifies the cycle and surfaces it to the user instead of proceeding.
  - **Fail signal:** Controller assigns mutually dependent tasks to waves without flagging the cycle, or silently drops one dependency.

## Agent Dispatch

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

## Gate Enforcement

- [ ] **EVAL-O09:** No Wave N+1 agent is dispatched before all Wave N agents are reviewed and approved
  - **Test:** Trace the sequence of Agent dispatches and review results. Every agent in Wave N must have a completed spec review (and code quality review if applicable) before any Wave N+1 agent is dispatched.
  - **Fail signal:** A Wave 2 agent is dispatched while a Wave 1 agent still has an open or failing review.

- [ ] **EVAL-O10:** Spec compliance review is dispatched before code quality review for each agent
  - **Test:** For each agent that receives both reviews, verify the spec compliance review completes and passes before the code quality review is dispatched.
  - **Fail signal:** Code quality review dispatched for an agent whose spec compliance review has not yet passed.

- [ ] **EVAL-O11:** Gate tracker is maintained with per-agent status
  - **Test:** After a wave's agents complete, verify a gate checklist is presented showing each task's review status (spec pass/fail, quality pass/fail).
  - **Fail signal:** No gate tracker is shown, or the tracker omits tasks that were dispatched in the wave.

## Shared Write Handling

- [ ] **EVAL-O12:** Tasks writing to the same file use tmp file pattern
  - **Test:** If two or more agents in the same wave would write to the same output file, verify each agent is directed to write to a unique tmp file path under `.parallel-dispatch-tmp/`.
  - **Fail signal:** Two agents in the same wave are directed to write to the same output file path directly.

## Boundary Behavior

- [ ] **EVAL-O13:** Concurrency limit is enforced for large waves
  - **Test:** If a wave contains more than 8 tasks, verify the controller sub-batches into groups of 8 or fewer per dispatch.
  - **Fail signal:** A single Agent tool call dispatches more than 8 agents simultaneously.

- [ ] **EVAL-O14:** Wrong-tool requests are recognized and redirected
  - **Test:** If the input is a planning request (no existing tasks to execute) or a debugging request (ad-hoc failures, no plan), verify the controller redirects to the appropriate skill rather than attempting wave dispatch.
  - **Fail signal:** Controller attempts to assess independence and dispatch waves when there are no existing tasks to execute.
