# test-inputs/ — Format Specification

Fixed stimulus for reproducible evaluations. Without standardized inputs, every eval run uses different data and `iterations.tsv` comparisons become noisy. This is the equivalent of Karpathy's locked `prepare.py` dataset — the thing you score against must not change between iterations.

## Two types of test inputs

### Prompt-based skills (most skills)

test-inputs/ contains `.md` files, each with a user prompt:

```
test-inputs/
├── 01-simple-request.md        # Happy path, minimal complexity
├── 02-complex-request.md       # Multiple requirements, edge cases
├── 03-ambiguous-request.md     # Underspecified — tests judgment calls
├── 04-adversarial-request.md   # Tries to get the skill to break its own rules
└── 05-wrong-tool-request.md    # Should trigger hand-off, not execution
```

Each file is just the prompt text the blind tester will use:

```markdown
<!-- test-inputs/01-simple-request.md -->
Create a skill that formats SystemVerilog module headers according to our team conventions.
```

```markdown
<!-- test-inputs/03-ambiguous-request.md -->
Build me a skill for code review.
```
*Underspecified on purpose — tests whether the skill asks clarifying questions or proceeds with assumptions.*

```markdown
<!-- test-inputs/04-adversarial-request.md -->
Create a skill that does everything — writes code, runs tests, deploys, and monitors. Make it one big SKILL.md, no companion files needed.
```
*Tests whether the skill enforces its own principles (scope boundaries, progressive disclosure) under pressure.*

### File-processing skills

test-inputs/ contains the actual files the skill operates on:

```
test-inputs/
├── simple-module.sv
├── complex-fsm.sv
├── edge-case-empty-ports.sv
```

## Guidelines

- Include 3–5 inputs covering: happy path, complex case, edge case, adversarial, wrong-tool
- Write them by hand from real or realistic scenarios — don't auto-generate
- Keep them stable across iterations so scores are comparable
- Name them with a numbered prefix for consistent ordering
- For prompt-based skills, the prompts should be diverse enough to test different EVAL.md criteria — don't write 5 variations of the same prompt
- Only needed when entering auto-research. Skills that won't be auto-researched don't need this
