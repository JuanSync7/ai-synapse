#!/usr/bin/env bash
# @name: reorganize
# @description: Domain-based artifact reorganization utility
# @audience: maintainer
# @action: repair
# @scope: repo
set -euo pipefail

# Domain-based artifact reorganization for ai-synapse.
#
# Frontmatter `domain` is the source of truth. Directory structure is derived.
# Skills use dot notation (docs.spec → top-level dir "docs").
# Agents and protocols use flat domain names.
#
# When a domain directory gets crowded, split at a deeper dot-depth:
#   reorganize split protocols frontend 2
# This moves protocols with domain "frontend.X" into "frontend/X/" subdirs.
#
# Commands:
#   status   [type]              Show current vs expected placement
#   validate [type]              Exit 1 if any artifact is misplaced
#   plan     <type> <domain> <depth>  Dry-run of split
#   split    <type> <domain> <depth>  Move artifacts into subdomain dirs
#   merge    <type> <domain>          Flatten subdomain dirs back to parent

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Artifact type configs
# Each type: source dir, frontmatter domain field, file discovery pattern
# Framework reorganization defaults to synapse/. Override with REORG_ROOT=src for adopter content.
REORG_ROOT="${REORG_ROOT:-synapse}"
declare -A TYPE_SOURCE=(
    [skills]="${REORG_ROOT}/skills"
    [agents]="${REORG_ROOT}/agents"
    [protocols]="${REORG_ROOT}/protocols"
)

# External suites directory
EXTERNAL_DIR="$REPO_ROOT/external"

# Registry files that contain paths to artifacts
AGENTS_REGISTRY="$REPO_ROOT/registry/AGENTS_REGISTRY.md"
PROTOCOL_REGISTRY="$REPO_ROOT/registry/PROTOCOL_REGISTRY.md"

# ============================================================================
# Helpers
# ============================================================================

usage() {
    echo "Usage: reorganize <command> [args...]"
    echo ""
    echo "Commands:"
    echo "  status   [skills|agents|protocols]       Show current vs expected placement for all artifacts"
    echo "  validate [skills|agents|protocols]        Check all artifacts are in the correct directory (exit 1 if not)"
    echo "  plan     <type> <domain> <depth>          Dry-run: show what split would do"
    echo "  split    <type> <domain> <depth>          Split domain dir into subdomain dirs"
    echo "  merge    <type> <domain>                  Flatten subdomain dirs back into parent"
    echo ""
    echo "Examples:"
    echo "  reorganize status                         # all artifact types"
    echo "  reorganize status protocols               # protocols only"
    echo "  reorganize validate                       # check everything"
    echo "  reorganize plan protocols frontend 2      # preview split"
    echo "  reorganize split protocols frontend 2     # execute split"
    echo "  reorganize merge protocols frontend       # flatten back"
}

# Extract a frontmatter field value from a markdown file.
# Usage: extract_field <file> <field>
extract_field() {
    local file="$1"
    local field="$2"
    sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d' \
        | grep "^${field}:" | head -1 \
        | sed "s/^${field}: *//" | tr -d '"' | tr -d "'"
}

# Given a domain value and a depth, return the expected directory path segments.
# e.g., domain="docs.spec.api" depth=1 → "docs"
#        domain="docs.spec.api" depth=2 → "docs/spec"
#        domain="frontend" depth=1 → "frontend"
domain_to_dir() {
    local domain="$1"
    local depth="${2:-1}"
    local IFS='.'
    read -ra parts <<< "$domain"
    local result=""
    local i=0
    while [ "$i" -lt "$depth" ] && [ "$i" -lt "${#parts[@]}" ]; do
        if [ -n "$result" ]; then
            result="$result/${parts[$i]}"
        else
            result="${parts[$i]}"
        fi
        i=$((i + 1))
    done
    echo "$result"
}

