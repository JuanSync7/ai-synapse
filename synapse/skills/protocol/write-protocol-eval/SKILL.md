---
name: write-protocol-eval
description: "Use when asked to generate evaluation criteria for a protocol, or to define conformance tests for a protocol."
domain: synapse
intent: generate
tags: [protocol, eval, conformance-testing]
user-invocable: true
argument-hint: "<protocol-path>"
---

# Write Protocol Eval

> **Status: Draft stub.** This skill will be built when 3+ protocols exist in `src/protocols/`. See GOVERNANCE.md for protocol promotion criteria.

Generates conformance testing criteria for protocol definitions. Conformance testing dispatches an agent with the protocol injected and checks if output conforms to the protocol's schema.

## Wrong-Tool Detection

- **User wants to evaluate a skill** → redirect to `/write-skill-eval`
- **User wants to evaluate an agent** → redirect to `/write-agent-eval`
- **User wants to create a protocol** → redirect to `/protocol-creator`
