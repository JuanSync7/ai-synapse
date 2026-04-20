# Example Verdicts — synapse-gatekeeper

Three complete worked examples. Each shows the full certification report output for a realistic skill, illustrating the expected format and content for each verdict type.

---

## Example 1 — APPROVE

**Input:** `/synapse-gatekeeper src/skills/skill/skill-creator --score 84`

---

```
VERDICT: APPROVE

## Certification Report — skill-creator

### Structural                    ✓
- [x] SKILL.md exists
- [x] EVAL.md exists
- [x] Frontmatter complete (name, description, domain, intent)
- [x] domain `skill.create` in TAXONOMY.md
- [x] intent `write` in TAXONOMY.md
- [x] tags well-formed: [skill, creation, scaffolding, eval]
- [x] user-invocable: true
- [x] argument-hint present: "<skill-name> [--domain <domain>]"
- [x] Domain README (src/skills/skill/README.md) has row for skill-creator
- [x] Name globally unique — no collision in SKILLS_REGISTRY.yaml

### Quality                       ✓
- [x] Description is routing contract ("Use when building a new skill from scratch...")
- [x] Eval score ≥ 80 (provided: 84)
- [x] SKILL.md under 500 lines (412 lines)
- [x] Instructions trace to failure modes
- [x] Wrong-Tool Detection section present
- [x] references/ used correctly (skill-design-principles.md loaded at Phase 3)

### Registry                      ✓
- [x] Not pipeline-routable — inventory entry present with explanatory comment
- [x] No stage_name conflict applicable
```

---

## Example 2 — REVISE

**Input:** `/synapse-gatekeeper src/skills/skill/write-skill-eval --score 76`

---

```
VERDICT: REVISE

## Certification Report — write-skill-eval

### Structural                    ✓
- [x] SKILL.md exists
- [x] EVAL.md exists
- [x] Frontmatter complete (name, description, domain, intent)
- [x] domain `skill.eval` in TAXONOMY.md
- [x] intent `generate` in TAXONOMY.md
- [x] tags well-formed: [eval, skill, test-prompts, output-criteria]
- [x] user-invocable: true
- [x] argument-hint present: "<skill-path>"
- [x] Domain README (src/skills/skill/README.md) has row for write-skill-eval
- [x] Name globally unique — no collision in SKILLS_REGISTRY.yaml

### Quality                       ✗
- [x] Description is routing contract
- [ ] Eval score ≥ 80 (provided: 76 — below threshold)
- [x] SKILL.md under 500 lines (338 lines)
- [x] Instructions trace to failure modes
- [x] Wrong-Tool Detection section present
- [x] references/ used correctly

### Registry                      ✓
- [x] Not pipeline-routable — inventory entry present with explanatory comment

## Gaps

1. **Eval score below threshold (76/80):** Run `/improve-skill src/skills/skill/write-skill-eval` to identify and fix quality gaps. Re-run `/synapse-gatekeeper` with the updated score once it reaches ≥ 80.
```

---

## Example 3 — REJECT

**Input:** `/synapse-gatekeeper src/skills/skill/write-scope-docs`

*(EVAL.md is absent in this scenario)*

---

```
VERDICT: REJECT

## Certification Report — write-scope-docs

### Structural                    ✗
- [x] SKILL.md exists
- [ ] EVAL.md exists — ABSENT (REJECT)
- [x] Frontmatter complete (name, description, domain, intent)
- [x] domain `engineering.planning` in TAXONOMY.md
- [x] intent `write` in TAXONOMY.md
- [x] tags well-formed
- [x] user-invocable: true
- [x] argument-hint present
- [x] Domain README has row for write-scope-docs
- [x] Name globally unique

### Quality                       — skipped (EVAL.md absent)

### Registry                      — skipped (EVAL.md absent)

## Gaps

1. **EVAL.md missing:** No certification is possible without an EVAL.md. Run `/write-skill-eval src/skills/skill/write-scope-docs` to generate one, then re-run `/synapse-gatekeeper` with a measured eval score.
```