# Infer current directory depth for a given type+domain by looking at the filesystem.
# Walks the directory tree and returns the deepest level that contains artifact files.
infer_depth() {
    local type="$1"
    local domain_top="$2"
    local source_dir="$REPO_ROOT/${TYPE_SOURCE[$type]}/$domain_top"

    if [ ! -d "$source_dir" ]; then
        echo "1"
        return
    fi

    local max_depth=1

    if [ "$type" = "skills" ]; then
        # Skills: look for SKILL.md — the parent dir is the skill dir, its parent is the domain dir
        while IFS= read -r skill_md; do
            local skill_dir
            skill_dir="$(dirname "$skill_md")"
            local domain_dir
            domain_dir="$(dirname "$skill_dir")"
            local rel="${domain_dir#$REPO_ROOT/${TYPE_SOURCE[$type]}/}"
            local depth
            depth="$(echo "$rel" | tr '/' '\n' | wc -l)"
            if [ "$depth" -gt "$max_depth" ]; then
                max_depth="$depth"
            fi
        done < <(find "$source_dir" -name "SKILL.md" -type f 2>/dev/null)
    else
        # Agents/protocols: look for .md files (not README.md)
        while IFS= read -r md_file; do
            local dir
            dir="$(dirname "$md_file")"
            local rel="${dir#$REPO_ROOT/${TYPE_SOURCE[$type]}/}"
            local depth
            depth="$(echo "$rel" | tr '/' '\n' | wc -l)"
            if [ "$depth" -gt "$max_depth" ]; then
                max_depth="$depth"
            fi
        done < <(find "$source_dir" -name "*.md" -not -name "README.md" -type f 2>/dev/null)
    fi

    echo "$max_depth"
}

# Discover all artifacts of a type. Outputs lines: <filepath> <domain-from-frontmatter>
# For skills: filepath is the SKILL.md path
# For agents/protocols: filepath is the .md file path
discover_artifacts() {
    local type="$1"
    local source_dir="$REPO_ROOT/${TYPE_SOURCE[$type]}"

    if [ ! -d "$source_dir" ]; then
        return
    fi

    if [ "$type" = "skills" ]; then
        while IFS= read -r skill_md; do
            local domain
            domain="$(extract_field "$skill_md" "domain")"
            echo "$skill_md $domain"
        done < <(find "$source_dir" -name "SKILL.md" -type f 2>/dev/null | sort)
    else
        while IFS= read -r md_file; do
            local domain
            domain="$(extract_field "$md_file" "domain")"
            echo "$md_file $domain"
        done < <(find "$source_dir" -name "*.md" -not -name "README.md" -not -path "*/change_requests/*" -type f 2>/dev/null | sort)
    fi
}

