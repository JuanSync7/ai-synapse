# registry

Two classes of file live here:

- **`<TYPE>_VOCABULARY.md`** — the controlled vocabulary for each slug slot of an artifact type. Section headers (`## Domains`, `## Subdomains`, etc.) enumerate the allowed values. To add a new allowed value, edit the relevant section here.
- **`<TYPE>_REGISTRY.md`** — the inventory of artifacts of that type currently in the repo. Each row is one artifact, with a link to its file/dir.

The shape (slug pattern + required frontmatter fields) for each type is defined in [`../taxonomy/<TYPE>_TAXONOMY.md`](../taxonomy/). Vocabulary = values; taxonomy = shape; registry = inventory.

Check the registry files here before creating a new skill, agent, protocol, tool, or script — an existing one may already cover what you need.

## Canonical schema

All registry tables share one shape:

```
| Name | Description | Status | Consumers |
```

| Column | Source | Notes |
|--------|--------|-------|
| Name | linked slug to artifact file/dir | Slot values (domain, action, role, harness, audience, pipeline stage) are encoded in the slug — they do not get their own columns |
| Description | frontmatter `description` field | Semantic summary; not derivable from slug |
| Status | frontmatter `status` field | `draft` / `stable`. Lifecycle state |
| Consumers | derived (cross-reference scan) | Comma-separated list of artifacts that dispatch/depend on this one. `—` if none |

**Why this shape.** Slot values are recoverable from a well-formed slug, so they don't earn columns — duplication invites drift. Pipeline Stage for routable skills lives in [`synapse/SKILLS_REGISTRY.yaml`](../synapse/SKILLS_REGISTRY.yaml) where the orchestrator reads it.

**Consumer is universal.** Skills can chain into other skills, tools can be invoked from CLI, agents can be debugged directly. Every artifact has a (possibly empty) consumer set. The column is `—` when nothing chains in.

## Files

| File | Description |
|------|-------------|
| [SKILL_REGISTRY.md](SKILL_REGISTRY.md) | All skills — user-invocable recipes |
| [AGENTS_REGISTRY.md](AGENTS_REGISTRY.md) | All agents — internal recipes dispatched by skills |
| [PROTOCOL_REGISTRY.md](PROTOCOL_REGISTRY.md) | All protocols — behavioral contracts injected into agents |
| [TOOL_REGISTRY.md](TOOL_REGISTRY.md) | All tools — mechanical capabilities dispatched by skills/agents |
| [PATHWAY_REGISTRY.md](PATHWAY_REGISTRY.md) | All pathways — named synapse bundles |
| [SCRIPT_REGISTRY.md](SCRIPT_REGISTRY.md) | All scripts — repo management scripts |

