#!/usr/bin/env bash
# @name: pathway
# @description: Manage pathway bundles — list, show, install, create, export
# @audience: consumer
# @action: install
# @scope: pathway
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PATHWAYS_DIR="$REPO_ROOT/pathways"
INSTALL_SCRIPT="$REPO_ROOT/scripts/install.sh"

# ── Helpers ──────────────────────────────────────────────────────────

usage() {
    cat <<'USAGE'
Usage: pathway.sh <command> [args]

Commands:
  list              List all available pathways
  show <name>       Show pathway contents (resolves inheritance)
  install <name>    Install all synapses in a pathway
  create <name>     Create a new pathway from template
  export <name>     Export resolved (inheritance-flattened) pathway to stdout

Options:
  -h, --help        Show this help message
USAGE
}

extract_field() {
    local file="$1" field="$2"
    sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d' \
        | { grep "^${field}:" || true; } | head -1 \
        | sed "s/^${field}: *//" | tr -d '"' | tr -d "'"
}

# Extract synapse paths from a given section (skills, agents, protocols, tools).
# Reads lines between the section header and the next section or EOF.
extract_synapses() {
    local file="$1" section="$2"
    # Get content after the second --- (body, not frontmatter)
    local body
    body="$(awk 'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' "$file")"
    # Find lines under "  <section>:" and extract "    - <value>" entries
    echo "$body" | awk -v sec="  ${section}:" '
        $0 == sec { found=1; next }
        found && /^    - / { gsub(/^    - /, ""); print }
        found && /^  [a-z]/ { found=0 }
    '
}

resolve_pathway() {
    local file="$1"
    local inherits
    inherits="$(extract_field "$file" "inherits")"

    local skills agents protocols tools

    if [[ -n "$inherits" && "$inherits" != "" ]]; then
        local parent_file="$PATHWAYS_DIR/${inherits}.yaml"
        if [[ ! -f "$parent_file" ]]; then
            echo "Error: parent pathway '$inherits' not found at $parent_file" >&2
            exit 1
        fi
        # Resolve parent first (recursive)
        local parent_resolved
        parent_resolved="$(resolve_pathway "$parent_file")"

        # Parent synapses
        local p_skills p_agents p_protocols p_tools
        p_skills="$(echo "$parent_resolved" | sed -n '/^SKILLS:$/,/^[A-Z]*:$/{ /^SKILLS:$/d; /^[A-Z]*:$/d; p; }')"
        p_agents="$(echo "$parent_resolved" | sed -n '/^AGENTS:$/,/^[A-Z]*:$/{ /^AGENTS:$/d; /^[A-Z]*:$/d; p; }')"
        p_protocols="$(echo "$parent_resolved" | sed -n '/^PROTOCOLS:$/,/^[A-Z]*:$/{ /^PROTOCOLS:$/d; /^[A-Z]*:$/d; p; }')"
        p_tools="$(echo "$parent_resolved" | sed -n '/^TOOLS:$/,/^END$/{ /^TOOLS:$/d; /^END$/d; p; }')"

        # Child synapses (additive)
        local c_skills c_agents c_protocols c_tools
        c_skills="$(extract_synapses "$file" "skills")"
        c_agents="$(extract_synapses "$file" "agents")"
        c_protocols="$(extract_synapses "$file" "protocols")"
        c_tools="$(extract_synapses "$file" "tools")"

        # Merge (deduplicate)
        skills="$(printf '%s\n%s\n' "$p_skills" "$c_skills" | grep -v '^$' | sort -u)" || true
        agents="$(printf '%s\n%s\n' "$p_agents" "$c_agents" | grep -v '^$' | sort -u)" || true
        protocols="$(printf '%s\n%s\n' "$p_protocols" "$c_protocols" | grep -v '^$' | sort -u)" || true
        tools="$(printf '%s\n%s\n' "$p_tools" "$c_tools" | grep -v '^$' | sort -u)" || true
    else
        skills="$(extract_synapses "$file" "skills")"
        agents="$(extract_synapses "$file" "agents")"
        protocols="$(extract_synapses "$file" "protocols")"
        tools="$(extract_synapses "$file" "tools")"
    fi

    printf 'SKILLS:\n%s\nAGENTS:\n%s\nPROTOCOLS:\n%s\nTOOLS:\n%s\nEND\n' \
        "$skills" "$agents" "$protocols" "$tools"
}

# ── Commands ─────────────────────────────────────────────────────────

