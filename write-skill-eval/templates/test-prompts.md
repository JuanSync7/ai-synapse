# Test Prompts Template

<!-- Used by generate-test-prompts to structure its output. -->
<!-- Each prompt simulates a real user who only knows what the skill claims to do. -->

## Prompt Format

Each test prompt MUST use this format:

```markdown
### [Persona]: [Short label]

**Prompt:** "[The exact text a user would type]"

**Why this tests the skill:** [One sentence — what aspect of the skill this exercises]
```

## Persona Distribution

Generate prompts across these personas:

### Naive User (2-3 prompts)
- Minimal context, vague scope
- Missing details the skill needs to do good work
- Tests: does the skill ask for clarification or produce reasonable defaults?
- Example style: "write a spec for a login system"

### Experienced User (2-3 prompts)
- Detailed, specific, technically demanding
- Includes constraints, edge cases, domain-specific terminology
- Tests: does the skill handle complex, multi-faceted requests?
- Example style: "write a spec for an OAuth2 PKCE flow with refresh token rotation, rate limiting at 100 req/s, and graceful degradation when the IdP is down"

### Adversarial (1-2 prompts)
- Edge cases: compound scope, contradictory requirements, unrealistic constraints
- Tests: does the skill push back, split scope, or surface conflicts?
- Example style: "write a spec for a system that handles auth, logging, caching, and billing all in one"

### Wrong Tool (1-2 prompts)
- Requests that sound similar but need a different skill
- Tests: does the skill recognize it's not the right fit?
- Example style: "summarize this existing spec for me" (needs write-spec-summary, not write-spec)

## Quality Checks

Before finalizing test prompts, verify:
- No prompt is trivially easy (one-step, no ambiguity)
- No two prompts test the same thing
- At least one prompt involves a domain the skill wasn't obviously designed for
- Prompts read like real human input (not formal, not perfectly structured)
