# write-spec-docs now produces a _SPEC_MAP.md artifact

write-spec-docs now outputs two files per spec: the spec itself (`_SPEC.md`) and a companion map (`_SPEC_MAP.md`). The map contains the document skeleton and a knowledge graph index (sections, entities, REQ IDs).

If the orchestrator tracks artifacts between pipeline stages, it should register `_SPEC_MAP.md` as an output of the write-spec-docs stage. Downstream stages (write-spec-summary, write-design) may benefit from receiving it.

Source: write-spec-docs brainstorm 2026-04-21