# Discover artifacts in external/ suites. Each suite may contain skills/, agents/, protocols/.
# Outputs lines: <filepath> <domain-from-frontmatter> <suite-name>
discover_external() {
    local type="$1"

    [ -d "$EXTERNAL_DIR" ] || return

    # Map type to internal dir names suites might use
    local subdir_name
    case "$type" in
        skills)    subdir_name="skills" ;;
        agents)    subdir_name="agents" ;;
        protocols) subdir_name="protocols" ;;
    esac

    for suite_dir in "$EXTERNAL_DIR"/*/; do
        [ -d "$suite_dir" ] || continue
        local suite_name
        suite_name="$(basename "$suite_dir")"
        local search_dir="$suite_dir$subdir_name"

        if [ ! -d "$search_dir" ]; then
            continue
        fi

        if [ "$type" = "skills" ]; then
            while IFS= read -r skill_md; do
                local domain
                domain="$(extract_field "$skill_md" "domain")"
                echo "$skill_md $domain $suite_name"
            done < <(find "$search_dir" -name "SKILL.md" -type f 2>/dev/null | sort)
        else
            while IFS= read -r md_file; do
                local domain
                domain="$(extract_field "$md_file" "domain")"
                echo "$md_file $domain $suite_name"
            done < <(find "$search_dir" -name "*.md" -not -name "README.md" -not -path "*/change_requests/*" -type f 2>/dev/null | sort)
        fi
    done
}

# Get the expected directory for an artifact given its type, domain, and the current
# depth of its top-level domain in the filesystem.
expected_dir_for_artifact() {
    local type="$1"
    local domain="$2"
    local source_dir="$REPO_ROOT/${TYPE_SOURCE[$type]}"

    # Get top-level domain
    local top_domain="${domain%%.*}"
    # Infer current depth from filesystem
    local depth
    depth="$(infer_depth "$type" "$top_domain")"
    # Compute expected dir
    local subdir
    subdir="$(domain_to_dir "$domain" "$depth")"

    echo "$source_dir/$subdir"
}

# ============================================================================
# Commands
# ============================================================================

cmd_status() {
    local filter="${1:-all}"
    local types=()

    if [ "$filter" = "all" ]; then
        types=(skills agents protocols)
    else
        types=("$filter")
    fi

    for type in "${types[@]}"; do
        echo "=== $type ==="
        echo ""

        local source_dir="$REPO_ROOT/${TYPE_SOURCE[$type]}"
        if [ ! -d "$source_dir" ]; then
            echo "  (no $type directory)"
            echo ""
            continue
        fi

        local count=0
        local misplaced=0

        while IFS=' ' read -r filepath domain; do
            [ -z "$filepath" ] && continue
            count=$((count + 1))

            local expected_dir
            expected_dir="$(expected_dir_for_artifact "$type" "$domain")"

            local actual_dir
            if [ "$type" = "skills" ]; then
                # For skills, the artifact dir is parent of SKILL.md, domain dir is grandparent
                actual_dir="$(dirname "$(dirname "$filepath")")"
            else
                actual_dir="$(dirname "$filepath")"
            fi

            local artifact_name
            if [ "$type" = "skills" ]; then
                artifact_name="$(basename "$(dirname "$filepath")")"
            else
                artifact_name="$(basename "$filepath" .md)"
            fi

            local rel_actual="${actual_dir#$REPO_ROOT/}"
            local rel_expected="${expected_dir#$REPO_ROOT/}"

            if [ "$actual_dir" = "$expected_dir" ]; then
                printf "  %-35s  %-25s  %s\n" "$artifact_name" "domain: $domain" "OK ($rel_actual)"
            else
                printf "  %-35s  %-25s  %s → %s\n" "$artifact_name" "domain: $domain" "MOVE $rel_actual" "$rel_expected"
                misplaced=$((misplaced + 1))
            fi
        done < <(discover_artifacts "$type")

        echo ""
        echo "  $count artifact(s), $misplaced misplaced"

        # External artifacts (read-only listing)
        local ext_count=0
        local ext_output=""
        while IFS=' ' read -r filepath domain suite_name; do
            [ -z "$filepath" ] && continue
            ext_count=$((ext_count + 1))

            local artifact_name
            if [ "$type" = "skills" ]; then
                artifact_name="$(basename "$(dirname "$filepath")")"
            else
                artifact_name="$(basename "$filepath" .md)"
            fi

            ext_output+="$(printf "  %-35s  %-25s  %s\n" "$artifact_name" "domain: $domain" "EXTERNAL ($suite_name)")"$'\n'
        done < <(discover_external "$type")

        if [ "$ext_count" -gt 0 ]; then
            echo ""
            echo "  --- external ---"
            echo "$ext_output"
            echo "  $ext_count external artifact(s)"
        fi
        echo ""
    done
}

cmd_validate() {
    local filter="${1:-all}"
    local types=()

    if [ "$filter" = "all" ]; then
        types=(skills agents protocols)
    else
        types=("$filter")
    fi

    local total_misplaced=0

    for type in "${types[@]}"; do
        while IFS=' ' read -r filepath domain; do
            [ -z "$filepath" ] && continue

            local expected_dir
            expected_dir="$(expected_dir_for_artifact "$type" "$domain")"

            local actual_dir
            if [ "$type" = "skills" ]; then
                actual_dir="$(dirname "$(dirname "$filepath")")"
            else
                actual_dir="$(dirname "$filepath")"
            fi

            if [ "$actual_dir" != "$expected_dir" ]; then
                local artifact_name
                if [ "$type" = "skills" ]; then
                    artifact_name="$(basename "$(dirname "$filepath")")"
                else
                    artifact_name="$(basename "$filepath" .md)"
                fi
                local rel_actual="${actual_dir#$REPO_ROOT/}"
                local rel_expected="${expected_dir#$REPO_ROOT/}"
                echo "  MISPLACED  $artifact_name ($type): $rel_actual → should be $rel_expected"
                total_misplaced=$((total_misplaced + 1))
            fi
        done < <(discover_artifacts "$type")
    done

    if [ "$total_misplaced" -gt 0 ]; then
        echo ""
        echo "$total_misplaced artifact(s) misplaced. Run 'reorganize split' to fix."
        exit 1
    else
        echo "All artifacts correctly placed."
    fi
}

# Plan or execute a split.
# Usage: cmd_split_or_plan <type> <domain> <depth> <dry_run>
cmd_split_or_plan() {
    local type="$1"
    local domain_arg="$2"
    local target_depth="$3"
    local dry_run="$4"  # "true" or "false"

    # Accept dotted domain (integration.jira) or top-level (integration)
    local domain_top="${domain_arg%%.*}"

    local source_dir="$REPO_ROOT/${TYPE_SOURCE[$type]}"
    local domain_dir="$source_dir/$domain_top"

    if [ ! -d "$domain_dir" ]; then
        echo "Error: directory $domain_dir does not exist"
        exit 1
    fi

    local action_verb="move"
    if [ "$dry_run" = "true" ]; then
        action_verb="would move"
    fi

    local moves=()
    local move_count=0

    # Collect moves
    while IFS=' ' read -r filepath domain; do
        [ -z "$filepath" ] && continue

        # Only process artifacts in this top-level domain
        local file_top="${domain%%.*}"
        if [ "$file_top" != "$domain_top" ]; then
            continue
        fi

        local subdir
        subdir="$(domain_to_dir "$domain" "$target_depth")"
        local new_parent="$source_dir/$subdir"

        local actual_dir
        local artifact_name
        if [ "$type" = "skills" ]; then
            local skill_dir
            skill_dir="$(dirname "$filepath")"
            actual_dir="$(dirname "$skill_dir")"
            artifact_name="$(basename "$skill_dir")"
        else
            actual_dir="$(dirname "$filepath")"
            artifact_name="$(basename "$filepath" .md)"
        fi

        if [ "$actual_dir" = "$new_parent" ]; then
            continue
        fi

        local rel_from="${actual_dir#$REPO_ROOT/}"
        local rel_to="${new_parent#$REPO_ROOT/}"

        if [ "$type" = "skills" ]; then
            echo "  $action_verb  $artifact_name/  $rel_from/$artifact_name/ → $rel_to/$artifact_name/"
            moves+=("$filepath|$new_parent/$artifact_name")
        else
            echo "  $action_verb  $artifact_name.md  $rel_from/$artifact_name.md → $rel_to/$artifact_name.md"
            moves+=("$filepath|$new_parent/$artifact_name.md")
        fi
        move_count=$((move_count + 1))
    done < <(discover_artifacts "$type")

    if [ "$move_count" -eq 0 ]; then
        echo "  Nothing to move — all artifacts in '$domain_top' already at depth $target_depth."
        return
    fi

    echo ""
    echo "$move_count artifact(s) to $action_verb."

    if [ "$dry_run" = "true" ]; then
        return
    fi

    echo ""
    echo "Executing moves..."

    for move in "${moves[@]}"; do
        local from="${move%%|*}"
        local to="${move##*|}"
        local to_dir
        to_dir="$(dirname "$to")"

        mkdir -p "$to_dir"

        if [ "$type" = "skills" ]; then
            # Move entire skill directory
            local from_dir
            from_dir="$(dirname "$from")"
            mv "$from_dir" "$to"
        else
            mv "$from" "$to"
        fi
    done

    echo "Moves complete."

    # Update references
    echo ""
    echo "Updating references..."
    update_references "$type" "$domain_top"

    # Clean up empty directories
    cleanup_empty_dirs "$source_dir/$domain_top"

    echo ""
    echo "Done. Run 'reorganize validate $type' to verify."
}

cmd_merge() {
    local type="$1"
    local domain_top="$2"

    local source_dir="$REPO_ROOT/${TYPE_SOURCE[$type]}"
    local domain_dir="$source_dir/$domain_top"

    if [ ! -d "$domain_dir" ]; then
        echo "Error: directory $domain_dir does not exist"
        exit 1
    fi

    local move_count=0

    # Find all artifacts in subdirs and move them to the top-level domain dir
    while IFS=' ' read -r filepath domain; do
        [ -z "$filepath" ] && continue

        local file_top="${domain%%.*}"
        if [ "$file_top" != "$domain_top" ]; then
            continue
        fi

        local actual_dir
        local artifact_name
        if [ "$type" = "skills" ]; then
            local skill_dir
            skill_dir="$(dirname "$filepath")"
            actual_dir="$(dirname "$skill_dir")"
            artifact_name="$(basename "$skill_dir")"
        else
            actual_dir="$(dirname "$filepath")"
            artifact_name="$(basename "$filepath" .md)"
        fi

        # Already at top level?
        if [ "$actual_dir" = "$domain_dir" ]; then
            continue
        fi

        local rel_from="${actual_dir#$REPO_ROOT/}"
        echo "  move  $artifact_name  $rel_from → ${TYPE_SOURCE[$type]}/$domain_top/"

        if [ "$type" = "skills" ]; then
            mv "$(dirname "$filepath")" "$domain_dir/$artifact_name"
        else
            mv "$filepath" "$domain_dir/$artifact_name.md"
        fi
        move_count=$((move_count + 1))
    done < <(discover_artifacts "$type")

    if [ "$move_count" -eq 0 ]; then
        echo "  Nothing to merge — '$domain_top' is already flat."
        return
    fi

    echo ""
    echo "$move_count artifact(s) merged."

    # Update references
    echo ""
    echo "Updating references..."
    update_references "$type" "$domain_top"

    # Clean up empty subdirectories
    cleanup_empty_dirs "$domain_dir"

    echo ""
    echo "Done. Run 'reorganize validate $type' to verify."
}

# ============================================================================
# Reference updating
# ============================================================================

update_references() {
    local type="$1"
    local domain_top="$2"

    # 1. Regenerate domain README(s)
    regenerate_domain_readmes "$type" "$domain_top"

    # 2. Update parent README
    regenerate_parent_readme "$type"

    # 3. Update registries
    if [ "$type" = "agents" ]; then
        update_registry_paths "$AGENTS_REGISTRY" "$type"
    elif [ "$type" = "protocols" ]; then
        update_registry_paths "$PROTOCOL_REGISTRY" "$type"
    fi

    # 4. Update symlinks in skill directories that point to moved artifacts
    if [ "$type" = "agents" ] || [ "$type" = "protocols" ]; then
        update_symlinks "$type"
    fi
}

# Regenerate domain README(s) for a given type and top-level domain.
# Discovers all artifacts in the domain and groups by their immediate parent dir.
regenerate_domain_readmes() {
    local type="$1"
    local domain_top="$2"
    local source_dir="$REPO_ROOT/${TYPE_SOURCE[$type]}"
    local domain_dir="$source_dir/$domain_top"

    # Collect all subdirectories that contain artifacts
    local -A dir_artifacts  # dir → list of "name|field2_value|description" entries

    while IFS=' ' read -r filepath domain; do
        [ -z "$filepath" ] && continue

        local file_top="${domain%%.*}"
        if [ "$file_top" != "$domain_top" ]; then
            continue
        fi

        local artifact_dir
        local artifact_name
        local description
        local field2_name field2_value

        if [ "$type" = "skills" ]; then
            artifact_dir="$(dirname "$(dirname "$filepath")")"
            artifact_name="$(basename "$(dirname "$filepath")")"
            description="$(extract_field "$filepath" "description")"
            field2_name="intent"
            field2_value="$(extract_field "$filepath" "intent")"
        elif [ "$type" = "agents" ]; then
            artifact_dir="$(dirname "$filepath")"
            artifact_name="$(basename "$filepath" .md)"
            description="$(extract_field "$filepath" "description")"
            field2_name="role"
            field2_value="$(extract_field "$filepath" "role")"
        else
            artifact_dir="$(dirname "$filepath")"
            artifact_name="$(basename "$filepath" .md)"
            description="$(extract_field "$filepath" "description")"
            field2_name="type"
            field2_value="$(extract_field "$filepath" "type")"
        fi

        local rel_dir="${artifact_dir#$REPO_ROOT/}"
        local key="$artifact_dir"

        if [ -z "${dir_artifacts[$key]+x}" ]; then
            dir_artifacts[$key]=""
        fi
        dir_artifacts[$key]+="$artifact_name|$field2_value|$description"$'\n'
    done < <(discover_artifacts "$type")

    # For each directory that has artifacts, write/update its README.md
    for dir in "${!dir_artifacts[@]}"; do
        local readme="$dir/README.md"
        local dir_name
        dir_name="$(basename "$dir")"
        local rel_dir="${dir#$REPO_ROOT/${TYPE_SOURCE[$type]}/}"

        # Determine section header and field2 column name
        local section_name field2_col
        case "$type" in
            skills)    section_name="Skills"; field2_col="Intent" ;;
            agents)    section_name="Agents"; field2_col="Role" ;;
            protocols) section_name="Protocols"; field2_col="Type" ;;
        esac

        # Try to preserve the first line description if README exists
        local header_desc=""
        if [ -f "$readme" ]; then
            header_desc="$(sed -n '3p' "$readme" 2>/dev/null || true)"
            # Only keep if it's not a table or heading
            if echo "$header_desc" | grep -q '^[|#]'; then
                header_desc=""
            fi
        fi

        # Build README content
        {
            echo "# $dir_name"
            echo ""
            if [ -n "$header_desc" ]; then
                echo "$header_desc"
            fi
            echo ""
            echo "## $section_name"
            echo ""

            if [ "$type" = "skills" ]; then
                echo "| Skill | Intent | Description |"
                echo "|-------|--------|-------------|"
            elif [ "$type" = "agents" ]; then
                echo "| Agent | Role | Description |"
                echo "|-------|------|-------------|"
            else
                echo "| Protocol | Type | Description |"
                echo "|----------|------|-------------|"
            fi

            while IFS= read -r entry; do
                [ -z "$entry" ] && continue
                local name field2 desc
                name="${entry%%|*}"
                local rest="${entry#*|}"
                field2="${rest%%|*}"
                desc="${rest#*|}"

                if [ "$type" = "skills" ]; then
                    echo "| [$name]($name/) | $field2 | $desc |"
                else
                    echo "| [$name]($name.md) | $field2 | $desc |"
                fi
            done <<< "${dir_artifacts[$dir]}"
        } > "$readme"

        echo "  readme  ${readme#$REPO_ROOT/}"
    done

    # Check if there are subdirectories — if so, regenerate the domain-top README
    # as a parent pointing to subdirs
    local has_subdirs=false
    for dir in "${!dir_artifacts[@]}"; do
        if [ "$dir" != "$domain_dir" ]; then
            has_subdirs=true
            break
        fi
    done

    if [ "$has_subdirs" = true ]; then
        # Domain-top README should be a parent listing subdirectories
        local readme="$domain_dir/README.md"
        local dir_name
        dir_name="$(basename "$domain_dir")"

        # Preserve header description
        local header_desc=""
        if [ -f "$readme" ]; then
            header_desc="$(sed -n '3p' "$readme" 2>/dev/null || true)"
            if echo "$header_desc" | grep -q '^[|#]'; then
                header_desc=""
            fi
        fi

        {
            echo "# $dir_name"
            echo ""
            if [ -n "$header_desc" ]; then
                echo "$header_desc"
            fi
            echo ""
            echo "| Subdomain | Description |"
            echo "|-----------|-------------|"

            # List each subdirectory
            for dir in $(echo "${!dir_artifacts[@]}" | tr ' ' '\n' | sort); do
                if [ "$dir" = "$domain_dir" ]; then
                    continue
                fi
                local subdir_name
                subdir_name="$(basename "$dir")"
                # Count artifacts in this subdir
                local artifact_count
                artifact_count="$(echo -n "${dir_artifacts[$dir]}" | grep -c '.' || true)"
                echo "| [$subdir_name/]($subdir_name/) | $artifact_count artifact(s) |"
            done

            # If there are also artifacts directly in domain_dir, list them
            if [ -n "${dir_artifacts[$domain_dir]+x}" ] && [ -n "${dir_artifacts[$domain_dir]}" ]; then
                echo ""
                echo "## Direct"
                echo ""

                local section_name field2_col
                case "$type" in
                    skills)    echo "| Skill | Intent | Description |"; echo "|-------|--------|-------------|" ;;
                    agents)    echo "| Agent | Role | Description |"; echo "|-------|------|-------------|" ;;
                    protocols) echo "| Protocol | Type | Description |"; echo "|----------|------|-------------|" ;;
                esac

                while IFS= read -r entry; do
                    [ -z "$entry" ] && continue
                    local name field2 desc
                    name="${entry%%|*}"
                    local rest="${entry#*|}"
                    field2="${rest%%|*}"
                    desc="${rest#*|}"
                    if [ "$type" = "skills" ]; then
                        echo "| [$name]($name/) | $field2 | $desc |"
                    else
                        echo "| [$name]($name.md) | $field2 | $desc |"
                    fi
                done <<< "${dir_artifacts[$domain_dir]}"
            fi
        } > "$readme"

        echo "  readme  ${readme#$REPO_ROOT/} (parent)"
    fi
}

# Regenerate the parent README (e.g., src/agents/README.md) listing all domain dirs.
regenerate_parent_readme() {
    local type="$1"
    local source_dir="$REPO_ROOT/${TYPE_SOURCE[$type]}"
    local readme="$source_dir/README.md"

    # Preserve header
    local header_line=""
    local desc_line=""
    if [ -f "$readme" ]; then
        header_line="$(sed -n '1p' "$readme" 2>/dev/null || true)"
        desc_line="$(sed -n '3p' "$readme" 2>/dev/null || true)"
        if echo "$desc_line" | grep -q '^[|#]'; then
            desc_line=""
        fi
    else
        local type_name
        type_name="$(basename "$source_dir")"
        header_line="# $type_name"
    fi

    {
        echo "$header_line"
        echo ""
        if [ -n "$desc_line" ]; then
            echo "$desc_line"
            echo ""
        fi
        echo "| Domain | Description |"
        echo "|--------|-------------|"

        for domain_dir in "$source_dir"/*/; do
            [ -d "$domain_dir" ] || continue
            local domain_name
            domain_name="$(basename "$domain_dir")"
            # Get description from domain README first line after heading
            local domain_desc=""
            if [ -f "$domain_dir/README.md" ]; then
                domain_desc="$(sed -n '3p' "$domain_dir/README.md" 2>/dev/null || true)"
                if echo "$domain_desc" | grep -q '^[|#]'; then
                    domain_desc=""
                fi
            fi
            echo "| [$domain_name/]($domain_name/) | ${domain_desc:-—} |"
        done
    } > "$readme"

    echo "  readme  ${readme#$REPO_ROOT/} (parent)"
}

