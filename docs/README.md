# docs

Documentation authoring skills. Produces specs, summaries, design docs, implementation docs, engineering guides, and test planning docs.

## Skills

| Skill | Intent | Description |
|-------|--------|-------------|
| [doc-authoring](doc-authoring/) | route | Router — identifies which doc skill to invoke based on role and layer |
| [write-spec-docs](write-spec-docs/) | write | Formal requirements specification with FR/NFR traceability |
| [write-spec-summary](write-spec-summary/) | summarize | Concise spec summary synced with companion spec |
| [write-design-docs](write-design-docs/) | write | Design document with task decomposition and code contracts |
| [write-implementation-docs](write-implementation-docs/) | write | Implementation source-of-truth before touching code |
| [write-engineering-guide](write-engineering-guide/) | write | Post-implementation engineering guide |
| [write-test-docs](write-test-docs/) | write | Test planning document for module test specs |

## Layer Chain

```
write-spec-docs → write-spec-summary → write-design-docs → write-implementation-docs → (code/build-plan) → write-engineering-guide → write-test-docs
```
