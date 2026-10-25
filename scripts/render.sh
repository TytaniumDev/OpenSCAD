#!/usr/bin/env bash
# Render OpenSCAD projects to STL.
#
# Usage:
#   scripts/render.sh                 # render every project to projects/<name>/<name>.stl
#   scripts/render.sh bag_clip        # render one project
#   scripts/render.sh --check         # render every project to a temp dir (no files changed)
#
# Each project lives in projects/<name>/ and has a main file named <name>.scad.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
check_only=false
projects=()

for arg in "$@"; do
  case "$arg" in
    --check) check_only=true ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) projects+=("$arg") ;;
  esac
done

if [ ${#projects[@]} -eq 0 ]; then
  for dir in "$repo_root"/projects/*/; do
    projects+=("$(basename "$dir")")
  done
fi

out_dir=""
if $check_only; then
  out_dir="$(mktemp -d)"
  trap 'rm -rf "$out_dir"' EXIT
fi

failed=0
for name in "${projects[@]}"; do
  src="$repo_root/projects/$name/$name.scad"
  if [ ! -f "$src" ]; then
    echo "✗ $name: missing $src" >&2
    failed=1
    continue
  fi

  if $check_only; then
    dest="$out_dir/$name.stl"
  else
    dest="$repo_root/projects/$name/$name.stl"
  fi

  # --hardwarnings turns warnings (e.g. unknown variables) into errors.
  if openscad --hardwarnings -o "$dest" "$src" 2>"$dest.log"; then
    echo "✓ $name"
  else
    echo "✗ $name" >&2
    cat "$dest.log" >&2
    failed=1
  fi
  rm -f "$dest.log"
done

exit $failed
