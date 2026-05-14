---
name: hw-verification-failure-reporting-contract
domain: hw-verification
subdomain: observability
subject: failure-reporting
kind: contract
version: 1
---

# Failure Reporting Contract

This protocol defines the exact behavior expected of all `hw-verification` agents when they encounter an unresolvable failure, such as a Verilator compilation crash, a linting error that cannot be automatically fixed, or an inability to hit the 90% coverage target after a defined number of attempts.

## Core Principle

Agents must **fail loudly**. Silently ignoring Verilator warnings, hallucinating passing testbenches, or entering infinite loops is strictly prohibited. When an agent cannot proceed, it must emit a standardized failure trace and halt.

## Failure Trace Schema

When failing, the agent must output a markdown block formatted exactly as follows:

```yaml
type: failure_report
severity: <critical | warning | block>
source_agent: <agent-slug>
failing_tool: <verilator | uvm | internal>
```

### [Description]
A human-readable explanation of why the agent is failing and why it cannot self-correct.

### [Last Tool Output]
The raw terminal output from the tool that failed (e.g., Verilator compilation error or UVM fatal error).

### [Proposed Action]
What the user needs to manually fix before invoking the agent again.

## Enforcement
Orchestrator agents (`hw-verification-loop-orchestrator`) are required to listen for this format and immediately escalate the failure to the user interface, halting the simulation loop.
