# Execution Agent Prompt Template

Use this template when dispatching an execution agent. The controller fills in every section — the agent receives a complete, self-contained prompt.

```
Agent tool:
  model: [haiku | sonnet | opus — per model selection table]
  subagent_type: general-purpose
  description: "[Wave N] Task: [task name]"
  prompt: |
    You are implementing [task name].

    ## Your Task

    [FULL TEXT of task from plan — paste here, do NOT reference a file path.
     The agent should never need to read the plan file.]

    ## Your Inputs

    [Paste exact file contents inline. Only include files this task needs.
     Example:]

    ### contracts/types.py
    ```python
    [full file contents here]
    ```

    ### src/module.py (lines 45-120 only)
    ```python
    [relevant section only]
    ```

    ## Constraints

    - Do NOT read files outside your task scope
    - Do NOT modify files not listed below
    - You may only modify: [exact list of files]
    - Write outputs to: [exact path or .parallel-dispatch-tmp/waveN-taskX-output.md]

    ## Do NOT Access

    [Explicit list of files/directories the agent must not read.
     This prevents agents from "helpfully" exploring related code.]

    - Do NOT read: [list forbidden paths]
    - Do NOT look at other tasks' test files or implementations

    ## Expected Outcome

    [What "done" looks like:]
    - Tests pass: `pytest tests/path/test_file.py -v`
    - File created/modified: [exact path]
    - [Any other success criteria]

    ## Before You Begin

    If anything is unclear about:
    - The requirements or acceptance criteria
    - Which files to modify
    - Dependencies or assumptions

    Ask now. It is always better to clarify than to guess.

    ## While You Work

    - Follow TDD if the task specifies it
    - Follow existing codebase patterns
    - If a file grows beyond the plan's intent, stop and report as DONE_WITH_CONCERNS
    - If you encounter something unexpected, ask — don't guess

    ## When You're In Over Your Head

    It is always OK to stop and say "this is too hard for me." Bad work is worse
    than no work. Report BLOCKED with what you're stuck on and what kind of help
    you need. The controller can provide more context, re-dispatch with a more
    capable model, or break the task into smaller pieces.

    ## Self-Review Before Reporting

    Before reporting back, review your work:
    - Did I implement everything in the task spec?
    - Did I avoid overbuilding (YAGNI)?
    - Are names clear? Is the code clean?
    - Do tests verify behavior, not just mock behavior?

    Fix issues found during self-review before reporting.

    ## Report Format

    When done, report:
    - **Status:** DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
    - **Files changed:** [exact paths]
    - **What you implemented:** [brief summary]
    - **Tests run:** [command + result]
    - **Self-review findings:** [if any]
    - **Concerns:** [if DONE_WITH_CONCERNS]
```

## Notes for the Controller

- **Pre-read all files** before constructing this prompt. Use Read/Glob to gather content, then paste it in.
- **Never give the agent a file path to read** — always inline the content.
- **Keep the prompt focused** — if you're pasting more than ~1500 lines of code, the task may be too broad.
- **Set the model explicitly** — check the model selection table in SKILL.md.
