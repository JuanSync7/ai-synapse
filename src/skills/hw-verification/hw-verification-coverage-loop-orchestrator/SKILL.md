---
name: hw-verification-coverage-loop-orchestrator
description: "Fires when the user requests to automatically run simulations and generate tests until a target coverage percentage is reached."
domain: hw-verification
intent: orchestrate
tags: [uvm, verilator, pipeline, automation]
user-invocable: true
argument-hint: "[target-pct] [src-dir] [tb-dir]"
---

# Coverage Loop Orchestrator

This is the master skill that ties the entire `hw-verification` framework together. It executes a continuous build-lint-sim-generate loop until the target coverage is met or an unrecoverable error occurs.

## Preconditions

You must verify that the `[src-dir]` and `[tb-dir]` exist and contain SystemVerilog files. 
*Failure mode: Running the pipeline on empty directories will cause immediate, unhelpful tool crashes.* If directories are invalid, fail loudly.

## Mechanics

1. Initialize a JSON state matching `hw-verification-coverage-iteration-schema` with `current_coverage_pct` = 0 and `iteration_count` = 0.
2. **Begin Loop:**
   - Run the Verilator build command (via mechanical terminal tools).
   - If Verilator fails, invoke `hw-verification-linter-error-fixer`. If the fixer returns a `failure_report`, break the loop and bubble the error to the user.
   - Run the simulation command to generate the `coverage.dat` file.
   - Parse the coverage file to extract `current_coverage_pct` and `uncovered_bins`. Update the JSON schema.
   - If `current_coverage_pct` >= `target_pct`, break the loop and return "Success: Target Reached".
   - Invoke `hw-verification-coverage-test-generator` with the updated schema. If it returns a `failure_report`, break and bubble the error.
   - Increment `iteration_count`. If `iteration_count` >= `max_iterations`, break the loop and emit a `failure_report` indicating "Max Iterations Reached".
3. **End Loop**
