---
name: doc-authoring
description: Router for the doc-authoring skill suite. Use when unsure which documentation skill to invoke. Routes by document ROLE (pipeline, integration, platform, extension) and LAYER (spec, summary, design, implementation, engineering guide, module tests). Covers placement, naming, cross-referencing, and governance.
domain: docs
intent: route
tags: [router, documentation, layer]
user-invocable: true
argument-hint: "[describe what you want to document]"
---

# Documentation Skills Router

You are helping the user identify and invoke the correct skill for their documentation task. The doc-authoring suite routes across two dimensions: **Role** (what kind of document) and **Layer** (which step in the authoring chain).

## Two-Dimensional Routing

Every document has a **Role** and a **Layer**. Determine the role first, then the layer.

### Step 1: Determine Role

Ask "what kind of document is this?" and classify:

| Role | What it is | Target directory |
|------|-----------|-----------------|
| **Pipeline** | Pure interface contract for a stage — what it does, inputs/outputs, acceptance criteria. No tool names in FRs. | `docs/{domain}/{stage}/` |
| **Integration** | How a specific tool/library implements one or more stages. References which pipeline FRs it fulfills/modifies. | `docs/{domain}/integrations/{provider}/` |
| **Platform** | Cross-cutting requirements spanning multiple stages (config, error handling, lifecycle). | `docs/{domain}/` (root level) |
| **Extension** | Additive requirements extending a base spec. IDs continue from parent. | Same directory as parent spec |

**How to identify the role:**

- If the user mentions a specific tool (Docling, Weaviate, Colang, LiteLLM) → likely **Integration**
- If the user describes a stage flow or interface contract → likely **Pipeline**
- If the user describes cross-cutting concerns (config, error handling, re-ingestion) → likely **Platform**
- If the user says "add requirements to existing spec" → likely **Extension**
- If unsure, ask: "Is this describing what a stage does (pipeline), or how a specific tool does it (integration)?"

### Step 2: Determine Layer

Ask "what do you need to produce?" and route:

```
Layer 1 — Platform Spec          (written manually — no skill)
               |
               v
Layer 2 — Spec Summary            -> invoke /write-spec-summary
               |
               v
Layer 3 — Authoritative Spec      -> invoke /write-spec-docs
               |
               v
Layer 4 — Implementation Plan     -> invoke /write-impl
               |
               v
Layer 5 — Engineering Guide       -> invoke /write-engineering-guide
           (post-implementation)
               |
               v
Layer 6 — Module Tests            -> invoke /write-module-tests or /write-test-docs
```

| User Intent | Skill to Invoke |
|-------------|----------------|
| Summarize an existing spec | `/write-spec-summary` |
| Sync a summary with an updated spec | `/write-spec-summary` (update mode) |
| Write requirements / a new spec | `/write-spec-docs` |
| Write an implementation plan (pre-build) | `/write-impl` |
| Document what was built / post-implementation reference | `/write-engineering-guide` |
| Test team handoff / maintenance reference | `/write-engineering-guide` |
| Unsure | Ask: "Is the system already built, or are you planning how to build it?" |

### Step 3: Pass Structural Context

Once role and layer are determined, pass this context to the write-* skill:

- **Target directory** — derived from role (see table above)
- **Document role** — pipeline, integration, platform, or extension
- **Companion documents** — what to cross-reference (see Cross-Reference Protocol below)
- **For integration role**: which pipeline spec(s) to read first, which FRs to populate `Implements`/`Modifies` fields for

Then tell the user which skill to invoke and why.

---

## Directory Structure Convention

Generic specs describe stages. Integration specs describe providers. They live in separate directory trees within the same domain.

```
docs/{domain}/
  {stage_a}/                        <- pipeline specs (pure interface)
    {STAGE_A}_SPEC.md
    {STAGE_A}_SPEC_SUMMARY.md
    {STAGE_A}_DESIGN.md
    {STAGE_A}_IMPLEMENTATION.md
    {STAGE_A}_ENGINEERING_GUIDE.md
    {STAGE_A}_MODULE_TESTS.md
  {stage_b}/
    ...
  integrations/                     <- provider implementations
    {provider_x}/
      {PROVIDER_X}_SPEC.md
      {PROVIDER_X}_SPEC_SUMMARY.md
      {PROVIDER_X}_DESIGN.md
      {PROVIDER_X}_IMPLEMENTATION.md
      {PROVIDER_X}_ENGINEERING_GUIDE.md
      {PROVIDER_X}_MODULE_TESTS.md
    {provider_y}/
      ...
    README.md                       <- discovery index: all providers
  {DOMAIN}_PLATFORM_SPEC.md         <- cross-cutting (root level)
  README.md
```

**Key rules:**

- **One directory per provider**, full layer chain inside, regardless of how many stages the provider touches.
- **Cross-phase providers** (e.g., a tool that touches both document processing and embedding) live at domain level in `integrations/` — not nested inside a single stage.
- **`integrations/README.md`** lists all providers with a one-line summary and which stages each touches.
- **Extension specs** stay in the same directory as their parent.
- **Every role gets the full layer chain.** Documents can be short, but the chain is what keeps consistency.

### Naming Convention

| Role | Pattern | Example |
|------|---------|---------|
| Pipeline | `{STAGE}_{DOC_TYPE}.md` | `DOCUMENT_PROCESSING_SPEC.md` |
| Integration | `{PROVIDER}_{DOC_TYPE}.md` (inside provider dir) | `integrations/docling/DOCLING_SPEC.md` |
| Platform | `{DOMAIN}_PLATFORM_{DOC_TYPE}.md` | `INGESTION_PLATFORM_SPEC.md` |
| Extension | `{PARENT}_{FEATURE}_{DOC_TYPE}.md` | `IMPORT_CHECK_ENHANCEMENTS_SPEC.md` |

