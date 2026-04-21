---
name: execution-trace
description: "Structured self-report trace appended by subagents when an observer requests execution observability"
domain: observability
type: trace
tags: [execution-trace, self-reported, subagent-observability]
---

# Execution Trace Protocol

A structured self-report appended by a subagent to its response when an observer requests execution observability. Zero overhead in normal runs — only injected when someone is watching.

## When This Protocol Is Used

An **observer** (improve-skill grading EVAL-E, auto-research optimizing, user debugging) injects this protocol's capture instructions into a subagent's prompt. The subagent executes the skill normally, then appends a trace block describing what it did.

The skill itself never references this protocol. It is injected externally.

## Trace Schema

The subagent appends this YAML block at the end of its response:

```yaml
## Execution Trace

phases_executed: [0, 1, 2, 3]        # which phases ran (by number or name)
test_file_count: 12                   # relevant input count (if applicable)

agents_dispatched:
  - phase: 1                          # which phase triggered this dispatch
    purpose: scan test file            # what the agent does
    target: tests/test_auth.py         # file or resource targeted
    model: sonnet                      # model explicitly set on Agent()
  - phase: 2
    purpose: cross-match ACs
    model: opus

workflow_decisions:
  - decision: subagent dispatch strategy
    chose: per-file dispatch
    reason: "12 test files >= 10 threshold"
  - decision: intent document source
    chose: spec (docs/auth/SPEC.md)
    reason: "spec exists — higher priority than eng-guide"

precondition_checks:
  - check: intent document exists
    result: pass
    path: docs/auth/SPEC.md
  - check: test directory exists
    result: pass
    path: tests/

context_isolation:
  phase1_prompt_contains_acs: false    # key isolation invariant
  phase1_prompt_contains_spec: false   # another isolation check
```

## Field Definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `phases_executed` | list | yes | Phases that ran, in execution order |
| `agents_dispatched` | list of objects | yes (if any) | Each Agent() call with phase, purpose, target, model |
| `workflow_decisions` | list of objects | yes (if any) | Key branching decisions with what was chosen and why |
| `precondition_checks` | list of objects | yes (if any) | Input validations with pass/fail result |
| `context_isolation` | object | no | Boolean flags for what was deliberately excluded from subagent prompts |

Additional fields may be added for skill-specific trace needs. The schema is extensible.

## Nesting Configuration

| Mode | Behavior | When to use |
|------|----------|-------------|
| `shallow` (default) | Trace only the top-level skill execution. Subagents dispatched by the skill are listed in `agents_dispatched` but do not produce their own traces. | Most evaluation and debugging scenarios |
| `deep` | Each subagent also appends its own execution trace (recursive). The top-level trace contains nested traces. | Diagnosing issues in subagent behavior, not just dispatch |

The observer specifies nesting depth when injecting. Default is `shallow`.

## Injection Instructions

The observer appends the following to the subagent prompt that will execute the skill:

```
---
After completing the task above, append an `## Execution Trace` section to your
response. Record the following in YAML format:

- phases_executed: list of phases that ran (by number or name)
- agents_dispatched: for each Agent() call, record phase, purpose, target, and model
- workflow_decisions: for each key branching decision, record what was decided,
  what was chosen, and why
- precondition_checks: for each input validation, record what was checked and
  whether it passed or failed
- context_isolation: boolean flags for what was deliberately excluded from
  subagent prompts (e.g., phase1_prompt_contains_acs: false)

Nesting: [shallow|deep]. [If shallow: do not ask your subagents to produce traces.
If deep: append these same trace instructions to every Agent() call you make.]
```

## Persistence

When the observer wants traces saved to disk, it writes the trace YAML to a file after receiving the subagent response. Suggested locations:

- During evaluation: `[workspace]/run-[N]/prompt-[ID]/trace.yaml`
- During debugging: `[skill-dir]/traces/[timestamp].yaml`
- During auto-research: `[skill-dir]/research/traces/iteration-[N].yaml`

The trace protocol does not specify where to save — the observer decides.

## Consumers

| Consumer | Reads trace for | Injects when |
|----------|----------------|--------------|
| improve-skill | Grading EVAL-E criteria | EVAL.md contains `## Execution Criteria` |
| auto-research | Optimizing agent dispatch, model selection | Measuring cost/performance per iteration |
| User (debugging) | Understanding why a skill behaved unexpectedly | On demand |
