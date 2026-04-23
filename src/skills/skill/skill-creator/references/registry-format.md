# Registry Format

Loaded at [R] Register. Covers both the markdown catalog and the YAML pipeline config.

---

## SKILL_REGISTRY.md — Always Required

Every new skill gets a row in `registry/SKILL_REGISTRY.md`:

```
| [skill-name](../src/skills/<domain>/<skill-name>/SKILL.md) | One-line description | `<domain-dir>` | `<stage-name>` or `—` | stable |
```

### Detail Sections (Conditional)

An entry gets a detail section below the summary table if ANY of these are true:
- It has contracts (consumes/produces beyond trivial)
- It contains tier 2 companion artifacts
- It has non-obvious dependency relationships

Otherwise, the table row is sufficient.

Detail section structure:

```markdown
### <skill-name>
**Consumes:**
| Artifact | Contract | Required? |
|----------|----------|-----------|

**Produces:**
| Artifact | Contract | Consumers |
|----------|----------|-----------|

**Contains:**
| Type | Name | Purpose | Promotion |
|------|------|---------|-----------|
```

### `contains` Field — Tier 2 Companions

When the skill has tier 2 companion artifacts (generic pattern, one consumer), add them to the Contains table:

```
| agent | design-doc-producer | produces design doc from notepad | candidate |
```

**Tier definitions:**
- **Tier 1 — super specific (one skill, tightly coupled):** companion file only. No registry mention.
- **Tier 2 — generic pattern, one consumer:** companion file + `contains` entry. Discoverable without promotion.
- **Tier 3 — multiple consumers:** promoted to separate artifact with own registry entry. Original becomes thin invocation config.

Tier decision is based on pattern reusability, not prompt specificity.

---

## SKILLS_REGISTRY.yaml — Conditional

A skill is pipeline-routable if ALL of these are true:
- It consumes a defined input artifact type (not just a user prompt)
- It produces a defined output artifact type (not just a conversational response)
- Other skills could depend on its output as a prerequisite
- It makes sense as a stage in an assembled multi-skill pipeline

If ANY are false → do not add to SKILLS_REGISTRY.yaml. The skill lives in SKILL_REGISTRY.md only.

### YAML Entry Format

```yaml
          - name: <skill-name>
            description: "<one-line description>"
            pipeline:
              stage_name: <stage-name>
              input_type: <type>
              output_type: <type>
              context_type: <type>
              requires_all: [<stage>, ...]   # omit if empty
              requires_any: [<stage>, ...]   # omit if empty
              skippable: true | false
```

### Field Reference

| Field | Description | Notes |
|---|---|---|
| `stage_name` | Short canonical ID | Must be unique across the entire registry |
| `input_type` | What artifact this stage consumes | Use `\|` for union (any one satisfies) |
| `output_type` | What artifact this stage produces | Single type only |
| `context_type` | Stakeholder-reviewer gate type | One of: `qa_answer`, `approach_selection`, `design_approval`, `spec_review`, `code_review`, `doc_review` |
| `requires_all` | Stage names that ALL must complete first | Hard sequential dependencies |
| `requires_any` | Stage names where AT LEAST ONE must complete | Multiple upstream paths valid |
| `skippable` | Can this stage be omitted? | `false` for core artifact stages |

### Concrete Example

```yaml
          - name: write-spec
            description: "Writes a formal requirements specification document"
            pipeline:
              stage_name: spec
              input_type: design_sketch
              output_type: formal_spec
              context_type: spec_review
              requires_all: [brainstorm]
              skippable: true
```

---

## Post-Registration Verification

After registering, verify:
- A row exists in `registry/SKILL_REGISTRY.md` with the correct `stage_name` (if pipeline-routable)
- `stage_name` is unique in `SKILLS_REGISTRY.yaml` (no collision)
- All `requires_all`/`requires_any` values resolve to a known `stage_name` or `built_in`
- The `context_type` is in the allowed list
