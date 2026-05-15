# type-config

Data-only lookup consumed by shared-steps. Edit here when adding a new artifact type.

Three companion files define the artifact contract:
- **`taxonomy_file`** — schema/shape (slug pattern, required frontmatter fields). Values are NOT enumerated here.
- **`vocabulary_file`** — controlled values for each slot in the slug pattern. Section headers in this file are looked up via `slot_fields`.
- **`registry_file`** — inventory of artifacts that exist. Name uniqueness is checked against this.

`slot_fields` maps each frontmatter slot field to the markdown `##` section header in the vocabulary file that enumerates its allowed values.

```yaml
skill:
  artifact_shape: directory
  artifact_dir_default: "src/skills/<domain>/<name>/"
  artifact_dir_framework: "synapse/skills/<domain>/<name>/"
  spec_file: "SKILL.md"
  taxonomy_file: "taxonomy/SKILL_TAXONOMY.md"
  vocabulary_file: "registry/SKILL_VOCABULARY.md"
  registry_file: "registry/SKILL_REGISTRY.md"
  name_pattern: "{domain}-{subdomain}-{scope}-{role}"
  slot_fields:
    domain: "Domains"
    subdomain: "Subdomains"
    scope: "Scopes"
    role: "Roles"
  frontmatter_required: [name, description, domain, subdomain, scope, role]
  eval_convention: "EVAL.md"
  registry_columns: [name, description, status, consumers]
  readme_columns: [name, role, description]   # NOTE: existing skill domain READMEs still label this column "Intent" — stale from prior schema. Migrate header to "Role" when touching the README; $meta key here reflects the current frontmatter field.
  flow_file: "references/flow-skill.md"
  design_principles_file: "references/design-principles-skill.md"
  templates_dir: "templates/skill/"

protocol:
  artifact_shape: directory
  artifact_dir_default: "src/protocols/<domain>/<name>/"
  artifact_dir_framework: "synapse/protocols/<domain>/<name>/"
  spec_file: "PROTOCOL.md"
  taxonomy_file: "taxonomy/PROTOCOL_TAXONOMY.md"
  vocabulary_file: "registry/PROTOCOL_VOCABULARY.md"
  registry_file: "registry/PROTOCOL_REGISTRY.md"
  name_pattern: "{domain}-{subdomain}-{subject}-{kind}"
  slot_fields:
    domain: "Domains"
    subdomain: "Subdomains"
    subject: "Subjects"
    kind: "Kinds"
  frontmatter_required: [name, description, domain, subdomain, subject, kind, version]
  eval_convention: "EVAL.md"
  registry_columns: [name, description, status, consumers]
  readme_columns: [name, kind, description]
  flow_file: "references/flow-protocol.md"
  design_principles_file: "references/design-principles-protocol.md"
  templates_dir: "templates/protocol/"

agent:
  artifact_shape: file           # agents are flat <name>.md files, NOT directories
  artifact_dir_default: "src/agents/<domain>/"
  artifact_dir_framework: "synapse/agents/<domain>/"
  spec_file: "<name>.md"         # the file IS the artifact; no subdirectory
  taxonomy_file: "taxonomy/AGENT_TAXONOMY.md"
  vocabulary_file: "registry/AGENT_VOCABULARY.md"
  registry_file: "registry/AGENTS_REGISTRY.md"
  name_pattern: "{domain}-{subdomain}-{scope}-{role}"
  slot_fields:
    domain: "Domains"
    subdomain: "Subdomains"
    scope: "Scopes"
    role: "Roles"
  frontmatter_required: [name, description, domain, subdomain, scope, role]
  eval_convention: "EVAL.md"
  registry_columns: [name, description, status, consumers]
  readme_columns: [name, role, description]
  flow_file: "references/flow-agent.md"
  design_principles_file: "references/design-principles-agent.md"
  templates_dir: "templates/agent/"

tool:
  artifact_shape: directory
  artifact_dir_default: "src/tools/<domain>/<name>/"
  artifact_dir_framework: "synapse/tools/<domain>/<name>/"
  spec_file: "TOOL.md"
  taxonomy_file: "taxonomy/TOOL_TAXONOMY.md"
  vocabulary_file: "registry/TOOL_VOCABULARY.md"
  registry_file: "registry/TOOL_REGISTRY.md"
  name_pattern: "{domain}-{subdomain}-{action}-{target}"
  slot_fields:
    domain: "Domains"
    subdomain: "Subdomains"
    action: "Actions"
    target: "Targets"
    kind: "Kinds"             # frontmatter-only, not part of slug
  frontmatter_required: [name, description, domain, subdomain, action, target, kind]
  eval_convention: "test/"       # default; write-tool-eval may upgrade to EVAL.md
  registry_columns: [name, description, status, consumers]
  readme_columns: [name, action, description]
  flow_file: "references/flow-tool.md"
  design_principles_file: "references/design-principles-tool.md"
  templates_dir: "templates/tool/"
```
