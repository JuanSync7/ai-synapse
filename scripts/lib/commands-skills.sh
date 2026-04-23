# commands-skills.sh — skill installation and packaging commands
# Sourced by install.sh; do not execute directly.
# Depends on: common.sh (TARGET, CODEX_GLOBAL_TARGET, _install_skills_to, usage)

cmd_install() {
    _install_skills_to "$TARGET" "claude" "$@"
}

cmd_install_codex() {
    _install_skills_to "$CODEX_GLOBAL_TARGET" "codex-global" "$@"
}

cmd_install_codex_project() {
    local project_target="${PWD}/.agents/skills"
    _install_skills_to "$project_target" "codex-project" "$@"
}

cmd_install_gemini() {
    # Ensure the extension manifest exists so Gemini CLI discovers skills
    _ensure_gemini_manifest
    _install_skills_to "$GEMINI_SKILLS_TARGET" "gemini" "$@"
}

_ensure_gemini_manifest() {
    local manifest="$GEMINI_EXT_DIR/gemini-extension.json"
    mkdir -p "$GEMINI_EXT_DIR"

    if [ -f "$manifest" ]; then
        return
    fi

    cat > "$manifest" << 'MANIFEST'
{
  "name": "ai-synapse",
  "version": "1.0.0",
  "description": "ai-synapse skill library — installed via scripts/install.sh"
}
MANIFEST
    echo "  init  gemini-extension.json (created manifest)"
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
