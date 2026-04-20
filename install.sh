#!/bin/bash
set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

DIST_DIR="$SKILLS_DIR/dist"

usage() {
    echo "Usage: ai-skills <command> [args...]"
    echo ""
    echo "Commands:"
    echo "  install <path...>   Install skills from directory paths"
    echo "  list                List currently installed skills"
    echo "  available           List all available skills in the repo"
    echo "  clean               Remove all installed skill symlinks"
    echo "  zip <path...>       Package skills as .zip for Claude Desktop"
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

    echo ""
    echo "Removed $count skill(s)"
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
    list)     cmd_list ;;
    available) cmd_available ;;
    clean)    cmd_clean ;;
    zip)      shift; cmd_zip "$@" ;;
    -h|--help|"") usage ;;
    *)        echo "Unknown command: $1"; usage; exit 1 ;;
esac