cmd_list() {
    local found=0
    printf "%-30s %-10s %s\n" "PATHWAY" "HARNESS" "DESCRIPTION"
    printf "%-30s %-10s %s\n" "-------" "-------" "-----------"
    shopt -s nullglob
    for f in "$PATHWAYS_DIR"/*.yaml; do
        [[ -f "$f" ]] || continue
        found=1
        local name harness description
        name="$(extract_field "$f" "name")"
        harness="$(extract_field "$f" "harness")"
        description="$(extract_field "$f" "description")"
        printf "%-30s %-10s %s\n" "$name" "$harness" "$description"
    done
    if [[ $found -eq 0 ]]; then
        echo "(no pathways found — use 'pathway.sh create <name>' to create one)"
    fi
}

cmd_show() {
    local name="$1"
    local file="$PATHWAYS_DIR/${name}.yaml"
    if [[ ! -f "$file" ]]; then
        echo "Error: pathway '$name' not found at $file" >&2
        exit 1
    fi

    local p_name harness description tags inherits
    p_name="$(extract_field "$file" "name")"
    harness="$(extract_field "$file" "harness")"
    description="$(extract_field "$file" "description")"
    tags="$(extract_field "$file" "tags")"
    inherits="$(extract_field "$file" "inherits")"

    echo "Pathway: $p_name"
    echo "Description: $description"
    echo "Harness: $harness"
    echo "Tags: $tags"
    [[ -n "$inherits" ]] && echo "Inherits: $inherits"
    echo ""

    local resolved
    resolved="$(resolve_pathway "$file")"

    local skills agents protocols tools
    skills="$(echo "$resolved" | sed -n '/^SKILLS:$/,/^[A-Z]*:$/{ /^SKILLS:$/d; /^[A-Z]*:$/d; p; }' | grep -v '^$')" || true
    agents="$(echo "$resolved" | sed -n '/^AGENTS:$/,/^[A-Z]*:$/{ /^AGENTS:$/d; /^[A-Z]*:$/d; p; }' | grep -v '^$')" || true
    protocols="$(echo "$resolved" | sed -n '/^PROTOCOLS:$/,/^[A-Z]*:$/{ /^PROTOCOLS:$/d; /^[A-Z]*:$/d; p; }' | grep -v '^$')" || true
    tools="$(echo "$resolved" | sed -n '/^TOOLS:$/,/^END$/{ /^TOOLS:$/d; /^END$/d; p; }' | grep -v '^$')" || true

    echo "Synapses:"
    if [[ -n "$skills" ]]; then
        echo "  Skills:"
        echo "$skills" | sed 's/^/    - /'
    fi
    if [[ -n "$agents" ]]; then
        echo "  Agents:"
        echo "$agents" | sed 's/^/    - /'
    fi
    if [[ -n "$protocols" ]]; then
        echo "  Protocols:"
        echo "$protocols" | sed 's/^/    - /'
    fi
    if [[ -n "$tools" ]]; then
        echo "  Tools:"
        echo "$tools" | sed 's/^/    - /'
    fi
    if [[ -z "$skills" && -z "$agents" && -z "$protocols" && -z "$tools" ]]; then
        echo "  (empty — no synapses defined)"
    fi
}

cmd_install() {
    local name="$1"
    local file="$PATHWAYS_DIR/${name}.yaml"
    if [[ ! -f "$file" ]]; then
        echo "Error: pathway '$name' not found at $file" >&2
        exit 1
    fi

    local harness
    harness="$(extract_field "$file" "harness")"
    if [[ -z "$harness" ]]; then
        echo "Error: pathway '$name' has no harness field" >&2
        exit 1
    fi

    local resolved
    resolved="$(resolve_pathway "$file")"

    local skills agents
    skills="$(echo "$resolved" | sed -n '/^SKILLS:$/,/^[A-Z]*:$/{ /^SKILLS:$/d; /^[A-Z]*:$/d; p; }' | grep -v '^$')" || true
    agents="$(echo "$resolved" | sed -n '/^AGENTS:$/,/^[A-Z]*:$/{ /^AGENTS:$/d; /^[A-Z]*:$/d; p; }' | grep -v '^$')" || true

    echo "Installing pathway: $name (harness: $harness)"
    echo ""

    # Install skills
    if [[ -n "$skills" ]]; then
        local skill_paths=()
        while IFS= read -r s; do
            skill_paths+=("$s")
        done <<< "$skills"

        case "$harness" in
            claude)
                "$INSTALL_SCRIPT" install "${skill_paths[@]}"
                ;;
            codex)
                "$INSTALL_SCRIPT" codex "${skill_paths[@]}"
                ;;
            gemini)
                "$INSTALL_SCRIPT" gemini "${skill_paths[@]}"
                ;;
            multi)
                "$INSTALL_SCRIPT" install "${skill_paths[@]}"
                "$INSTALL_SCRIPT" codex "${skill_paths[@]}"
                "$INSTALL_SCRIPT" gemini "${skill_paths[@]}"
                ;;
            *)
                echo "Error: unknown harness '$harness'" >&2
                exit 1
                ;;
        esac
    fi

    # Install agents
    if [[ -n "$agents" ]]; then
        echo ""
        echo "Installing agents..."
        "$INSTALL_SCRIPT" agents
    fi

    echo ""
    echo "Pathway '$name' installed successfully."
}

cmd_create() {
    local name="$1"
    local file="$PATHWAYS_DIR/${name}.yaml"
    if [[ -f "$file" ]]; then
        echo "Error: pathway '$name' already exists at $file" >&2
        exit 1
    fi

    cat > "$file" <<EOF
---
name: ${name}
description: ""
harness: claude
tags: []
# inherits: <parent-pathway-name>
---

synapses:
  skills: []
  agents: []
  protocols: []
  tools: []
EOF

    echo "Created pathways/${name}.yaml — edit it to add synapses."
}

cmd_export() {
    local name="$1"
    local file="$PATHWAYS_DIR/${name}.yaml"
    if [[ ! -f "$file" ]]; then
        echo "Error: pathway '$name' not found at $file" >&2
        exit 1
    fi

    local p_name harness description tags
    p_name="$(extract_field "$file" "name")"
    harness="$(extract_field "$file" "harness")"
    description="$(extract_field "$file" "description")"
    tags="$(extract_field "$file" "tags")"

    local resolved
    resolved="$(resolve_pathway "$file")"

    local skills agents protocols tools
    skills="$(echo "$resolved" | sed -n '/^SKILLS:$/,/^[A-Z]*:$/{ /^SKILLS:$/d; /^[A-Z]*:$/d; p; }' | grep -v '^$')" || true
    agents="$(echo "$resolved" | sed -n '/^AGENTS:$/,/^[A-Z]*:$/{ /^AGENTS:$/d; /^[A-Z]*:$/d; p; }' | grep -v '^$')" || true
    protocols="$(echo "$resolved" | sed -n '/^PROTOCOLS:$/,/^[A-Z]*:$/{ /^PROTOCOLS:$/d; /^[A-Z]*:$/d; p; }' | grep -v '^$')" || true
    tools="$(echo "$resolved" | sed -n '/^TOOLS:$/,/^END$/{ /^TOOLS:$/d; /^END$/d; p; }' | grep -v '^$')" || true

    # Output resolved YAML
    echo "---"
    echo "name: ${p_name}"
    echo "description: \"${description}\""
    echo "harness: ${harness}"
    echo "tags: [${tags}]"
    echo "---"
    echo ""
    echo "synapses:"

    echo "  skills:"
    if [[ -n "$skills" ]]; then
        echo "$skills" | sed 's/^/    - /'
    else
        echo "    []"
    fi

    echo "  agents:"
    if [[ -n "$agents" ]]; then
        echo "$agents" | sed 's/^/    - /'
    else
        echo "    []"
    fi

    echo "  protocols:"
    if [[ -n "$protocols" ]]; then
        echo "$protocols" | sed 's/^/    - /'
    else
        echo "    []"
    fi

    echo "  tools:"
    if [[ -n "$tools" ]]; then
        echo "$tools" | sed 's/^/    - /'
    else
        echo "    []"
    fi
}

# ── Main dispatch ────────────────────────────────────────────────────

case "${1:-}" in
    list)
        cmd_list
        ;;
    show)
        [[ -z "${2:-}" ]] && { echo "Error: 'show' requires a pathway name" >&2; usage; exit 1; }
        cmd_show "$2"
        ;;
    install)
        [[ -z "${2:-}" ]] && { echo "Error: 'install' requires a pathway name" >&2; usage; exit 1; }
        cmd_install "$2"
        ;;
    create)
        [[ -z "${2:-}" ]] && { echo "Error: 'create' requires a pathway name" >&2; usage; exit 1; }
        cmd_create "$2"
        ;;
    export)
        [[ -z "${2:-}" ]] && { echo "Error: 'export' requires a pathway name" >&2; usage; exit 1; }
        cmd_export "$2"
        ;;
    -h|--help|"")
        usage
        ;;
    *)
        echo "Error: unknown command '$1'" >&2
        usage
        exit 1
        ;;
esac
