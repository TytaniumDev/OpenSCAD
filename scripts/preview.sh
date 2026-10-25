#!/usr/bin/env bash
# Render a PNG preview of a project, for checking a design without a GUI.
#
# Usage:
#   scripts/preview.sh <project> [output.png] [-D 'var=value' ...]
#
# Examples:
#   scripts/preview.sh bag_clip
#   scripts/preview.sh bag_clip /tmp/assembled.png -D 'part="assembled"'
#
# Uses xvfb-run when no display is available (e.g. cloud sessions, CI).
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
name="${1:?usage: scripts/preview.sh <project> [output.png] [-D 'var=value' ...]}"
shift
out="${1:-$repo_root/build/$name.png}"
[ $# -gt 0 ] && shift

mkdir -p "$(dirname "$out")"

runner=()
if [ -z "${DISPLAY:-}" ] && command -v xvfb-run >/dev/null; then
  runner=(xvfb-run -a)
fi

"${runner[@]}" openscad \
  --render --autocenter --viewall \
  --imgsize=1024,768 --colorscheme=Tomorrow \
  -o "$out" "$@" "$repo_root/projects/$name/$name.scad"

echo "Wrote $out"
