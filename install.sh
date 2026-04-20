#!/bin/bash
set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

AGENTS_SOURCE="$SKILLS_DIR/src/agents"
AGENTS_TARGET="${CLAUDE_AGENTS_DIR:-$HOME/.claude/agents}"

DIST_DIR="$SKILLS_DIR/dist"

usage() {
    echo "Usage: ai-skills <command> [args...]"
    echo ""
    echo "Commands:"
    echo "  install <path...>   Install skills from directory paths"
    echo "  list                List currently installed skills"
    echo "  available           List all available skills in the repo"
    echo "  clean               Remove all installed skill symlinks"
    echo "  agents              Install agent definitions from src/agents/"
    echo "  zip <path...>       Package skills as .zip for Claude Desktop"
    echo "  identity            Install identity files (SOUL.md, stakeholder.md)"
    echo ""
    echo "Examples:"
    echo "  ai-skills install src/skills/docs src/skills/code/build-plan"
    echo "  ai-skills install src/skills/docs/spec src/skills/orchestration"
    echo "  ai-skills install all"
    echo "  ai-skills zip all"
    echo "  ai-skills zip src/skills/docs/patch-docs"
}

cmd_install() {
    if [ $# -eq 0 ]; then
        echo "Error: specify at least one path (or 'all')"
        usage
        exit 1
    fi

    mkdir -p "$TARGET"

    local count=0

    for path in "$@"; do
        if [ "$path" = "all" ]; then
            path="."
        fi

        local search_dir="$SKILLS_DIR/$path"
        if [ ! -d "$search_dir" ]; then
            echo "Error: '$path' is not a directory in ai-skills"
            exit 1
        fi

        while IFS= read -r skill_md; do
            local skill_dir
            skill_dir="$(dirname "$skill_md")"
            local skill_name
            skill_name="$(basename "$skill_dir")"

            # Check for collision
            if [ -L "$TARGET/$skill_name" ]; then
                local existing
                existing="$(readlink "$TARGET/$skill_name")"
                if [ "$existing" = "$skill_dir" ]; then
                    echo "  skip  $skill_name (already installed)"
                else
                    echo "  WARN  $skill_name collision: already points to $existing"
                fi
                continue
            fi

            ln -s "$skill_dir" "$TARGET/$skill_name"
            echo "  add   $skill_name"
            count=$((count + 1))
        done < <(find "$search_dir" -name "SKILL.md" -type f)
    done

    echo ""
    echo "Installed $count skill(s) → $TARGET"
}

cmd_list() {
    if [ ! -d "$TARGET" ]; then
        echo "No skills installed."
        return
    fi

    echo "Installed skills ($TARGET):"
    for link in "$TARGET"/*/; do
        [ -L "${link%/}" ] || continue
        local name
        name="$(basename "$link")"
        local real
        real="$(readlink "${link%/}")"
        # Get relative path from SKILLS_DIR
        local rel="${real#$SKILLS_DIR/}"
        echo "  $name → $rel"
    done
}

cmd_available() {
    echo "Available skills:"
    while IFS= read -r skill_md; do
        local skill_dir
        skill_dir="$(dirname "$skill_md")"
        local skill_name
        skill_name="$(basename "$skill_dir")"
        local rel="${skill_dir#$SKILLS_DIR/}"
        local desc
        desc="$(grep '^description:' "$skill_md" | head -1 | sed 's/^description: //' | cut -c1-60)"
        printf "  %-35s %s\n" "$rel" "$desc"
    done < <(find "$SKILLS_DIR" -name "SKILL.md" -type f | sort)
}

cmd_clean() {
    if [ ! -d "$TARGET" ]; then
        echo "Nothing to clean."
        return
    fi

    local count=0
    for link in "$TARGET"/*; do
        if [ -L "$link" ]; then
            local real
            real="$(readlink "$link")"
            # Remove symlinks pointing into this repo OR dangling symlinks (stale from a renamed/moved repo)
            if [[ "$real" == "$SKILLS_DIR"* ]] || [ ! -e "$link" ]; then
                rm "$link"
                echo "  rm  $(basename "$link")"
                count=$((count + 1))
            fi
        fi
    done

    # Also clean agent symlinks in ~/.claude/agents/
    if [ -d "$AGENTS_TARGET" ]; then
        for link in "$AGENTS_TARGET"/*; do
            if [ -L "$link" ]; then
                local real
                real="$(readlink "$link")"
                if [[ "$real" == "$SKILLS_DIR"* ]] || [ ! -e "$link" ]; then
                    rm "$link"
                    echo "  rm  $(basename "$link") (agent)"
                    count=$((count + 1))
                fi
            fi
        done
    fi

    # Also clean identity symlinks in ~/.claude/
    local CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
    for identity_file in "SOUL.md" "stakeholder.md"; do
        local link="$CLAUDE_DIR/$identity_file"
        if [ -L "$link" ]; then
            local real
            real="$(readlink "$link")"
            if [[ "$real" == "$SKILLS_DIR"* ]] || [ ! -e "$link" ]; then
                rm "$link"
                echo "  rm  $identity_file (identity)"
                count=$((count + 1))
            fi
        fi
    done

    echo ""
    echo "Removed $count symlink(s)"
}

cmd_install_identity() {
    local IDENTITY_DIR="$SKILLS_DIR/identity"
    local CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

    if [ ! -d "$IDENTITY_DIR" ]; then
        echo "Error: identity/ directory not found"
        exit 1
    fi

    local count=0

    # Files to install: source_name -> target_name
    # SOUL.template.md is excluded (repo-only, not installed)
    local src_files=("SOUL.md" "STAKEHOLDER.md")
    local tgt_files=("SOUL.md" "stakeholder.md")

    for i in "${!src_files[@]}"; do
        local src="$IDENTITY_DIR/${src_files[$i]}"
        local target_name="${tgt_files[$i]}"
        local target="$CLAUDE_DIR/$target_name"

        if [ ! -f "$src" ]; then
            echo "  skip  ${src_files[$i]} (not found)"
            continue
        fi

        if [ -L "$target" ]; then
            local existing
            existing="$(readlink "$target")"
            if [ "$existing" = "$src" ]; then
                echo "  skip  $target_name (already installed)"
            else
                echo "  WARN  $target_name collision: already points to $existing"
            fi
            continue
        fi

        if [ -f "$target" ]; then
            echo "  WARN  $target_name exists as regular file — back up and remove before installing"
            continue
        fi

        ln -s "$src" "$target"
        echo "  add   $target_name -> identity/${src_files[$i]}"
        count=$((count + 1))
    done

    echo ""
    echo "Installed $count identity file(s) -> $CLAUDE_DIR"
}

cmd_install_agents() {
    if [ ! -d "$AGENTS_SOURCE" ]; then
        echo "Error: src/agents/ directory not found"
        exit 1
    fi

    mkdir -p "$AGENTS_TARGET"

    local count=0

    for src in "$AGENTS_SOURCE"/*.md; do
        [ -f "$src" ] || continue
        local name
        name="$(basename "$src")"
        local target="$AGENTS_TARGET/$name"

        if [ -L "$target" ]; then
            local existing
            existing="$(readlink "$target")"
            if [ "$existing" = "$src" ]; then
                echo "  skip  $name (already installed)"
            else
                echo "  WARN  $name collision: already points to $existing"
            fi
            continue
        fi

        ln -s "$src" "$target"
        echo "  add   $name"
        count=$((count + 1))
    done

    echo ""
    echo "Installed $count agent(s) → $AGENTS_TARGET"
}

cmd_zip() {
    if [ $# -eq 0 ]; then
        echo "Error: specify at least one path (or 'all')"
        usage
        exit 1
    fi

    mkdir -p "$DIST_DIR"

    local count=0

    for path in "$@"; do
        if [ "$path" = "all" ]; then
            path="."
        fi

        local search_dir="$SKILLS_DIR/$path"
        if [ ! -d "$search_dir" ]; then
            echo "Error: '$path' is not a directory in ai-skills"
            exit 1
        fi

        while IFS= read -r skill_md; do
            local skill_dir
            skill_dir="$(dirname "$skill_md")"
            local skill_name
            skill_name="$(basename "$skill_dir")"
            local zip_path="$DIST_DIR/${skill_name}.zip"

            # Build zip from skill directory, excluding non-execution files
            python3 -c "
import zipfile, os, fnmatch, sys
exclude = ['research/*', 'test-inputs/*', 'EVAL.md', 'PROGRAM.md', 'SCOPE.md',
           '.brainstorm-*', '.decision-memo-*', '*.pyc', '__pycache__/*']
skill_dir = sys.argv[1]
zip_path = sys.argv[2]
with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, files in os.walk(skill_dir):
        dirs[:] = [d for d in dirs if not any(fnmatch.fnmatch(d + '/', p) for p in exclude)]
        for f in files:
            full = os.path.join(root, f)
            rel = os.path.relpath(full, skill_dir)
            if not any(fnmatch.fnmatch(rel, p) for p in exclude):
                zf.write(full, rel)
" "$skill_dir" "$zip_path"

            echo "  zip   $skill_name → dist/${skill_name}.zip"
            count=$((count + 1))
        done < <(find "$search_dir" -name "SKILL.md" -type f)
    done

    echo ""
    echo "Packaged $count skill(s) → $DIST_DIR"
}

# Main
case "${1:-}" in
    install)  shift; cmd_install "$@" ;;
    agents)   cmd_install_agents ;;
    identity) cmd_install_identity ;;
    list)     cmd_list ;;
    available) cmd_available ;;
    clean)    cmd_clean ;;
    zip)      shift; cmd_zip "$@" ;;
    -h|--help|"") usage ;;
    *)        echo "Unknown command: $1"; usage; exit 1 ;;
esac
