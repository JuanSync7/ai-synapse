# Stage Interface Contract

Every stage in the pipeline declares itself using this YAML contract. The orchestrator reads these declarations to know how to invoke, gate, and connect stages.

## Stage Declaration

```yaml
stage:
  name: string            # Canonical stage name (must match Stage Registry)
  skill: string | null    # Skill to invoke (null for built-in stages only)
  input_from: string      # Canonical name of the stage whose output this stage consumes
  output_type: string     # What this stage produces (human-readable description)
  output_path: string     # File path pattern where the stage writes its artifact
  context_type: string    # Stakeholder-reviewer context type for this stage's gate
  skippable: bool         # Can this stage be omitted via --stages or template config?
  requires: list[string]  # Stages that must be completed before this one can run
```

### Concrete Example — `spec` stage

```yaml
stage:
  name: spec
  skill: write-spec
  input_from: brainstorm
  output_type: "formal spec (markdown)"
  output_path: "docs/superpowers/specs/<date>-<topic>-spec.md"
  context_type: spec_review
  skippable: true
  requires: [brainstorm]
```

## Field Details

### name
The canonical stage name. Must be unique across the pipeline. Used in templates, `--stages` arguments, checkpoint state, and inter-stage references.

### skill
The Claude Code skill to invoke for this stage. Set to `null` for built-in stages (currently only `brainstorm`). Built-in stages are handled directly by the orchestrator rather than dispatched.

### input_from
Which prior stage's output to consume. The orchestrator reads the output file from this stage's checkpoint entry and provides it to the current stage. When the referenced stage was skipped, the orchestrator walks backward through the pipeline to find the most recent completed stage's output.

### output_path
File path pattern for the stage's artifact. Supports variables:
- `<date>` — current date in YYYY-MM-DD format
- `<topic>` — sanitized goal text or brief topic
- `<run-id>` — the run identifier

### context_type
The context type passed to stakeholder-reviewer when gating this stage's output. Must be one of: `qa_answer`, `approach_selection`, `design_approval`, `spec_review`, `code_review`, `doc_review`.

### requires
Hard dependencies. The orchestrator verifies these stages are `completed` before starting this stage. This is enforced even when `--stages` is used — if a required stage is missing from the stage list, the orchestrator flags the dependency and asks for confirmation.

## Built-In Stage Exception

The `brainstorm` stage is the only built-in stage. It sets `skill: null` because brainstorming is the orchestrator's core capability — the self-answering, self-critique, and approach selection logic is defined in `brainstorm-phase.md`, not in a separate skill.

All other stages dispatch to existing skills. If the orchestrator's brainstorming logic is ever extracted into its own skill, this exception goes away and `brainstorm` gets a `skill` value like every other stage.

## How to Add a New Stage

1. **Create the skill** — run `/skill-creator` to build the skill directory and SKILL.md.
2. **Register in SKILLS_REGISTRY.yaml** — `skill-creator` prompts for pipeline metadata and appends the entry. If adding manually, declare a `pipeline:` block under the correct domain/group with: `stage_name`, `input_type`, `output_type`, `context_type`, `requires_all`/`requires_any`, `skippable`.
3. **Define the inter-stage contract** in `pipeline-templates.md` — what artifact does it receive, what does it produce?
4. **Add to presets if appropriate** — update the `presets:` section in `SKILLS_REGISTRY.yaml` for any named pipeline that should include this stage.
5. **Verify** — confirm `stage_name` is unique in the registry, `requires` references resolve, and at least one preset or goal type would route to it.

No changes to orchestrator SKILL.md are needed — the router reads from `SKILLS_REGISTRY.yaml` dynamically.

## Plugin Stage Registration

Skills from external plugins (outside `.claude/skills/`) may declare a `REGISTRY_ENTRY.yaml`
in their skill directory to make themselves routable by the autonomous-orchestrator:

```yaml
version: 2           # required; rejected if absent or mismatched
name: my-custom-skill
description: "Does X for Y"
domain: engineering  # top-level domain to merge into
group: planning      # group within that domain
pipeline:
  stage_name: custom-stage
  input_type: formal_spec
  output_type: custom_artifact
  context_type: design_approval
  requires_all: [spec]
  skippable: true
```

The orchestrator merges plugin entries in-memory during Phase 0. They are **never written
back to `SKILLS_REGISTRY.yaml`**. If a plugin declares a `stage_name` that collides with
an existing registry entry, the plugin entry is rejected and the user is notified.

Plugin skills without a `REGISTRY_ENTRY.yaml` are not routable — no error, they simply
won't appear in assembled pipelines.
