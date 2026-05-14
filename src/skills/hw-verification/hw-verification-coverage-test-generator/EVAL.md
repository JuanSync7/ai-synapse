# Evaluation: hw-verification-coverage-test-generator

## Structural Criteria
- MUST parse and validate the input against `hw-verification-coverage-iteration-schema`.
- MUST terminate immediately if the target coverage is already met.
- MUST explicitly verify that the UVM agent did not edit RTL code.

## Output Criteria
- Valid schema with uncovered bins MUST result in testbench modifications.
- Invalid schema or schema lacking the `uncovered_bins` key MUST result in a loud failure.
- If the UVM agent attempts to modify RTL code, the skill MUST intercept it and fail loudly.

## Test Prompts

### Test 1: Goal Already Met
**Prompt:**
```
Trigger `hw-verification-coverage-test-generator` with `test_data/schema_met.json` (where current_coverage >= target) and `tb/`.
```
**Expected:** Skill reads the schema, sees the goal is met, and exits without invoking the UVM agent.

### Test 2: Standard Missing Bins
**Prompt:**
```
Trigger `hw-verification-coverage-test-generator` with `test_data/schema_missing_bins.json` and `tb/`.
```
**Expected:** Skill invokes the UVM agent, the agent adds constraints to the testbench sequence items, and the skill returns the paths of the modified testbench files.

### Test 3: Agent RTL Violation
**Prompt:**
```
Trigger `hw-verification-coverage-test-generator` with `test_data/schema_missing_bins.json` and a workspace where the agent hallucinated an RTL edit.
```
**Expected:** The skill catches that a non-testbench file was modified, aborts the output, and emits a `failure_report` explicitly stating the agent violated the "Do Not Touch RTL" policy.