Doc types: `SPEC`, `SPEC_SUMMARY`, `DESIGN`, `IMPLEMENTATION`, `ENGINEERING_GUIDE`, `MODULE_TESTS`.

---

## Cross-Reference Protocol

Documents are written across sessions. Each document carries enough pointers for a future session to reconstruct relationships.

### Pipeline spec -> Integration specs (downstream pointers)

In the Companion Documents metadata field:
```
| Companion Documents | ... DOCLING_SPEC.md (Docling integration — structure detection, chunking) |
```

Plus an Integrations table at the bottom of the pipeline spec (added when the first integration spec is written):
```markdown
## Integrations

| Provider | Stages | Spec |
|----------|--------|------|
| Docling  | Structure Detection, Chunking | integrations/docling/DOCLING_SPEC.md |
```

### Integration spec -> Pipeline spec (upstream pointers)

In the metadata header:
```markdown
| Upstream   | DOCUMENT_PROCESSING_SPEC.md, EMBEDDING_PIPELINE_SPEC.md |
| Implements | FR-201 (section tree), FR-202 (table extraction), FR-208 (swappable provider) |
| Modifies   | FR-400-FR-499 (text cleaning — skipped when this provider succeeds) |
```

- **`Implements`** = which generic FRs this integration fulfills
- **`Modifies`** = which generic FRs change behavior when this integration is active

### Session boundary rules

- Writing a **pipeline spec**: no need to read integration specs. You define the interface.
- Writing an **integration spec**: MUST read the pipeline spec first. `Implements`/`Modifies` fields are derived from it.
- **Adding a swap point**: if an integration reveals the pipeline spec needs a new FR, update the pipeline spec in the same session (living-interface principle).

---

## Full Governance Rules

These rules apply across all skills in this suite. Individual skills carry a compact version inline.

### Layer Contracts

- **Never skip layers.** A summary (Layer 2) requires a spec (Layer 3). An implementation guide (Layer 4) requires a spec (Layer 3).
- **Changes propagate downward.** When a spec changes, its summary and implementation guide must be reviewed and updated to match.
- **Sibling specs must not overlap.** When one spec is split into two, FR-ID ranges must be non-overlapping and mutually exclusive.

### Role Contracts

- **Interface purity rule.** Pipeline specs MUST NOT contain implementation-specific requirements. If a requirement names a specific tool, config key, or provider behavior, it belongs in that provider's integration spec. The pipeline spec may name the default provider in prose (e.g., "the default provider is X") but all FRs must be tool-agnostic.
- **Living interface rule.** When writing an integration spec reveals that the pipeline spec is missing a swap point or stage boundary, add the generic FR to the pipeline spec in the same session. Do not leave the gap for a future session to discover.
- **Full chain rule.** Every role (pipeline, integration, platform, extension) gets the full layer chain. Documents can be short but the chain exists.

### The S1 Generic System Overview Contract

S1 of every spec summary is a technology-agnostic, fully-detailed description of the system. Written from scratch by Claude — not copied or condensed from the spec.

**Must cover (five dimensions):**
1. **Purpose** — what problem the system solves, its role in the platform
2. **Pipeline flow** — how input moves through the system, described generically (stage names describe WHAT, not HOW)
3. **Tunable knobs** — what operators/engineers can configure, why, and what the default behaviour is
4. **Design rationale** — why this approach, what constraints drove key decisions
5. **Boundary semantics** — entry point, exit point, what is handed off vs. discarded

**Must NOT contain:**
- Requirement IDs (FR-xxx, NFR-xxx, SC-xxx, REQ-xxx)
- Technology names (no "LangGraph", "Qdrant", "GPT-4o", "PyMuPDF", etc.)
- Implementation file names or class names
- Specific threshold values or metric targets

**Length:** 250-450 words. Full detail — not condensed.

**Scrapeable boundary:** Content starts immediately after the `## 1)` heading and ends before `---`.

### Coherence Gates (summary checklist before any document is finalised)

**Spec Summary (Layer 2):**
- [ ] Companion spec was fully read before writing
- [ ] S1 contains no FR-IDs, no technology names, no file names
- [ ] S1 covers all five dimensions
- [ ] S2+ scope lists match the spec exactly

**Authoritative Spec (Layer 3):**
- [ ] FR-ID ranges do not overlap with sibling specs
- [ ] Every requirement has Rationale and Acceptance Criteria
- [ ] Out-of-scope list is explicit

**Implementation Plan (Layer 4):**
- [ ] Companion spec was fully read before writing
- [ ] Every task traces to >=1 spec requirement
- [ ] Every spec requirement covered by >=1 task
- [ ] Task DAG has no cycles; critical path identified

**Engineering Guide (Layer 5):**
- [ ] All source files were read before writing (not just the spec or plan)
- [ ] Every module has a self-contained section with all six sub-sections
- [ ] No module section cross-references another section for required context
- [ ] Architecture Decisions covers all cross-cutting choices with alternatives considered
- [ ] Data Flow section uses a concrete example with actual state shapes
- [ ] Testing Guide includes testability map, mock boundaries, and 8-12 critical scenarios

**Integration Spec (any layer, additional gate):**
- [ ] `Implements` field lists every pipeline FR this integration fulfills
- [ ] `Modifies` field lists every pipeline FR whose behavior changes
- [ ] Pipeline spec's Integrations table includes this provider
- [ ] No implementation-specific FRs exist in the pipeline spec
