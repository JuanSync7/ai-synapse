# Protocol Registry

Behavioral contracts injected into agents by consuming skills. Before creating a new protocol, check if one already covers the behavioral contract you need.

| Protocol | Description | Domain | Type | Consumers |
|----------|-------------|--------|------|-----------|
| [execution-trace](src/protocols/traces/execution-trace.md) | Structured self-report trace for subagent observability | observability | trace | improve-skill, auto-research |
| [failure-reporting](src/protocols/failure-reporting/failure-reporting.md) | Standardized failure tag format for agents and protocols | observability | schema | all agents, all protocols |
