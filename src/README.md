# Skills

All skills live under `src/skills/<domain>/`. Each domain groups skills by concern. See the tables below for what's available, then use `./scripts/install.sh` or `make install` to install.

---

## docs — Documentation Authoring Pipeline

Skills for producing every layer of a software project's documentation, from early scope through post-build engineering guides.

| Skill | Intent | Description |
|-------|--------|-------------|
| [`doc-authoring`](skills/docs/doc-authoring/) | route | Router — identifies which doc skill to invoke based on role and layer |
| [`write-scope-docs`](skills/docs/write-scope-docs/) | write | Scope document — what to build, what to defer, how to phase delivery |
| [`write-architecture-docs`](skills/docs/write-architecture-docs/) | write | Architecture doc with technology decisions, component boundaries, and data flow patterns |
| [`write-spec-docs`](skills/docs/write-spec-docs/) | write | Formal requirements specification with FR/NFR traceability |
| [`write-spec-summary`](skills/docs/write-spec-summary/) | summarize | Concise spec summary synced with companion spec |
| [`write-design-docs`](skills/docs/write-design-docs/) | write | Design document with task decomposition and code contracts |
| [`write-implementation-docs`](skills/docs/write-implementation-docs/) | write | Implementation source-of-truth before touching code |
| [`write-engineering-guide`](skills/docs/write-engineering-guide/) | write | Post-implementation engineering guide |
| [`write-test-docs`](skills/docs/write-test-docs/) | write | Test planning document for module test specs |
| [`write-test-coverage`](skills/docs/write-test-coverage/) | write | Living test coverage register — maps acceptance criteria to test scenarios |
| [`patch-docs`](skills/docs/patch-docs/) | write | Diff-driven incremental doc patcher — targeted section updates from git diffs |

### Doc Pipeline

Each stage produces a document consumed by the next. The `autonomous-orchestrator` can drive this end-to-end with stakeholder review gates between stages.

```
write-scope-docs
     │
write-architecture-docs
     │
write-spec-docs ──► write-spec-summary
     │
write-design-docs
     │
write-implementation-docs
     │
  (code)
     │
write-engineering-guide
     │
write-test-docs
     │
write-module-tests
```

---

## code — Code Generation & Testing

| Skill | Intent | Description |
|-------|--------|-------------|
| [`build-plan`](skills/code/build-plan/) | plan | Bias-free execution plan with agent isolation phases |
| [`write-module-tests`](skills/code/write-module-tests/) | write | Implements pytest test code from test-docs spec |
| [`test-runner`](skills/code/test-runner/) | execute | Runs pytest suites with structured output and fix loop |

---

## orchestration — Multi-Agent Coordination

| Skill | Intent | Description |
|-------|--------|-------------|
| [`autonomous-orchestrator`](skills/orchestration/autonomous-orchestrator/) | execute | End-to-end autonomous development pipeline with stakeholder review gates |
| [`parallel-agents-dispatch`](skills/orchestration/parallel-agents-dispatch/) | execute | Dispatches parallel agent waves from plans or task lists |
| [`stakeholder-reviewer`](skills/orchestration/stakeholder-reviewer/) | review | Evaluates decisions against a stakeholder persona (APPROVE / REVISE / ESCALATE) |

---

## skill — Skill Development Lifecycle

End-to-end lifecycle for building, evaluating, improving, and certifying Claude Code skills.

| Skill | Intent | Description |
|-------|--------|-------------|
| [`skill-brainstorm`](skills/skill/skill-brainstorm/) | plan | Coaching brainstorm to shape skill ideas before /skill-creator |
| [`skill-creator`](skills/skill/skill-creator/) | write | Scaffolds new skills — baseline test, design principles, EVAL.md, improvement loop |
| [`improve-skill`](skills/skill/improve-skill/) | improve | Score-fix-rescore loop against an existing EVAL.md |
| [`write-skill-eval`](skills/skill/write-skill-eval/) | generate | Generates EVAL.md with output criteria and test prompts |
| [`synapse-gatekeeper`](skills/skill/synapse-gatekeeper/) | validate | Certifies promotion readiness — APPROVE / REVISE / REJECT verdict |

---

## meta — Framework Utilities

| Skill | Intent | Description |
|-------|--------|-------------|
| [`skill-router`](skills/meta/skill-router/) | route | Routes user intent to the right skill |

---

## optimization — Iterative Improvement

| Skill | Intent | Description |
|-------|--------|-------------|
| [`auto-research`](skills/optimization/auto-research/) | improve | Autonomous modify-measure-keep loop for any target (skills, code, prompts) |

---

## frameworks — Technology-Specific

| Skill | Intent | Description |
|-------|--------|-------------|
| [`langgraph-architect`](skills/frameworks/langgraph-architect/) | write | Design, review, and code-review LangGraph workflow graphs |

---

## creative — Visual & Interactive

| Skill | Intent | Description |
|-------|--------|-------------|
| [`create-animation-page`](skills/creative/create-animation-page/) | write | Single-page interactive animation as one self-contained HTML file |

---

## integration — External Services

Skills for external tool integrations. Submoduled suites are sourced from their own repos.

| Skill | Intent | Source | Description |
|-------|--------|--------|-------------|
| [`jira-reporter`](skills/integration/jira-suite/skills/jira-reporter/) | execute | [jira-suite](https://github.com/JuanSync7/jira-suite) | JIRA updates as observability/HITL layer during agent workflows |
