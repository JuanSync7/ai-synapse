#!/usr/bin/env bash
# @name: scaffold
# @description: Create a new synapse with correct structure, frontmatter, and registry entries
# @audience: contributor
# @action: create
# @scope: synapse
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

usage() {
  cat <<'USAGE'
Usage: scaffold.sh <type> <domain> <name>

Creates a new artifact with correct structure, frontmatter, README row, and registry entry.

Types:
  skill      Create src/skills/<domain>/<name>/SKILL.md + EVAL.md
  agent      Create src/agents/<domain>/<name>.md
  protocol   Create src/protocols/<domain>/<name>.md
  tool       Create src/tools/<domain>/<name>/TOOL.md

Examples:
  scaffold.sh skill docs my-new-skill
  scaffold.sh agent ml training-monitor
  scaffold.sh protocol observability my-protocol
  scaffold.sh tool integration jira-mcp
USAGE
}

# --- Helpers ---

validate_domain() {
  local type="$1" domain="$2" taxonomy_file="$3"
  if ! grep -qP "^\| \`${domain}\`" "$taxonomy_file"; then
    echo "Error: Domain '${domain}' not found in $(basename "$taxonomy_file"). Add it there first or pick an existing domain." >&2
    exit 1
  fi
}

# Extract top-level domain (before first dot): docs.spec → docs
top_domain() {
  echo "${1%%.*}"
}

# Append a row to a markdown table. Finds the last non-empty line of the file and appends after it.
append_table_row() {
  local file="$1" row="$2"
  # Append the row at the end of the file (after last content line)
  if [[ -f "$file" ]]; then
    # Remove trailing blank lines, append row, add final newline
    sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$file"
    echo "$row" >> "$file"
  else
    echo "Error: File $file does not exist." >&2
    exit 1
  fi
}

# Ensure domain README exists; create if missing
ensure_domain_readme() {
  local readme_path="$1" domain="$2" artifact_type="$3" second_field="$4"
  if [[ ! -f "$readme_path" ]]; then
    local type_cap
    type_cap="$(echo "${artifact_type}" | sed 's/^./\U&/')"
    cat > "$readme_path" <<EOF
# ${domain}

${type_cap}s for the ${domain} domain.

## ${type_cap}s

| ${type_cap} | ${second_field} | Description |
|$(printf -- '-%.0s' {1..20})|$(printf -- '-%.0s' {1..20})|$(printf -- '-%.0s' {1..20})|
EOF
    CREATED_FILES+=("$readme_path")
  fi
}

# --- Main ---

if [[ $# -lt 1 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 3 ]]; then
  echo "Error: Expected 3 arguments: <type> <domain> <name>" >&2
  usage >&2
  exit 1
fi

TYPE="$1"
DOMAIN="$2"
NAME="$3"
CREATED_FILES=()

case "$TYPE" in
  skill)
    taxonomy_file="$REPO_ROOT/taxonomy/SKILL_TAXONOMY.md"
    validate_domain "$TYPE" "$DOMAIN" "$taxonomy_file"

    top_dom="$(top_domain "$DOMAIN")"
    skill_dir="$REPO_ROOT/src/skills/${top_dom}/${NAME}"

    if [[ -d "$skill_dir" ]]; then
      echo "Error: Artifact '${NAME}' already exists at ${skill_dir}" >&2
      exit 1
    fi

    mkdir -p "$skill_dir"

    # SKILL.md
    cat > "$skill_dir/SKILL.md" <<EOF
---
name: ${NAME}
description: ""
domain: ${DOMAIN}
intent: write
tags: []
user-invocable: true
argument-hint: ""
---

# ${NAME}

TODO: Add skill body.
EOF
    CREATED_FILES+=("$skill_dir/SKILL.md")

    # EVAL.md
    cat > "$skill_dir/EVAL.md" <<EOF
# Evaluation — ${NAME}

TODO: Add evaluation criteria and test prompts.
EOF
    CREATED_FILES+=("$skill_dir/EVAL.md")

    # Domain README
    readme_path="$REPO_ROOT/src/skills/${top_dom}/README.md"
    ensure_domain_readme "$readme_path" "$top_dom" "skill" "Intent"
    append_table_row "$readme_path" "| [${NAME}](${NAME}/) | write | |"
    if [[ ! " ${CREATED_FILES[*]} " =~ " ${readme_path} " ]]; then
      CREATED_FILES+=("$readme_path (updated)")
    fi

    # Registry
    registry="$REPO_ROOT/registry/SKILL_REGISTRY.md"
    append_table_row "$registry" "| [${NAME}](../src/skills/${top_dom}/${NAME}/SKILL.md) | | ${DOMAIN} | — | draft |"
    CREATED_FILES+=("$registry (updated)")
    ;;

  agent)
    taxonomy_file="$REPO_ROOT/taxonomy/AGENT_TAXONOMY.md"
    validate_domain "$TYPE" "$DOMAIN" "$taxonomy_file"

    agent_dir="$REPO_ROOT/src/agents/${DOMAIN}"
    agent_file="$agent_dir/${NAME}.md"

    if [[ -f "$agent_file" ]]; then
      echo "Error: Artifact '${NAME}' already exists at ${agent_file}" >&2
      exit 1
    fi

    mkdir -p "$agent_dir"

    cat > "$agent_file" <<EOF
