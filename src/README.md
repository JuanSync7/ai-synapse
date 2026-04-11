# Skills

All skills live under `src/<domain>/`. Each domain groups skills by concern. See the tables below for what's available, then use `./install.sh` or `make install` to install.

---

## docs — Documentation Authoring Pipeline

Skills for producing every layer of a software project's documentation, from early scope through post-build engineering guides.

| Skill | Intent | Description |
|-------|--------|-------------|
| [`doc-authoring`](docs/doc-authoring/) | route | Router — identifies which doc skill to invoke based on role and layer |
| [`write-scope-docs`](docs/write-scope-docs/) | write | Scope document — what to build, what to defer, how to phase delivery |
| [`write-architecture-docs`](docs/write-architecture-docs/) | write | Architecture doc with technology decisions, component boundaries, and data flow patterns |
| [`write-spec-docs`](docs/write-spec-docs/) | write | Formal requirements specification with FR/NFR traceability |
| [`write-spec-summary`](docs/write-spec-summary/) | summarize | Concise spec summary synced with companion spec |
| [`write-design-docs`](docs/write-design-docs/) | write | Design document with task decomposition and code contracts |
| [`write-implementation-docs`](docs/write-implementation-docs/) | write | Implementation source-of-truth before touching code |
| [`write-engineering-guide`](docs/write-engineering-guide/) | write | Post-implementation engineering guide |
| [`write-test-docs`](docs/write-test-docs/) | write | Test planning document for module test specs |

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
| [`build-plan`](code/build-plan/) | plan | Bias-free execution plan with agent isolation phases |
| [`write-module-tests`](code/write-module-tests/) | write | Implements pytest test code from test-docs spec |
| [`test-runner`](code/test-runner/) | execute | Runs pytest suites with structured output and fix loop |

---

## orchestration — Multi-Agent Coordination

| Skill | Intent | Description |
|-------|--------|-------------|
| [`autonomous-orchestrator`](orchestration/autonomous-orchestrator/) | execute | End-to-end autonomous development pipeline with stakeholder review gates |
| [`parallel-agents-dispatch`](orchestration/parallel-agents-dispatch/) | execute | Dispatches parallel agent waves from plans or task lists |
| [`stakeholder-reviewer`](orchestration/stakeholder-reviewer/) | review | Evaluates decisions against a stakeholder persona (APPROVE / REVISE / ESCALATE) |

---

## skill — Skill Development Lifecycle

End-to-end lifecycle for building, evaluating, improving, and certifying Claude Code skills.

| Skill | Intent | Description |
|-------|--------|-------------|
| [`skill-brainstorm`](skill/skill-brainstorm/) | plan | Coaching brainstorm to shape skill ideas before /skill-creator |
| [`skill-creator`](skill/skill-creator/) | write | Scaffolds new skills — baseline test, design principles, EVAL.md, improvement loop |
| [`improve-skill`](skill/improve-skill/) | improve | Score-fix-rescore loop against an existing EVAL.md |
| [`write-skill-eval`](skill/write-skill-eval/) | generate | Generates EVAL.md with output criteria and test prompts |
| [`generate-output-criteria`](skill/generate-output-criteria/) | generate | Binary pass/fail output criteria as impartial judge |
| [`generate-test-prompts`](skill/generate-test-prompts/) | generate | Diverse test prompts blind to SKILL.md body |
| [`synapse-gatekeeper`](skill/synapse-gatekeeper/) | validate | Certifies promotion readiness — APPROVE / REVISE / REJECT verdict |

---

## meta — Framework Utilities

| Skill | Intent | Description |
|-------|--------|-------------|
| [`skill-router`](meta/skill-router/) | route | Routes user intent to the right skill |

---

## optimization — Iterative Improvement

| Skill | Intent | Description |
|-------|--------|-------------|
| [`auto-research`](optimization/auto-research/) | improve | Autonomous modify-measure-keep loop for any target (skills, code, prompts) |

---

## frameworks — Technology-Specific

| Skill | Intent | Description |
|-------|--------|-------------|
| [`langgraph-architect`](frameworks/langgraph-architect/) | write | Design, review, and code-review LangGraph workflow graphs |

---

## creative — Visual & Interactive

| Skill | Intent | Description |
|-------|--------|-------------|
| [`create-animation-page`](creative/create-animation-page/) | write | Single-page interactive animation as one self-contained HTML file |

---

## integration — External Services

Skills for external tool integrations. Submoduled suites are sourced from their own repos.

| Skill | Intent | Source | Description |
|-------|--------|--------|-------------|
| [`jira-reporter`](integration/jira-suite/skills/jira-reporter/) | execute | [jira-suite](https://github.com/JuanSync7/jira-suite) | JIRA updates as observability/HITL layer during agent workflows |