# Update paths in a registry file to match current artifact locations.
update_registry_paths() {
    local registry_file="$1"
    local type="$2"

    if [ ! -f "$registry_file" ]; then
        echo "  skip  registry (file not found)"
        return
    fi

    local source_prefix="${TYPE_SOURCE[$type]}"

    # Build a mapping: artifact_name → current_relative_path
    local -A name_to_path

    while IFS=' ' read -r filepath domain; do
        [ -z "$filepath" ] && continue
        local artifact_name
        if [ "$type" = "skills" ]; then
            artifact_name="$(basename "$(dirname "$filepath")")"
        else
            artifact_name="$(basename "$filepath" .md)"
        fi
        local rel_path="${filepath#$REPO_ROOT/}"
        name_to_path[$artifact_name]="$rel_path"
    done < <(discover_artifacts "$type")

    # For each artifact in the mapping, update the registry link
    local updated=false
    for name in "${!name_to_path[@]}"; do
        local new_path="${name_to_path[$name]}"
        # Match markdown links like [name](old/path/to/name.md)
        if grep -q "\[$name\](" "$registry_file"; then
            # Extract current path
            local current_path
            current_path="$(grep "\[$name\](" "$registry_file" | head -1 | sed "s/.*\[$name\](\([^)]*\)).*/\1/")"
            if [ "$current_path" != "$new_path" ]; then
                sed -i "s|\[$name\]([^)]*)|[$name]($new_path)|g" "$registry_file"
                echo "  registry  $name: $current_path → $new_path"
                updated=true
            fi
        fi
    done

    if [ "$updated" = false ]; then
        echo "  registry  (no path changes needed)"
    fi
}

