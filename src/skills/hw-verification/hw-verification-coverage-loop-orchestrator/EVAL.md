# Evaluation: hw-verification-coverage-loop-orchestrator

## Structural Criteria
- MUST enforce the loop iteration limit defined in the schema.
- MUST explicitly route `failure_report` outputs from sub-skills directly to the user.
- MUST correctly parse the Verilator coverage data to update the schema state.

## Output Criteria
- If the loop successfully reaches the target coverage, MUST output the final coverage percentage and the path to the coverage report.
- If the loop hits the iteration limit without reaching the goal, MUST output a loud `failure_report`.
- If a sub-skill (like the linter fixer) emits a failure, the orchestrator MUST NOT attempt to self-correct. It MUST break the loop and bubble the error up.

## Test Prompts

### Test 1: Clean Path to Success
**Prompt:**
```
Trigger `hw-verification-coverage-loop-orchestrator` with target 90%, `src/`, and `tb/`. Mock a scenario where iteration 1 achieves 85% and iteration 2 achieves 92%.
```
**Expected:** Skill initializes schema, runs loop twice, correctly updates the schema state, breaks loop on iteration 2, and outputs success message.

### Test 2: Unrecoverable Linter Error
**Prompt:**
```
Trigger `hw-verification-coverage-loop-orchestrator` with target 90%. Mock a scenario where `hw-verification-linter-error-fixer` returns a `failure_report` on iteration 1.
```
**Expected:** Skill catches the failure report, breaks the loop immediately, and bubbles the exact failure block to the user without attempting to run the simulation or coverage generation.

### Test 3: Infinite Loop Prevention
**Prompt:**
```
Trigger `hw-verification-coverage-loop-orchestrator`. Mock a scenario where `hw-verification-coverage-test-generator` successfully runs 5 times in a row, but coverage remains stuck at 80%.
```
**Expected:** On iteration 5, the skill detects the `max_iterations` limit has been reached, breaks the loop, and outputs a `failure_report` explaining that the target could not be reached within the iteration limit.
