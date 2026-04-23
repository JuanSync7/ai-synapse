#!/usr/bin/env bash
# @name: audit-artifacts
# @description: Inventory and promotion-signal audit for companion artifacts
# @audience: maintainer
# @action: inspect
# @scope: repo
set -euo pipefail

# Companion artifacts are agents, tools, and protocols that live inside skill directories.

REPO_ROOT="$(git rev-parse --show-toplevel)"

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------

usage() {
    echo "Usage: audit-artifacts.sh [command]"
    echo ""
    echo "Commands:"
    echo "  inventory   List all companion artifacts in skill directories"
    echo "  signals     Show promotion signals (copies that should be symlinks, duplicates)"
    echo "  fix         Auto-convert identical copies to symlinks; flag drifted copies"
    echo "  (none)      Full audit (inventory + signals)"
    echo ""
    echo "Options:"
    echo "  -h, --help  Show this help message"
}

# ---------------------------------------------------------------------------
# Discovery — find companion .md files inside skill and external directories
# ---------------------------------------------------------------------------

# Populates parallel arrays: PATHS[], BASENAMES[], PARENT_SKILLS[], IS_SYMLINK[], LINK_TARGET[]
declare -a PATHS=()
declare -a BASENAMES=()
declare -a PARENT_SKILLS=()
declare -a IS_SYMLINK=()
declare -a LINK_TARGET=()
DISCOVERED=false

