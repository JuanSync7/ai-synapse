# Spec Compliance Reviewer Prompt Template

Use this template when dispatching a spec compliance reviewer. Always use model: opus for reviews.

```
Agent tool:
  model: opus
  subagent_type: general-purpose
  description: "Review spec compliance: [task name]"
  prompt: |
    You are reviewing whether an implementation matches its specification.

    ## What Was Requested

    [FULL TEXT of the task requirements — paste from plan]

    ## What the Implementer Claims They Built

    [Paste the implementer's report verbatim]

    ## CRITICAL: Do Not Trust the Report

    The implementer may be incomplete, inaccurate, or optimistic. Verify
    everything independently by reading the actual code.

    **DO NOT:**
    - Take their word for what they implemented
    - Trust their claims about completeness
    - Accept their interpretation of requirements

    **DO:**
    - Read the actual code they wrote
    - Compare implementation to requirements line by line
    - Check for missing pieces they claimed to implement
    - Look for extra features they didn't mention

    ## Files to Review

    [List exact file paths the implementer modified]

    ## Your Job

    Read the implementation code and verify:

    **Missing requirements:**
    - Did they implement everything requested?
    - Are there requirements they skipped?
    - Did they claim something works but didn't actually implement it?

    **Extra/unneeded work:**
    - Did they build things that weren't requested?
    - Did they over-engineer or add unnecessary features?

    **Misunderstandings:**
    - Did they interpret requirements differently than intended?
    - Did they solve the wrong problem?

    ## Report

    - ✅ **Spec compliant** — all requirements implemented, nothing extra
    - ❌ **Issues found:**
      - Missing: [what's not implemented, with file:line references]
      - Extra: [what was added but not requested]
      - Wrong: [what was misinterpreted]
```

# Code Quality Reviewer Prompt Template

Dispatch ONLY after spec compliance passes. Always use model: opus.

```
Agent tool:
  model: opus
  subagent_type: superpowers:code-reviewer
  description: "Code quality review: [task name]"
  prompt: |
    Review the implementation of [task name] for code quality.

    ## What Was Implemented

    [From implementer's report]

    ## Files Changed

    [Exact file paths]

    ## Review Focus

    In addition to standard code quality:
    - Does each file have one clear responsibility?
    - Are units decomposed for independent testing?
    - Does the implementation follow the plan's file structure?
    - Did this change create or significantly grow large files?
    - Are names clear and accurate?
    - Is there unnecessary complexity?

    ## Report

    - **Strengths:** [what's good]
    - **Issues:**
      - Critical: [must fix]
      - Important: [should fix]
      - Minor: [nice to fix]
    - **Assessment:** Approved | Needs changes
```
