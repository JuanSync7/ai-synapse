# Skill Brainstorm — Evaluation Criteria

## Output Criteria

| ID | Criterion | Pass | Fail |
|----|-----------|------|------|
| EVAL-O01 | Asks diagnostic questions before offering suggestions | First 2+ exchanges are questions exploring the user's problem space | Opens with suggestions or prescriptions before understanding the gap |
| EVAL-O02 | Identifies one of three outcomes (skill / config / not needed) | Explicitly names the outcome and explains why | Defaults to "skill" without evaluating alternatives |
| EVAL-O03 | Creates and maintains a brainstorm notepad | Scratchpad file created after first substantive exchange; updated with resolved/open/discarded items | No notepad, or notepad created but never updated |
| EVAL-O04 | Enters Phase B with relevant lens rotation when outcome is "skill" | At least 3 of 5 lenses applied with lens-specific diagnostic questions | Skips Phase B or applies lenses superficially (no lens-specific questions) |
| EVAL-O05 | Produces decision memo only after Phase B — not prematurely | Memo produced after coach signals "no major gaps remain" | Memo produced before pressure-testing, or before resolving identified gaps |
| EVAL-O06 | Decision memo "Why Claude needs it" describes a concrete failure mode | Specific example of what Claude gets wrong without the injection | Vague improvement claim ("makes output better") without a concrete failure |
| EVAL-O07 | Decision memo includes "Edge cases considered" populated from lens notes | At least 2 edge cases with how each is handled | Section empty, missing, or contains only generic statements |
| EVAL-O08 | Checks SKILLS_REGISTRY.yaml for overlap before producing memo (when available) | Registry consulted; overlaps surfaced if found | Registry not checked, or overlaps ignored |
| EVAL-O09 | Does not force a direction — suggestions framed as questions or paired with alternatives | Suggestions include "what's your instinct?" or present 2+ alternatives | Single suggestion presented as the answer, no alternatives offered |
| EVAL-O10 | Routes to project-level config when idea is a simple rule | Identifies config-appropriate ideas and offers brief nudge without prescribing mechanism | Steers everything toward being a skill regardless of fit |
| EVAL-O11 | Pushes back when user rushes past gaps | Explicitly names remaining gaps and refuses to produce memo | Produces memo on demand without checking for unresolved issues |

## Test Prompts

### EVAL-T01 — Vague idea (diagnostic questions)
> I want Claude to write better tests. Can you help me turn this into a skill?

Expected: Diagnostic questions first — what kind of tests? what does Claude currently produce? what's wrong with that output? is the gap in test structure, coverage strategy, or framework knowledge? Should NOT jump to "here's how to make a test-writing skill."

### EVAL-T02 — Clearly project config (route to config)
> I want Claude to always use our internal logging format when writing code in this repo. Let's make a skill for that.

Expected: Identifies this as project-level config, not a skill. Explains why (one-line rule, project-specific, not reusable). Offers brief nudge of what the config might look like. Does NOT build a skill.

### EVAL-T03 — Skill-worthy idea with blind spots (Phase B)
> I want a skill that generates API documentation from code. It should read the source files and produce OpenAPI specs.

Expected: Phase A confirms skill-worthy. Phase B surfaces blind spots via lenses — usability: "what triggers it?", robustness: "what if the code has no docstrings?", boundary: "how is this different from existing doc skills?", preciseness: "is this teaching Claude something it doesn't know, or just output formatting?"

### EVAL-T04 — Stuck user asks for help (suggest without anchoring)
> I know I want something about code reviews but I can't figure out what Claude is missing. What do you think?

Expected: Offers framings without anchoring. "A few angles — is it your team's specific conventions Claude doesn't know? Security patterns it misses? Or is it more about output format — you want a specific review structure?" Returns ownership: "What resonates?"

### EVAL-T05 — Overlaps existing skill (surface at gate)
> I want to create a skill that reviews stakeholder decisions and gives APPROVE/REVISE/REJECT verdicts.

Expected: During brainstorm or at registry check, surfaces that `stakeholder-reviewer` already exists with similar functionality. Helps user differentiate or decide to enhance the existing skill instead.

### EVAL-T06 — User rushes to memo (push back)
> Ok I think we've talked enough, just give me the decision memo.

Expected: If major gaps remain, pushes back: "I still see [specific gap] as significant. Let's resolve that first." If genuinely done, produces memo. Does NOT silently comply when gaps exist.
