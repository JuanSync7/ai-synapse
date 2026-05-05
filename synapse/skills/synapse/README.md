# synapse

Framework-level meta-skills that operate across artifact types in ai-synapse. These are the consolidated creators, improvers, and eval-writers that succeed the per-type creator skills under `skill/`, `protocol/`, `agent/`, and `tool/`.

## Skills

| Skill | Intent | Description |
|-------|--------|-------------|
| [synapse-creator](synapse-creator/) | write | Router-based unified creator — routes to type-specific creation flow for skill, protocol, agent, or tool |
| [synapse-external-validator](synapse-external-validator/) | validate | Suite-level structural sweep — validates every artifact in an external submodule before it is wired into ai-synapse |
