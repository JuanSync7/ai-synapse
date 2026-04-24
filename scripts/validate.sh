#!/usr/bin/env bash
# @name: validate
# @description: Run structural checks without committing
# @audience: contributor
# @action: inspect
# @scope: repo
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# --- Taxonomy and registry paths ---
SKILL_TAXONOMY="$REPO_ROOT/taxonomy/SKILL_TAXONOMY.md"
AGENT_TAXONOMY="$REPO_ROOT/taxonomy/AGENT_TAXONOMY.md"
PROTOCOL_TAXONOMY="$REPO_ROOT/taxonomy/PROTOCOL_TAXONOMY.md"
TOOL_TAXONOMY="$REPO_ROOT/taxonomy/TOOL_TAXONOMY.md"
SCRIPT_TAXONOMY="$REPO_ROOT/taxonomy/SCRIPT_TAXONOMY.md"

SKILL_REGISTRY="$REPO_ROOT/registry/SKILL_REGISTRY.md"
AGENTS_REGISTRY="$REPO_ROOT/registry/AGENTS_REGISTRY.md"
TOOL_REGISTRY="$REPO_ROOT/registry/TOOL_REGISTRY.md"
SCRIPT_REGISTRY="$REPO_ROOT/registry/SCRIPT_REGISTRY.md"

error_count=0
warn_count=0

# =============================================================================
# Usage
# =============================================================================

