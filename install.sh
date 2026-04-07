#!/bin/bash
set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

usage() {
    echo "Usage: ai-skills <command> [args...]"
    echo ""
    echo "Commands:"
    echo "  install <path...>   Install skills from directory paths"
    echo "  list                List currently installed skills"
    echo "  available           List all available skills in the repo"
    echo "  clean               Remove all installed skill symlinks"
    echo ""
    echo "Examples:"
    echo "  ai-skills install docs code/build-plan"
    echo "  ai-skills install docs/spec orchestration"
    echo "  ai-skills install all"
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

            # Skip if already installed
            if [ -L "$TARGET/$skill_name" ]; then
                echo "  skip  $skill_name (already installed)"
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
            # Only remove symlinks pointing into ai-skills
            if [[ "$real" == "$SKILLS_DIR"* ]]; then
                rm "$link"
                echo "  rm  $(basename "$link")"
                count=$((count + 1))
            fi
        fi
    done

    echo ""
    echo "Removed $count skill(s)"
}

# Main
case "${1:-}" in
    install)  shift; cmd_install "$@" ;;
    list)     cmd_list ;;
    available) cmd_available ;;
    clean)    cmd_clean ;;
    -h|--help|"") usage ;;
    *)        echo "Unknown command: $1"; usage; exit 1 ;;
esac