---
name: ${NAME}
description: ""
domain: ${DOMAIN}
role: writer
tags: []
---

# ${NAME}

TODO: Add agent definition.
EOF
    CREATED_FILES+=("$agent_file")

    # Domain README
    readme_path="$agent_dir/README.md"
    ensure_domain_readme "$readme_path" "$DOMAIN" "agent" "Role"
    append_table_row "$readme_path" "| [${NAME}](${NAME}.md) | writer | |"
    if [[ ! " ${CREATED_FILES[*]} " =~ " ${readme_path} " ]]; then
      CREATED_FILES+=("$readme_path (updated)")
    fi

    # Registry
    registry="$REPO_ROOT/registry/AGENTS_REGISTRY.md"
    append_table_row "$registry" "| [${NAME}](src/agents/${DOMAIN}/${NAME}.md) | | |"
    CREATED_FILES+=("$registry (updated)")
    ;;

  protocol)
    taxonomy_file="$REPO_ROOT/taxonomy/PROTOCOL_TAXONOMY.md"
    validate_domain "$TYPE" "$DOMAIN" "$taxonomy_file"

    proto_dir="$REPO_ROOT/src/protocols/${DOMAIN}"
    proto_file="$proto_dir/${NAME}.md"

    if [[ -f "$proto_file" ]]; then
      echo "Error: Artifact '${NAME}' already exists at ${proto_file}" >&2
      exit 1
    fi

    mkdir -p "$proto_dir"

    cat > "$proto_file" <<EOF
---
name: ${NAME}
description: ""
domain: ${DOMAIN}
type: contract
tags: []
---

# ${NAME}

TODO: Add protocol definition.
EOF
    CREATED_FILES+=("$proto_file")

    # Domain README
    readme_path="$proto_dir/README.md"
    ensure_domain_readme "$readme_path" "$DOMAIN" "protocol" "Type"
    append_table_row "$readme_path" "| [${NAME}](${NAME}.md) | contract | |"
    if [[ ! " ${CREATED_FILES[*]} " =~ " ${readme_path} " ]]; then
      CREATED_FILES+=("$readme_path (updated)")
    fi

    # Registry
    registry="$REPO_ROOT/registry/PROTOCOL_REGISTRY.md"
    append_table_row "$registry" "| [${NAME}](src/protocols/${DOMAIN}/${NAME}.md) | | ${DOMAIN} | contract | |"
    CREATED_FILES+=("$registry (updated)")
    ;;

  tool)
    taxonomy_file="$REPO_ROOT/taxonomy/TOOL_TAXONOMY.md"
    validate_domain "$TYPE" "$DOMAIN" "$taxonomy_file"

    tool_dir="$REPO_ROOT/src/tools/${DOMAIN}/${NAME}"

    if [[ -d "$tool_dir" ]]; then
      echo "Error: Artifact '${NAME}' already exists at ${tool_dir}" >&2
      exit 1
    fi

    mkdir -p "$tool_dir"

    cat > "$tool_dir/TOOL.md" <<EOF
---
name: ${NAME}
description: ""
domain: ${DOMAIN}
action: generator
type: internal
tags: []
---

# ${NAME}

TODO: Add tool definition.
EOF
    CREATED_FILES+=("$tool_dir/TOOL.md")

    # Domain README
    readme_path="$REPO_ROOT/src/tools/${DOMAIN}/README.md"
    ensure_domain_readme "$readme_path" "$DOMAIN" "tool" "Action"
    append_table_row "$readme_path" "| [${NAME}](${NAME}/) | generator | |"
    if [[ ! " ${CREATED_FILES[*]} " =~ " ${readme_path} " ]]; then
      CREATED_FILES+=("$readme_path (updated)")
    fi

    # Registry
    registry="$REPO_ROOT/registry/TOOL_REGISTRY.md"
    append_table_row "$registry" "| [${NAME}](../src/tools/${DOMAIN}/${NAME}/TOOL.md) | | ${DOMAIN} | generator | draft |"
    CREATED_FILES+=("$registry (updated)")
    ;;

  *)
    echo "Error: Unknown type '${TYPE}'. Must be one of: skill, agent, protocol, tool" >&2
    exit 1
    ;;
esac

# Summary
echo ""
echo "Created:"
for f in "${CREATED_FILES[@]}"; do
  echo "  - $f"
done
echo ""
echo "Next: fill in the description and body, then run './cortex validate <path>' to check."
