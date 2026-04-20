# Structured Brief Template

Use a structured brief when you want more control over the pipeline — especially for overnight runs where the orchestrator can't ask clarifying questions.

## YAML Schema

```yaml
# Required
goal: string              # What to build — one sentence

# Optional — all fields below have sensible defaults
constraints: list[string] # Hard constraints the solution must satisfy
scope_boundary:
  entry: string           # Where the system starts (e.g., "API request received")
  exit: string            # Where the system ends (e.g., "response returned to client")
template: string          # One of: full, feature, bugfix, docs-only (default: full)
stages: list[string]      # Explicit stage list — overrides template if both provided
```

## Precedence Rules

- Treat `stages` and `template` as mutually exclusive
- When both are provided, use `stages` (explicit override wins)
- When neither is provided, default to the `full` template
- When `stages` is provided, validate required predecessors before proceeding

## Examples

### Minimal Brief

```yaml
goal: "Add rate limiting to the API endpoints"
```

Uses the `full` template, no constraints, orchestrator infers scope from codebase.

### Feature Brief

```yaml
goal: "Add a caching layer between the API and database"
template: feature
constraints:
  - Must support per-user cache isolation
  - Must not require Redis in development environment
  - Cache TTL must be configurable per-endpoint
scope_boundary:
  entry: "API request handler receives validated request"
  exit: "Cached or fresh response returned to handler"
```

### Bugfix Brief

```yaml
goal: "Fix race condition in concurrent document ingestion"
template: bugfix
constraints:
  - Must not change the public API contract
  - Fix must be backward-compatible with existing stored documents
```

### Custom Stages

```yaml
goal: "Refactor the retrieval module for better testability"
stages: [brainstorm, design, code, eng-guide, tests]
constraints:
  - No functional changes — behavior must be identical before and after
  - All existing tests must continue to pass
```