discover() {
    [[ "$DISCOVERED" == "true" ]] && return
    DISCOVERED=true

    local search_dirs=()
    for base in src/skills external; do
        local abs="$REPO_ROOT/$base"
        [[ -d "$abs" ]] && search_dirs+=("$abs")
    done

    if [[ ${#search_dirs[@]} -eq 0 ]]; then
        return
    fi

    while IFS= read -r file; do
        local rel="${file#"$REPO_ROOT"/}"
        PATHS+=("$rel")
        BASENAMES+=("$(basename "$rel")")

        # Walk up to find the skill directory (parent of agents/, tools/, or protocols/)
        local container_dir
        container_dir="$(dirname "$file")"
        local skill_dir
        skill_dir="$(dirname "$container_dir")"
        PARENT_SKILLS+=("$(basename "$skill_dir")")

        if [[ -L "$file" ]]; then
            IS_SYMLINK+=("yes")
            LINK_TARGET+=("$(readlink "$file")")
        else
            IS_SYMLINK+=("no")
            LINK_TARGET+=("")
        fi
    done < <(find "${search_dirs[@]}" \
        \( -path '*/agents/*.md' -o -path '*/tools/*.md' -o -path '*/protocols/*.md' \) \
        -not -path '*/references/*' \
        | sort)
}

# ---------------------------------------------------------------------------
# Inventory
# ---------------------------------------------------------------------------

cmd_inventory() {
    discover

    echo "=== Companion Artifact Inventory ==="
    echo ""

    if [[ ${#PATHS[@]} -eq 0 ]]; then
        echo "  (no companion artifacts found)"
        echo ""
        return
    fi

    local current_dir=""
    for i in "${!PATHS[@]}"; do
        local dir
        dir="$(dirname "${PATHS[$i]}")"

        if [[ "$dir" != "$current_dir" ]]; then
            [[ -n "$current_dir" ]] && echo ""
            echo "$dir/"
            current_dir="$dir"
        fi

        local name="${BASENAMES[$i]}"
        if [[ "${IS_SYMLINK[$i]}" == "yes" ]]; then
            printf "  %-40s -> %s (symlink)\n" "$name" "${LINK_TARGET[$i]}"
        else
            printf "  %-40s (file)\n" "$name"
        fi
    done

    echo ""
    echo "Total: ${#PATHS[@]} companion artifact(s)"
}

# ---------------------------------------------------------------------------
# Promotion signals
# ---------------------------------------------------------------------------

cmd_signals() {
    discover

    echo "=== Promotion Signals ==="
    echo ""

    local should_be_symlink=0
    local promotion_candidates=0

    # --- Should-be-symlink detection ---
    # For each non-symlink companion, check if a same-name file exists in promoted dirs
    local promoted_dirs=("$REPO_ROOT/src/agents" "$REPO_ROOT/src/protocols")

    for i in "${!PATHS[@]}"; do
        [[ "${IS_SYMLINK[$i]}" == "yes" ]] && continue

        local name="${BASENAMES[$i]}"
        local match=""

        for pdir in "${promoted_dirs[@]}"; do
            [[ -d "$pdir" ]] || continue
            while IFS= read -r found; do
                match="${found#"$REPO_ROOT"/}"
                break
            done < <(find "$pdir" -name "$name" -type f 2>/dev/null)
            [[ -n "$match" ]] && break
        done

        if [[ -n "$match" ]]; then
            echo "SHOULD-BE-SYMLINK: ${PATHS[$i]}"
            echo "  Promoted version exists: $match"
            echo ""
            should_be_symlink=$((should_be_symlink + 1))
        fi
    done

    # --- Duplicate detection ---
    # Group non-symlink companions by basename; flag any name appearing in 2+ skill dirs
    declare -A name_locations
    for i in "${!PATHS[@]}"; do
        local name="${BASENAMES[$i]}"
        if [[ -n "${name_locations[$name]:-}" ]]; then
            name_locations[$name]+=$'\n'"${PATHS[$i]}"
        else
            name_locations[$name]="${PATHS[$i]}"
        fi
    done

    for name in $(printf '%s\n' "${!name_locations[@]}" | sort); do
        local locations="${name_locations[$name]}"
        local count
        count="$(echo "$locations" | wc -l)"

        if [[ "$count" -ge 2 ]]; then
            echo "DUPLICATE: $name found in $count skill directories:"
            while IFS= read -r loc; do
                echo "  $loc"
            done <<< "$locations"
            echo "  → Promotion candidate ($count consumers)"
            echo ""
            promotion_candidates=$((promotion_candidates + 1))
        fi
    done

    # --- Summary ---
    echo "Summary: ${#PATHS[@]} companions found, $should_be_symlink should-be-symlink(s), $promotion_candidates promotion candidate(s)"
}

# ---------------------------------------------------------------------------
# Fix — convert identical copies to symlinks, flag drifted copies
# ---------------------------------------------------------------------------

cmd_fix() {
    discover

    echo "=== Fix: Copies → Symlinks ==="
    echo ""

    local fixed=0
    local drifted=0

    local promoted_dirs=("$REPO_ROOT/src/agents" "$REPO_ROOT/src/protocols")

    for i in "${!PATHS[@]}"; do
        [[ "${IS_SYMLINK[$i]}" == "yes" ]] && continue

        local name="${BASENAMES[$i]}"
        local copy_abs="$REPO_ROOT/${PATHS[$i]}"
        local match_abs=""
        local match_rel=""

        for pdir in "${promoted_dirs[@]}"; do
            [[ -d "$pdir" ]] || continue
            while IFS= read -r found; do
                match_abs="$found"
                match_rel="${found#"$REPO_ROOT"/}"
                break
            done < <(find "$pdir" -name "$name" -type f 2>/dev/null)
            [[ -n "$match_abs" ]] && break
        done

        [[ -z "$match_abs" ]] && continue

        # Compare ignoring whitespace differences
        if diff -qbB "$copy_abs" "$match_abs" >/dev/null 2>&1; then
            # Identical (or whitespace-only differences) — convert to symlink
            local copy_dir
            copy_dir="$(dirname "$copy_abs")"
            local rel_symlink
            rel_symlink="$(python3 -c "import os.path; print(os.path.relpath('$match_abs', '$copy_dir'))")"

            rm "$copy_abs"
            ln -s "$rel_symlink" "$copy_abs"

            echo "FIXED: ${PATHS[$i]} → $rel_symlink"
            fixed=$((fixed + 1))
        else
            # Content differs — flag as drift
            echo "DRIFT: ${PATHS[$i]} differs from promoted version $match_rel"
            diff --stat "$copy_abs" "$match_abs" 2>/dev/null | sed 's/^/  /'
            echo ""
            drifted=$((drifted + 1))
        fi
    done

    if [[ $fixed -eq 0 && $drifted -eq 0 ]]; then
        echo "  (no non-symlink copies with promoted versions found)"
        echo ""
    fi

    echo "Summary: $fixed fixed, $drifted drift(s) detected"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

case "${1:-}" in
    inventory)      cmd_inventory ;;
    signals)        cmd_signals ;;
    fix)            cmd_fix ;;
    -h|--help)      usage ;;
    "")             cmd_inventory; echo ""; cmd_signals ;;
    *)              echo "Unknown command: $1"; usage; exit 1 ;;
esac
