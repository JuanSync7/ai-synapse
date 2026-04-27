# Output Criteria Template

<!-- Used by skill-eval-judge to structure its output. -->
<!-- Each criterion is a binary pass/fail check against skill output. -->

## Criteria Format

Each criterion MUST use this exact format:

```markdown
- [ ] **EVAL-Oxx:** [Short descriptive name]
  - **Test:** [Exact procedure to verify. Must be objective — no "looks good" or "appropriate"]
  - **Fail signal:** [Observable symptom when the criterion is not met]
```

## Criteria Categories

When writing output criteria, cover these dimensions (include only those relevant to the skill's domain):

### Completeness
Does the output contain all expected sections/components?

### Correctness
Is the content accurate, consistent, and free of contradictions?

### Structure
Does the output follow the expected format and organization?

### Boundary Behavior
Does the output handle edge cases? (empty input, ambiguous input, compound requests)

### Self-Consistency
Do different parts of the output agree with each other? (e.g., a traceability matrix matches the requirements listed above it)

### Actionability
Can someone act on the output without needing to ask clarifying questions?
