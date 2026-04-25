# SCOPE.md — Format Specification

A capability profile for model migration decisions. Answers: can a smaller model run this skill?

This artifact is **not** read during skill execution — only during improvement and migration workflows.

## Template

```markdown
# [Skill Name] — Capability Profile

long-context: yes|no      # Does it need to process >10K token inputs?
tool-use: yes|no          # Does it call tools via MCP or similar?
multi-step-reasoning: yes|no  # Does it chain multiple judgment calls?
code-generation: yes|no   # Does it produce code as output?
minimum-model-tier: frontier|mid|small

## Notes
[One or two sentences on what specifically demands the minimum tier.
E.g., "Needs frontier because Phase 2 requires synthesizing 12 design
principles into coherent judgment calls — smaller models follow rules
literally but miss edge cases."]
```

## Filled example — skill-creator

```markdown
# skill-creator — Capability Profile

long-context: no
tool-use: yes             # Dispatches agent definitions (skill-eval-prompter, skill-eval-judge, skill-eval-auditor) and /improve-skill
multi-step-reasoning: yes # 7-phase workflow with judgment calls at each gate
code-generation: no
minimum-model-tier: frontier

## Notes
Needs frontier because Phase 2 requires synthesizing design principles into
opinionated SKILL.md instructions — mid-tier models produce generic, hedging
language ("consider", "you might") that fails the discipline requirements.
```

## Filled example — simple formatting skill

```markdown
# sv-header-formatter — Capability Profile

long-context: no
tool-use: no
multi-step-reasoning: no  # Pure template fill from structured input
code-generation: yes      # Produces SystemVerilog
minimum-model-tier: small

## Notes
Template-driven, no judgment needed. Any model that can follow a template
and produce valid SystemVerilog syntax is sufficient.
```

## When to create

During Phase 2 for every non-trivial skill. When porting skills to cheaper models, this file is the migration guide — it tells you which skills are candidates (small/mid tier) and which must stay on frontier.
