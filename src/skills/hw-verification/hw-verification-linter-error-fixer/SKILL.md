---
name: hw-verification-linter-error-fixer
description: "Fires when the Verilator simulation compilation fails or outputs lint warnings/errors."
domain: hw-verification
intent: fix
tags: [verilator, linting, syntax-correction]
user-invocable: true
argument-hint: "[verilator-log-path] [source-dir]"
---

# Linter Error Fixer

This skill orchestrates the resolution of SystemVerilog compilation and linting errors. Think of it as a bridge between the simulator's output and the `hw-verification-linter-agent`.

## Preconditions

You must verify that the `[verilator-log-path]` exists and contains text before proceeding. 
*Failure mode: Running the linter agent with an empty log will cause it to hallucinate changes to the codebase.* If the log is empty, fail loudly.

## Mechanics

1. Read the provided Verilator log.
2. If there are no errors or warnings, terminate successfully.
3. Otherwise, dispatch the `hw-verification-linter-agent` with the log contents and the source directory path.
4. Verify the agent successfully completed the task without emitting a failure report (per `hw-verification-failure-reporting-contract`).
5. Return the list of modified files back to the user.
