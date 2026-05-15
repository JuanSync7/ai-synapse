# taxonomy

Schema definitions for artifact metadata — slug pattern and required frontmatter fields per artifact type. **Shape only.** Files here do NOT enumerate the allowed values; the controlled vocabulary for each slot lives in [`../registry/<TYPE>_VOCABULARY.md`](../registry/). To add a new allowed slot value, edit the vocabulary file; to change the slug shape or required-field set, edit the taxonomy file here.

## Files

| File | Description |
|------|-------------|
| [NAMING_RATIONALE.md](NAMING_RATIONALE.md) | Wiki page — rationale for the four schemas, design principles, and adoption guidance |
| [SKILL_TAXONOMY.md](SKILL_TAXONOMY.md) | Skill schema `{domain}-{subdomain}-{scope}-{role}` + required fields. Values: [`../registry/SKILL_VOCABULARY.md`](../registry/SKILL_VOCABULARY.md) |
| [AGENT_TAXONOMY.md](AGENT_TAXONOMY.md) | Agent schema `{domain}-{subdomain}-{scope}-{role}` + required fields. Values: [`../registry/AGENT_VOCABULARY.md`](../registry/AGENT_VOCABULARY.md) |
| [PROTOCOL_TAXONOMY.md](PROTOCOL_TAXONOMY.md) | Protocol schema `{domain}-{subdomain}-{subject}-{kind}` + required fields. Values: [`../registry/PROTOCOL_VOCABULARY.md`](../registry/PROTOCOL_VOCABULARY.md) |
| [TOOL_TAXONOMY.md](TOOL_TAXONOMY.md) | Tool schema `{domain}-{subdomain}-{action}-{target}` + required fields. Values: [`../registry/TOOL_VOCABULARY.md`](../registry/TOOL_VOCABULARY.md) |
| [SCRIPT_TAXONOMY.md](SCRIPT_TAXONOMY.md) | Schema for script `audience`, `action`, and `scope` fields |
| [PATHWAY_TAXONOMY.md](PATHWAY_TAXONOMY.md) | Schema for pathway `harness` field and naming conventions |
