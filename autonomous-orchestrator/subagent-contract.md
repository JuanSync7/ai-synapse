# Subagent Contract

Rules that every subagent dispatched by the autonomous orchestrator must follow. The main orchestrator includes a reference to this file in every subagent dispatch prompt.

## Dispatch Prompt Template

When dispatching a subagent, the main orchestrator sends a prompt structured as:

```
You are a subagent of the autonomous-orchestrator pipeline.

**Goal:** <one-sentence goal>
**Stage:** <stage_name> (e.g., spec, design, impl, code, eng-guide, test-docs, tests)
**Input artifact:** <file path to read> (read this file for context — do not ask the orchestrator for its content)
**Skill to invoke:** /<skill-name>
**Gate context_type:** <context_type>
**Max revision iterations:** 3

Follow the subagent contract below.

<contents of subagent-contract.md>
```

## Subagent Responsibilities

### 1. Read your input — never ask for content

You receive an input artifact **path**. Read it yourself. The main orchestrator does not carry document content — asking for it wastes tokens and may get a stale or empty answer.

### 2. Invoke the skill

Use the Skill tool to invoke the skill listed in your dispatch prompt. Follow it fully.

### 3. Handle the revision loop

After producing your output, submit it to the stakeholder-reviewer (subagent, set `model:` explicitly) with the `context_type` from your dispatch prompt.

- **APPROVE** — you are done. Proceed to cleanup and return.
- **REVISE** — apply the feedback, regenerate, and re-submit. Max 3 consecutive REVISE verdicts; if you hit 3 without APPROVE, return with `verdict: ESCALATE` and the latest feedback.
- **ESCALATE** — return immediately with `verdict: ESCALATE` and the escalation reason.

### 4. Self-critique before every gate submission

Before each stakeholder-reviewer submission, apply the smell test:
- State the recommendation
- State the strongest counter-argument
- Explain why the recommendation stands despite the counter-argument

Do not use straw-man counter-arguments. If you cannot articulate a real counter-argument, the recommendation may be obvious enough that it does not need defense — state that instead.

### 5. Clean up your tasks before returning

Before returning your result to the main orchestrator:

1. Run `TaskList` to find all tasks you created during this work.
2. Mark every one as `completed` or `deleted`.
3. Do not leave any tasks in `pending` or `in_progress` state.

**Why:** Orphaned tasks confuse the user — their task list shows phantom in-progress items for work that is already done. You own your tasks; clean them up.

### 6. Return format

Return a single message with exactly these fields:

```
output_path: <path to the artifact you produced>
verdict: APPROVE | ESCALATE
iterations: <number of revision rounds>
escalation_reason: <only if verdict is ESCALATE>
```

Do not return full document content. The main orchestrator reads the file at `output_path` only if needed.

## What You Must NOT Do

- **Do not read artifacts from other stages** unless they are listed as your input. You have one input — use it.
- **Do not modify state.yaml** — the main orchestrator owns the state file.
- **Do not dispatch further pipeline stages** — you are one stage. Return when done.
- **Do not carry over context from the main orchestrator** — you start fresh. Your dispatch prompt is your full context.
