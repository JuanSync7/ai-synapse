# Evaluation: hw-verification-linter-error-fixer

## Structural Criteria
- MUST explicitly check that the provided log file exists and is not empty before invoking the agent.
- MUST handle agent failure responses formatted via `hw-verification-failure-reporting-contract`.

## Output Criteria
- Successful fixes MUST output a clean list of the files that were modified.
- If the log is empty, MUST output a loud error and halt.
- If the agent fails, MUST pass the exact `type: failure_report` YAML block back to the user without attempting to rewrite it.

## Test Prompts

### Test 1: Empty Log
**Prompt:**
```
Trigger `hw-verification-linter-error-fixer` with `logs/empty_verilator.log` and `src/rtl/`.
```
**Expected:** Fails loudly because the preconditions failed (log is empty).

### Test 2: Standard Syntax Error
**Prompt:**
```
Trigger `hw-verification-linter-error-fixer` with `logs/missing_semicolon.log` and `src/rtl/`.
```
**Expected:** Parses the log, invokes the linter agent, and outputs that `src/rtl/module.sv` was modified.

### Test 3: Unresolvable Architectural Flaw
**Prompt:**
```
Trigger `hw-verification-linter-error-fixer` with `logs/port_width_mismatch.log` and `src/rtl/`.
```
**Expected:** The linter agent hits its policy constraints and outputs a `failure_report`. The skill catches this and emits the exact failure block back to the user.
