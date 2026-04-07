# doc-authoring — Documentation Skills Suite

A suite of three composable skills for writing and maintaining layered technical documentation. Each skill owns one layer of the hierarchy and produces documents that stay coherent with the layers above and below.

---

## The 4-Layer Hierarchy

```
Layer 1 — Platform Spec          (manual — no skill)
          Platform-wide scope, cross-system contracts
               │
               ▼
Layer 2 — Spec Summary            /write-spec-summary
          §1: Generic System Overview (tech-agnostic, scrapeable)
          §2+: Requirements digest for technical stakeholders
               │
               ▼
Layer 3 — Authoritative Spec      /write-spec
          Full FR/NFR requirements, rationale, acceptance criteria,
          traceability matrix
               │
               ▼
Layer 4 — Implementation Guide    /write-impl
          Phased tasks, complexity ratings, dependency graph,
          code appendix
```

---

## Skills

| Skill | Invoke | Required Input | Output |
|-------|--------|---------------|--------|
| `write-spec` | `/write-spec` | System description + context | Authoritative spec (Layer 3) |
| `write-spec-summary` | `/write-spec-summary` | Spec file path | Summary with §1 Generic Overview (Layer 2) |
| `write-impl` | `/write-impl` | Spec file path | Phased implementation guide (Layer 4) |

Each skill enforces its own coherence gate before writing — see the skill's `SKILL.md` for details.

---

## Key Constraints

- **Never skip a layer.** A summary requires a spec. An implementation guide requires a spec.
- **Changes propagate downward.** Spec updated → summary and impl guide need review.
- **§1 of every summary is tech-agnostic.** No FR-IDs, no technology names, no file names. Designed to be extracted by a script into a platform-level overview.
- **Sibling specs must not overlap.** When a spec is split, FR-ID ranges are mutually exclusive.

---

## Governance

[GOVERNANCE.md](GOVERNANCE.md) is the authoritative reference for all cross-skill rules, the §1 contract, and coherence gates. It is not loaded at runtime — rules are inlined into each skill's `SKILL.md`.

When governance rules change: update `GOVERNANCE.md` → propagate to each affected `SKILL.md`.
