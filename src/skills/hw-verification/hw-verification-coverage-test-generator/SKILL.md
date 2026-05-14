---
name: hw-verification-coverage-test-generator
description: "Fires when the orchestrator provides a coverage report indicating missing coverage bins that need to be hit."
domain: hw-verification
intent: generate
tags: [uvm, coverage, constrained-random]
user-invocable: true
argument-hint: "[coverage-schema-json] [testbench-dir]"
---

# Coverage Test Generator

This skill drives the dynamic test generation process. Instead of blindly writing directed tests, it interprets Verilator coverage gaps and instructs the `hw-verification-uvm-agent` to bias random constraints to naturally fall into those holes.

## Preconditions

You must verify that the `[coverage-schema-json]` perfectly matches the structure defined in `hw-verification-coverage-iteration-schema`. 
*Failure mode: If the input schema is malformed or doesn't contain an array of `uncovered_bins`, the UVM agent will hallucinate test scenarios that don't actually improve coverage.* If the schema is invalid, fail loudly.

## Mechanics

1. Parse the JSON coverage schema.
2. If `current_coverage_pct` >= `target_coverage_pct`, terminate successfully without doing anything (the goal is already met).
3. If `uncovered_bins` is empty but the target is not met, fail loudly using the `hw-verification-failure-reporting-contract` (this is a logical contradiction from the coverage tool).
4. Dispatch the `hw-verification-uvm-agent` with the `uncovered_bins` and `testbench-dir`.
5. Verify the agent only returned edits to files ending in `.sv` or `.svh` that reside within the testbench directory (no RTL modifications allowed).
6. Return the list of modified files back to the user/orchestrator.
