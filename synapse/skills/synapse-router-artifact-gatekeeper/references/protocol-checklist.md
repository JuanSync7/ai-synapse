# Protocol Checklist

Loaded by synapse-router-artifact-gatekeeper when the artifact path points to `src/protocols/<domain>/<protocol>.md`. Protocols have two tiers — no registry tier (protocols are not in SKILLS_REGISTRY.yaml).

---

## Tier 1 — Structural

| Check | Pass condition |
|-------|---------------|
| Protocol file exists | `.md` file is present in `src/protocols/<domain>/` and non-empty |
| Frontmatter complete | `name`, `description`, `domain`, `subdomain`, `subject`, `kind`, `version` all present |
| `domain` in PROTOCOL_VOCABULARY.md | Value matches a row in the `## Domains` section of `registry/PROTOCOL_VOCABULARY.md` |
| `subdomain` in PROTOCOL_VOCABULARY.md | Value matches a row in the `## Subdomains` section of `registry/PROTOCOL_VOCABULARY.md` |
| `subject` in PROTOCOL_VOCABULARY.md | Value matches a row in the `## Subjects` section of `registry/PROTOCOL_VOCABULARY.md` |
| `kind` in PROTOCOL_VOCABULARY.md | Value matches a row in the `## Kinds` section of `registry/PROTOCOL_VOCABULARY.md` |
| `version` well-formed | Integer ≥ 1 |
| `tags` well-formed | Array of lowercase hyphenated strings |
| Mental model paragraph present | One paragraph after the heading explaining WHY the protocol exists |
| Contract section present | Section with imperative rules (MUST/NEVER/BEFORE/AFTER) — behavioral or schema-based |
| Failure assertion present | Protocol contains a `PROTOCOL FAILURE: [protocol-name] — [reason]` instruction |
| Domain README has row | Domain `README.md` contains a row linking this protocol |

---

## Tier 2 — Conformance

| Check | Pass condition |
|-------|---------------|
| Contract is unambiguous | Every instruction names a specific trigger moment and uses commitment language |
| Contract uses imperative language | MUST/NEVER/STOP/BEFORE/AFTER/THEN — no weak signals (consider, may want to, appropriate, ideally) |
| Failure assertion is imperative | The assertion is an instruction the agent follows (produces output), not a prose description |
| Zero-overhead design | Protocol has no cost when not injected — never self-loaded by the agent |

---

## Verdict Rules

| Condition | Verdict |
|-----------|---------|
| Both tiers pass | APPROVE |
| Fixable gaps (weak wording, vague trigger moments, zero-overhead not confirmed) | REVISE |
| Frontmatter absent, any of domain/subdomain/subject/kind not in PROTOCOL_VOCABULARY.md, no contract section, no failure assertion | REJECT |