# Find and fix symlinks in skill directories that point to moved agents/protocols.
update_symlinks() {
    local type="$1"
    local source_dir="$REPO_ROOT/${TYPE_SOURCE[$type]}"

    # Build name→path mapping
    local -A name_to_path
    while IFS=' ' read -r filepath domain; do
        [ -z "$filepath" ] && continue
        local artifact_name
        artifact_name="$(basename "$filepath" .md)"
        name_to_path[$artifact_name]="$filepath"
    done < <(discover_artifacts "$type")

    # Find all symlinks under src/skills/ and check if they point to our type's artifacts
    local updated=false
    while IFS= read -r symlink; do
        local target
        target="$(readlink "$symlink")"
        local resolved
        resolved="$(cd "$(dirname "$symlink")" && realpath -m "$target" 2>/dev/null || echo "")"

        # Check if this symlink's name matches an artifact we know about
        local link_name
        link_name="$(basename "$symlink" .md)"

        if [ -n "${name_to_path[$link_name]+x}" ]; then
            local expected="${name_to_path[$link_name]}"
            if [ "$resolved" != "$expected" ]; then
                # Compute new relative path from symlink location to artifact
                local link_dir
                link_dir="$(dirname "$symlink")"
                local new_rel
                new_rel="$(python3 -c "import os; print(os.path.relpath('$expected', '$link_dir'))")"

                rm "$symlink"
                ln -s "$new_rel" "$symlink"
                echo "  symlink  $(basename "$symlink"): $target → $new_rel"
                updated=true
            fi
        fi
    done < <(find "$REPO_ROOT/synapse/skills" "$REPO_ROOT/src/skills" -type l 2>/dev/null)

    if [ "$updated" = false ]; then
        echo "  symlinks  (no updates needed)"
    fi
}