usage() {
  cat <<'USAGE'
Usage: validate.sh [<path>] [--help]

Run structural checks on ai-synapse artifacts without committing.

Arguments:
  <path>       Validate a specific artifact file or directory (optional)
               If omitted, validates everything.

Options:
  --help       Show this help message

Examples:
  validate.sh                                        # validate all artifacts
  validate.sh src/skills/docs/write-spec-docs        # validate one skill
  validate.sh src/skills/docs/write-spec-docs/SKILL.md  # same, via file path
  validate.sh src/skills/                            # validate all skills
  validate.sh src/agents/                            # validate all agents
  validate.sh scripts/install.sh                     # validate one script

Checks performed:
  Skills (src/skills/**/SKILL.md):
    - Frontmatter exists with required fields (name, description, domain, intent)
    - domain/intent values exist in taxonomy/SKILL_TAXONOMY.md
    - EVAL.md exists alongside SKILL.md
    - Skill listed in registry/SKILL_REGISTRY.md
    - Domain README.md has a matching row

  Agents (src/agents/**/*.md, excluding README.md):
    - Frontmatter exists with required fields (name, description, domain, role)
    - domain/role values exist in taxonomy/AGENT_TAXONOMY.md
    - Agent listed in registry/AGENTS_REGISTRY.md
    - Domain README.md has a matching row

  Protocols (src/protocols/**/*.md, excluding README.md, change_requests/):
    - Frontmatter exists with required fields (name, description, domain, type)
    - domain/type values exist in taxonomy/PROTOCOL_TAXONOMY.md
    - Domain README.md has a matching row

  Tools (src/tools/**/TOOL.md):
    - Frontmatter exists with required fields (name, description, domain, action, type)
    - domain/action/type values exist in taxonomy/TOOL_TAXONOMY.md
    - Tool listed in registry/TOOL_REGISTRY.md
    - Domain README.md has a matching row

  Scripts (scripts/*.sh):
    - Comment-based frontmatter with required fields (@name, @description, @audience, @action, @scope)
    - audience/action/scope values exist in taxonomy/SCRIPT_TAXONOMY.md
    - Script listed in registry/SCRIPT_REGISTRY.md

  Stale registry entries:
    - Each registry link points to a file that exists on disk
USAGE
}

# =============================================================================
# Reporting helpers
# =============================================================================

report_error() {
  local path="$1" msg="$2"
  echo "ERROR: $path: $msg"
  (( error_count++ )) || true
}

report_warn() {
  local path="$1" msg="$2"
  echo "WARN: $path: $msg"
  (( warn_count++ )) || true
}

# =============================================================================
# Extraction helpers
# =============================================================================

# Extract a YAML frontmatter field value from a file with --- delimiters.
# Usage: extract_frontmatter_field <file> <field>
extract_frontmatter_field() {
  local file="$1" field="$2"
  local frontmatter
  frontmatter="$(sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d')"
  local val
  val="$(echo "$frontmatter" | grep "^${field}:" | head -1 | sed "s/^${field}: *//" | tr -d '"' | tr -d "'" | sed 's/ *$//')"
  echo "$val"
}

# Extract a # @field: value from a script file.
# Usage: extract_script_field <file> <field>
extract_script_field() {
  local file="$1" field="$2"
  local val
  val="$(grep "^# @${field}:" "$file" | head -1 | sed "s/^# @${field}: *//" | sed 's/ *$//')" || true
  echo "$val"
}

# Check if a value exists in a taxonomy file under a given section heading.
# Usage: check_taxonomy_value <taxonomy_file> <section_name> <value>
# Returns 0 if found, 1 if not.
check_taxonomy_value() {
  local file="$1" section="$2" value="$3"
  local in_section=false
  while IFS= read -r line; do
    if echo "$line" | grep -q "^## ${section}$"; then
      in_section=true
      continue
    fi
    if echo "$line" | grep -q "^## "; then
      if [ "$in_section" = true ]; then
        return 1
      fi
      continue
    fi
    if [ "$in_section" = true ]; then
      local val
      val="$(echo "$line" | grep '^\| `' | sed 's/^| `//;s/`.*//' || true)"
      if [ -n "$val" ] && [ "$val" = "$value" ]; then
        return 0
      fi
    fi
  done < "$file"
  return 1
}

# Check if a name appears as a markdown link [<name>] in a file.
# Usage: check_registry_entry <registry_file> <name>
# Returns 0 if found, 1 if not.
check_registry_entry() {
  local file="$1" name="$2"
  if [ ! -f "$file" ]; then
    return 1
  fi
  grep -q "\[${name}\]" "$file" 2>/dev/null
}

# Check if a name appears as a markdown link [<name>] in a README.
# Usage: check_readme_entry <readme_file> <name>
# Returns 0 if found, 1 if not.
check_readme_entry() {
  local file="$1" name="$2"
  if [ ! -f "$file" ]; then
    return 1
  fi
  grep -q "\[${name}\]" "$file" 2>/dev/null || grep -q "\[${name}\.sh\]" "$file" 2>/dev/null
}

# Check if a skill is marked draft in SKILL_REGISTRY.md.
# A draft row ends with `| draft |` (status column).
# Usage: is_draft_skill <skill_name>
# Returns 0 if draft, 1 otherwise.
is_draft_skill() {
  local name="$1"
  [ -f "$SKILL_REGISTRY" ] || return 1
  grep "\[${name}\]" "$SKILL_REGISTRY" 2>/dev/null | grep -q '|[[:space:]]*draft[[:space:]]*|'
}

# =============================================================================
# Frontmatter existence check
# =============================================================================

has_frontmatter() {
  local file="$1"
  head -1 "$file" | grep -q '^---$' && sed -n '2,$ p' "$file" | grep -q '^---$'
}

# =============================================================================
# Artifact validators
# =============================================================================

validate_skill() {
  local skill_md="$1"
  local skill_dir
  skill_dir="$(dirname "$skill_md")"
  local skill_name
  skill_name="$(basename "$skill_dir")"
  local rel_path="${skill_md#"$REPO_ROOT/"}"

  # 1. Frontmatter exists
  if ! has_frontmatter "$skill_md"; then
    report_error "$rel_path" "missing YAML frontmatter (--- delimiters)"
    return
  fi

  # 2. Required fields
  for field in name description domain intent; do
    local val
    val="$(extract_frontmatter_field "$skill_md" "$field")"
    if [ -z "$val" ]; then
      report_error "$rel_path" "missing or empty frontmatter field '$field'"
    fi
  done

  # 3. domain in taxonomy
  local domain_val
  domain_val="$(extract_frontmatter_field "$skill_md" "domain")"
  if [ -n "$domain_val" ]; then
    if ! check_taxonomy_value "$SKILL_TAXONOMY" "Domains" "$domain_val"; then
      report_error "$rel_path" "domain '$domain_val' not found in taxonomy/SKILL_TAXONOMY.md"
    fi
  fi

  # 4. intent in taxonomy
  local intent_val
  intent_val="$(extract_frontmatter_field "$skill_md" "intent")"
  if [ -n "$intent_val" ]; then
    if ! check_taxonomy_value "$SKILL_TAXONOMY" "Intents" "$intent_val"; then
      report_error "$rel_path" "intent '$intent_val' not found in taxonomy/SKILL_TAXONOMY.md"
    fi
  fi

  # 5. EVAL.md exists (skipped for draft skills — they predate the EVAL requirement)
  if [ ! -f "$skill_dir/EVAL.md" ]; then
    if is_draft_skill "$skill_name"; then
      report_warn "$rel_path" "missing EVAL.md (skill marked draft — required before promotion to stable)"
    else
      report_error "$rel_path" "missing EVAL.md alongside SKILL.md"
    fi
  fi

  # 6. Listed in SKILL_REGISTRY.md
  if [ -f "$SKILL_REGISTRY" ]; then
    if ! check_registry_entry "$SKILL_REGISTRY" "$skill_name"; then
      report_error "$rel_path" "no row for '$skill_name' in registry/SKILL_REGISTRY.md"
    fi
  else
    report_error "$rel_path" "registry/SKILL_REGISTRY.md not found"
  fi

  # 7. Domain README has a matching row
  # Domain dir is two levels up from SKILL.md: src/skills/<domain>/<name>/SKILL.md
  local domain_dir
  domain_dir="$(dirname "$skill_dir")"
  local domain_readme="$domain_dir/README.md"
  if [ -f "$domain_readme" ]; then
    if ! check_readme_entry "$domain_readme" "$skill_name"; then
      local rel_readme="${domain_readme#"$REPO_ROOT/"}"
      report_error "$rel_path" "no row for '$skill_name' in $rel_readme"
    fi
  else
    local rel_readme="${domain_dir#"$REPO_ROOT/"}/README.md"
    report_error "$rel_path" "missing $rel_readme"
  fi
}

validate_agent() {
  local agent_md="$1"
  local agent_name
  agent_name="$(basename "$agent_md" .md)"
  local rel_path="${agent_md#"$REPO_ROOT/"}"

  # 1. Frontmatter exists
  if ! has_frontmatter "$agent_md"; then
    report_error "$rel_path" "missing YAML frontmatter (--- delimiters)"
    return
  fi

  # 2. Required fields
  for field in name description domain role; do
    local val
    val="$(extract_frontmatter_field "$agent_md" "$field")"
    if [ -z "$val" ]; then
      report_error "$rel_path" "missing or empty frontmatter field '$field'"
    fi
  done

  # 3. domain in taxonomy
  local domain_val
  domain_val="$(extract_frontmatter_field "$agent_md" "domain")"
  if [ -n "$domain_val" ]; then
    if ! check_taxonomy_value "$AGENT_TAXONOMY" "Domains" "$domain_val"; then
      report_error "$rel_path" "domain '$domain_val' not found in taxonomy/AGENT_TAXONOMY.md"
    fi
  fi

  # 4. role in taxonomy
  local role_val
  role_val="$(extract_frontmatter_field "$agent_md" "role")"
  if [ -n "$role_val" ]; then
    if ! check_taxonomy_value "$AGENT_TAXONOMY" "Roles" "$role_val"; then
      report_error "$rel_path" "role '$role_val' not found in taxonomy/AGENT_TAXONOMY.md"
    fi
  fi

  # 5. Listed in AGENTS_REGISTRY.md
  if [ -f "$AGENTS_REGISTRY" ]; then
    if ! check_registry_entry "$AGENTS_REGISTRY" "$agent_name"; then
      report_error "$rel_path" "no row for '$agent_name' in registry/AGENTS_REGISTRY.md"
    fi
  else
    report_error "$rel_path" "registry/AGENTS_REGISTRY.md not found"
  fi

  # 6. Domain README has a matching row
  local domain_dir
  domain_dir="$(dirname "$agent_md")"
  local domain_readme="$domain_dir/README.md"
  if [ -f "$domain_readme" ]; then
    if ! check_readme_entry "$domain_readme" "$agent_name"; then
      local rel_readme="${domain_readme#"$REPO_ROOT/"}"
      report_error "$rel_path" "no row for '$agent_name' in $rel_readme"
    fi
  else
    local rel_readme="${domain_dir#"$REPO_ROOT/"}/README.md"
    report_error "$rel_path" "missing $rel_readme"
  fi
}

validate_protocol() {
  local protocol_md="$1"
  local protocol_name
  protocol_name="$(basename "$protocol_md" .md)"
  local rel_path="${protocol_md#"$REPO_ROOT/"}"

  # 1. Frontmatter exists
  if ! has_frontmatter "$protocol_md"; then
    report_error "$rel_path" "missing YAML frontmatter (--- delimiters)"
    return
  fi

  # 2. Required fields
  for field in name description domain type; do
    local val
    val="$(extract_frontmatter_field "$protocol_md" "$field")"
    if [ -z "$val" ]; then
      report_error "$rel_path" "missing or empty frontmatter field '$field'"
    fi
  done

  # 3. domain in taxonomy
  local domain_val
  domain_val="$(extract_frontmatter_field "$protocol_md" "domain")"
  if [ -n "$domain_val" ]; then
    if ! check_taxonomy_value "$PROTOCOL_TAXONOMY" "Domains" "$domain_val"; then
      report_error "$rel_path" "domain '$domain_val' not found in taxonomy/PROTOCOL_TAXONOMY.md"
    fi
  fi

  # 4. type in taxonomy
  local type_val
  type_val="$(extract_frontmatter_field "$protocol_md" "type")"
  if [ -n "$type_val" ]; then
    if ! check_taxonomy_value "$PROTOCOL_TAXONOMY" "Types" "$type_val"; then
      report_error "$rel_path" "type '$type_val' not found in taxonomy/PROTOCOL_TAXONOMY.md"
    fi
  fi

  # 5. Domain README has a matching row
  local domain_dir
  domain_dir="$(dirname "$protocol_md")"
  local domain_readme="$domain_dir/README.md"
  if [ -f "$domain_readme" ]; then
    if ! check_readme_entry "$domain_readme" "$protocol_name"; then
      local rel_readme="${domain_readme#"$REPO_ROOT/"}"
      report_error "$rel_path" "no row for '$protocol_name' in $rel_readme"
    fi
  else
    local rel_readme="${domain_dir#"$REPO_ROOT/"}/README.md"
    report_error "$rel_path" "missing $rel_readme"
  fi
}

validate_tool() {
  local tool_md="$1"
  local tool_dir
  tool_dir="$(dirname "$tool_md")"
  local tool_name
  tool_name="$(basename "$tool_dir")"
  local rel_path="${tool_md#"$REPO_ROOT/"}"

  # 1. Frontmatter exists
  if ! has_frontmatter "$tool_md"; then
    report_error "$rel_path" "missing YAML frontmatter (--- delimiters)"
    return
  fi

  # 2. Required fields
  for field in name description domain action type; do
    local val
    val="$(extract_frontmatter_field "$tool_md" "$field")"
    if [ -z "$val" ]; then
      report_error "$rel_path" "missing or empty frontmatter field '$field'"
    fi
  done

  # 3. domain in taxonomy
  local domain_val
  domain_val="$(extract_frontmatter_field "$tool_md" "domain")"
  if [ -n "$domain_val" ]; then
    if ! check_taxonomy_value "$TOOL_TAXONOMY" "Domains" "$domain_val"; then
      report_error "$rel_path" "domain '$domain_val' not found in taxonomy/TOOL_TAXONOMY.md"
    fi
  fi

  # 4. action in taxonomy
  local action_val
  action_val="$(extract_frontmatter_field "$tool_md" "action")"
  if [ -n "$action_val" ]; then
    if ! check_taxonomy_value "$TOOL_TAXONOMY" "Actions" "$action_val"; then
      report_error "$rel_path" "action '$action_val' not found in taxonomy/TOOL_TAXONOMY.md"
    fi
  fi

  # 5. type in taxonomy
  local type_val
  type_val="$(extract_frontmatter_field "$tool_md" "type")"
  if [ -n "$type_val" ]; then
    if ! check_taxonomy_value "$TOOL_TAXONOMY" "Types" "$type_val"; then
      report_error "$rel_path" "type '$type_val' not found in taxonomy/TOOL_TAXONOMY.md"
    fi
  fi

  # 6. Listed in TOOL_REGISTRY.md
  if [ -f "$TOOL_REGISTRY" ]; then
    if ! check_registry_entry "$TOOL_REGISTRY" "$tool_name"; then
      report_error "$rel_path" "no row for '$tool_name' in registry/TOOL_REGISTRY.md"
    fi
  else
    report_error "$rel_path" "registry/TOOL_REGISTRY.md not found"
  fi

  # 7. Domain README has a matching row
  local domain_dir
  domain_dir="$(dirname "$tool_dir")"
  local domain_readme="$domain_dir/README.md"
  if [ -f "$domain_readme" ]; then
    if ! check_readme_entry "$domain_readme" "$tool_name"; then
      local rel_readme="${domain_readme#"$REPO_ROOT/"}"
      report_error "$rel_path" "no row for '$tool_name' in $rel_readme"
    fi
  else
    local rel_readme="${domain_dir#"$REPO_ROOT/"}/README.md"
    report_error "$rel_path" "missing $rel_readme"
  fi
}

validate_script() {
  local script_file="$1"
  local script_name
  script_name="$(basename "$script_file" .sh)"
  local rel_path="${script_file#"$REPO_ROOT/"}"

  # 1. Comment-based frontmatter fields
  for field in name description audience action scope; do
    local val
    val="$(extract_script_field "$script_file" "$field")"
    if [ -z "$val" ]; then
      report_error "$rel_path" "missing comment frontmatter field '# @${field}:'"
    fi
  done

  # 2. audience in taxonomy
  local audience_val
  audience_val="$(extract_script_field "$script_file" "audience")"
  if [ -n "$audience_val" ]; then
    if ! check_taxonomy_value "$SCRIPT_TAXONOMY" "Audiences" "$audience_val"; then
      report_error "$rel_path" "audience '$audience_val' not found in taxonomy/SCRIPT_TAXONOMY.md"
    fi
  fi

  # 3. action in taxonomy
  local action_val
  action_val="$(extract_script_field "$script_file" "action")"
  if [ -n "$action_val" ]; then
    if ! check_taxonomy_value "$SCRIPT_TAXONOMY" "Actions" "$action_val"; then
      report_error "$rel_path" "action '$action_val' not found in taxonomy/SCRIPT_TAXONOMY.md"
    fi
  fi

  # 4. scope in taxonomy
  local scope_val
  scope_val="$(extract_script_field "$script_file" "scope")"
  if [ -n "$scope_val" ]; then
    if ! check_taxonomy_value "$SCRIPT_TAXONOMY" "Scopes" "$scope_val"; then
      report_error "$rel_path" "scope '$scope_val' not found in taxonomy/SCRIPT_TAXONOMY.md"
    fi
  fi

  # 5. Listed in SCRIPT_REGISTRY.md
  if [ -f "$SCRIPT_REGISTRY" ]; then
    if ! check_registry_entry "$SCRIPT_REGISTRY" "$script_name"; then
      report_error "$rel_path" "no row for '$script_name' in registry/SCRIPT_REGISTRY.md"
    fi
  else
    report_error "$rel_path" "registry/SCRIPT_REGISTRY.md not found"
  fi
}

# =============================================================================
# Discovery functions — find all artifacts of a type
# =============================================================================

find_all_skills() {
  find "$REPO_ROOT/src/skills" -name "SKILL.md" -type f 2>/dev/null | sort
}

find_all_agents() {
  find "$REPO_ROOT/src/agents" -name "*.md" -type f ! -name "README.md" 2>/dev/null | sort
}

find_all_protocols() {
  find "$REPO_ROOT/src/protocols" -name "*.md" -type f ! -name "README.md" ! -path "*/change_requests/*" 2>/dev/null | sort
}

find_all_tools() {
  find "$REPO_ROOT/src/tools" -name "TOOL.md" -type f 2>/dev/null | sort
}

find_all_scripts() {
  find "$REPO_ROOT/scripts" -maxdepth 1 -name "*.sh" -type f 2>/dev/null | sort
}

# =============================================================================
# Stale registry entry detection
# =============================================================================

check_stale_registry_entries() {
  local registry_file="$1"
  local registry_name
  registry_name="$(basename "$registry_file")"

  if [ ! -f "$registry_file" ]; then
    return
  fi

  # Extract markdown links from table rows: [name](relative/path)
  while IFS= read -r line; do
    # Match table rows containing markdown links
    local link_path
    link_path="$(echo "$line" | grep -oP '\]\(\K[^)]+' | head -1 || true)"
    if [ -z "$link_path" ]; then
      continue
    fi

    # Resolve relative path from registry directory
    local registry_dir
    registry_dir="$(dirname "$registry_file")"
    local resolved_path="$registry_dir/$link_path"

    # Some registries use repo-root-relative paths (no ../), try both
    if [ ! -e "$resolved_path" ] && [[ "$link_path" != ../* ]]; then
      resolved_path="$REPO_ROOT/$link_path"
    fi

    # Check existence
    if [ ! -e "$resolved_path" ]; then
      local link_name
      link_name="$(echo "$line" | grep -oP '\[\K[^\]]+' | head -1 || true)"
      report_warn "$registry_name" "stale entry '$link_name' — target '$link_path' does not exist"
    fi
  done < "$registry_file"
}

# =============================================================================
# Targeted validation — resolve a user-provided path to artifacts
# =============================================================================

validate_path() {
  local target="$1"

  # Make absolute if relative
  if [[ "$target" != /* ]]; then
    target="$REPO_ROOT/$target"
  fi

  # Remove trailing slash
  target="${target%/}"

  if [ -f "$target" ]; then
    # Specific file
    case "$target" in
      */SKILL.md)   validate_skill "$target" ;;
      */TOOL.md)    validate_tool "$target" ;;
      */scripts/*.sh) validate_script "$target" ;;
      */src/agents/*/README.md) ;; # skip READMEs
      */src/protocols/*/README.md) ;; # skip READMEs
      */src/agents/*.md)
        validate_agent "$target" ;;
      */src/protocols/*.md)
        # Skip change_requests
        if [[ "$target" != */change_requests/* ]]; then
          validate_protocol "$target"
        fi
        ;;
      *)
        echo "Unknown artifact type: ${target#"$REPO_ROOT/"}"
        ;;
    esac
  elif [ -d "$target" ]; then
    # Directory — find artifacts within it
    local found=false

    # Skills
    while IFS= read -r f; do
      validate_skill "$f"
      found=true
    done < <(find "$target" -name "SKILL.md" -type f 2>/dev/null | sort)

    # Agents
    if [[ "$target" == *src/agents* ]]; then
      while IFS= read -r f; do
        validate_agent "$f"
        found=true
      done < <(find "$target" -name "*.md" -type f ! -name "README.md" 2>/dev/null | sort)
    fi

    # Protocols
    if [[ "$target" == *src/protocols* ]]; then
      while IFS= read -r f; do
        validate_protocol "$f"
        found=true
      done < <(find "$target" -name "*.md" -type f ! -name "README.md" ! -path "*/change_requests/*" 2>/dev/null | sort)
    fi

    # Tools
    while IFS= read -r f; do
      validate_tool "$f"
      found=true
    done < <(find "$target" -name "TOOL.md" -type f 2>/dev/null | sort)

    # Scripts
    if [[ "$target" == *scripts* ]]; then
      while IFS= read -r f; do
        validate_script "$f"
        found=true
      done < <(find "$target" -maxdepth 1 -name "*.sh" -type f 2>/dev/null | sort)
    fi

    if [ "$found" = false ]; then
      echo "No artifacts found in: ${target#"$REPO_ROOT/"}"
    fi
  else
    echo "Path not found: ${target#"$REPO_ROOT/"}"
    exit 1
  fi
}

# =============================================================================
# Main
# =============================================================================

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  usage
  exit 0
fi

if [ $# -gt 0 ]; then
  # Targeted validation
  echo "Validating: $1"
  echo ""
  validate_path "$1"
else
  # Full validation
  echo "Validating all artifacts..."
  echo ""

  # Skills
  echo "--- Skills ---"
  if [ -d "$REPO_ROOT/src/skills" ]; then
    while IFS= read -r f; do
      validate_skill "$f"
    done < <(find_all_skills)
  fi

  # Agents
  echo "--- Agents ---"
  if [ -d "$REPO_ROOT/src/agents" ]; then
    while IFS= read -r f; do
      validate_agent "$f"
    done < <(find_all_agents)
  fi

  # Protocols
  echo "--- Protocols ---"
  if [ -d "$REPO_ROOT/src/protocols" ]; then
    while IFS= read -r f; do
      validate_protocol "$f"
    done < <(find_all_protocols)
  fi

  # Tools
  echo "--- Tools ---"
  if [ -d "$REPO_ROOT/src/tools" ]; then
    while IFS= read -r f; do
      validate_tool "$f"
    done < <(find_all_tools)
  fi

  # Scripts
  echo "--- Scripts ---"
  if [ -d "$REPO_ROOT/scripts" ]; then
    while IFS= read -r f; do
      validate_script "$f"
    done < <(find_all_scripts)
  fi

  # Stale registry entries
  echo "--- Stale registry entries ---"
  check_stale_registry_entries "$SKILL_REGISTRY"
  check_stale_registry_entries "$AGENTS_REGISTRY"
  check_stale_registry_entries "$TOOL_REGISTRY"
  check_stale_registry_entries "$SCRIPT_REGISTRY"
  # Protocol registry uses paths relative to registry/ dir — check it too
  check_stale_registry_entries "$REPO_ROOT/registry/PROTOCOL_REGISTRY.md"
fi

# =============================================================================
# Summary
# =============================================================================

echo ""
echo "$error_count error(s), $warn_count warning(s)"

if [ "$error_count" -gt 0 ]; then
  exit 1
fi
exit 0
