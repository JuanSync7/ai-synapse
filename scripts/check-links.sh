#!/usr/bin/env bash
# @name: check-links
# @description: Validate relative markdown links in src/ for broken targets
# @audience: maintainer
# @action: inspect
# @scope: repo
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
total=0
broken=0

# Strip fenced code blocks (``` ... ```) and inline code spans (`...`) so that
# documentation showing example link syntax doesn't trigger false positives.
strip_code() {
  awk '
    /^[[:space:]]*```/ { in_fence = !in_fence; next }
    in_fence { next }
    { gsub(/`[^`]*`/, ""); print }
  ' "$1"
}

while IFS= read -r file; do
  filedir="$(dirname "$file")"
  while IFS= read -r link; do
    link="${link%%#*}"
    [ -z "$link" ] && continue
    [[ "$link" =~ ^https?:// ]] && continue
    [[ "$link" == *"{"* || "$link" == *"<"* ]] && continue
    total=$((total + 1))
    resolved="$(realpath -m "$filedir/$link")"
    if [ ! -e "$resolved" ]; then
      echo "BROKEN  ${file#$ROOT/}"
      echo "  link:     $link"
      echo "  expected: $resolved"
      echo ""
      broken=$((broken + 1))
    fi
  done < <(strip_code "$file" | grep -oP '\[[^\]]*\]\(\K[^)]+' 2>/dev/null)
done < <(find "$ROOT/synapse/skills" "$ROOT/synapse/agents" "$ROOT/synapse/protocols" \
  "$ROOT/src/skills" "$ROOT/src/agents" "$ROOT/src/protocols" \
  -name '*.md' -type f 2>/dev/null | sort)

echo "$total links checked, $broken broken"
[ "$broken" -gt 0 ] && exit 1 || exit 0