# Remove empty directories left after moves.
cleanup_empty_dirs() {
    local dir="$1"
    # Remove empty subdirs (bottom-up), but keep the top dir itself
    find "$dir" -mindepth 1 -type d -empty -delete 2>/dev/null || true
}

# ============================================================================
# Main
# ============================================================================

case "${1:-}" in
    status)
        shift
        cmd_status "${1:-all}"
        ;;
    validate)
        shift
        cmd_validate "${1:-all}"
        ;;
    plan)
        shift
        if [ $# -lt 3 ]; then
            echo "Usage: reorganize plan <type> <domain> <depth>"
            exit 1
        fi
        cmd_split_or_plan "$1" "$2" "$3" "true"
        ;;
    split)
        shift
        if [ $# -lt 3 ]; then
            echo "Usage: reorganize split <type> <domain> <depth>"
            exit 1
        fi
        cmd_split_or_plan "$1" "$2" "$3" "false"
        ;;
    merge)
        shift
        if [ $# -lt 2 ]; then
            echo "Usage: reorganize merge <type> <domain>"
            exit 1
        fi
        cmd_merge "$1" "$2"
        ;;
    -h|--help|"")
        usage
        ;;
    *)
        echo "Unknown command: $1"
        usage
        exit 1
        ;;
esac
