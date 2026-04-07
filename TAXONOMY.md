# Skill Taxonomy

Controlled vocabulary for skill metadata. When creating a new skill, pick `domain` and `intent` from the tables below. If nothing fits, propose an addition to this file — do not invent ad hoc values.

## Domains

| Domain | Description |
|--------|-------------|
| `docs` | Documentation authoring |
| `docs.spec` | Specs and summaries |
| `docs.design` | Design documents |
| `docs.impl` | Implementation reference docs |
| `docs.post-build` | Engineering guides, test docs |
| `code` | Code generation and execution |
| `code.test` | Test code authoring and execution |
| `code.plan` | Execution planning |
| `meta` | Skills about skills |
| `meta.eval` | Skill evaluation |
| `meta.create` | Skill creation and improvement |
| `optimization` | Autonomous iterative improvement |
| `orchestration` | Multi-agent coordination |
| `creative` | Standalone creative/visual |
| `frameworks.langgraph` | LangGraph-specific tools |

## Intents

| Intent | Description |
|--------|-------------|
| `write` | Produce a new artifact |
| `review` | Evaluate/critique existing work |
| `plan` | Create an execution strategy |
| `route` | Dispatch to another skill |
| `execute` | Run/dispatch agents |
| `improve` | Iterate on existing artifact |
| `debug` | Diagnose and fix issues |
| `analyze` | Extract insights without changing anything |
| `convert` | Transform between formats |
| `validate` | Check correctness against a reference |
| `summarize` | Condense existing artifact |
| `migrate` | Move between versions/platforms |
| `generate` | Produce from template/config |

## Tags

Freeform — no controlled list. Use lowercase, hyphenated multi-word tags (e.g., `test-planning`, `source-of-truth`).
