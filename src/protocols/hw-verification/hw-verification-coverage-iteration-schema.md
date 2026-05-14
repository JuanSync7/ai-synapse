---
name: hw-verification-coverage-iteration-schema
domain: hw-verification
subdomain: execution
subject: coverage-iteration
kind: schema
version: 1
---

# Coverage Iteration Schema

This schema defines the formal state required to orchestrate the coverage feedback loop. It guarantees that the orchestrator and the coverage generation agents agree on the target metrics and the current progression state.

## State Object

When invoking the `hw-verification-coverage-test-generator` skill, the orchestrator must supply the following JSON schema as the primary input:

```json
{
  "target_coverage_pct": 90.0,
  "current_coverage_pct": 0.0,
  "iteration_count": 0,
  "max_iterations": 5,
  "coverage_report_path": "path/to/verilator_coverage.dat",
  "uncovered_bins": [
    "module.signal_name_1",
    "module.state_machine_arc_2"
  ]
}
```

## Policy

1. **Iteration Limit:** The agent must enforce the `max_iterations` limit. If `iteration_count` >= `max_iterations` and `current_coverage_pct` < `target_coverage_pct`, the agent must invoke the `hw-verification-failure-reporting-contract` and fail loudly.
2. **Target Goal:** The loop naturally terminates when `current_coverage_pct` >= `target_coverage_pct`. The agent may exit early if this condition is met.
3. **Data Source:** The `uncovered_bins` must be parsed directly from the Verilator coverage outputs to ensure the agent is targeting mathematically verifiable holes rather than hallucinating test scenarios.
