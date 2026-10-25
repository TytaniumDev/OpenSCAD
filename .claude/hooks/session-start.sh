#!/usr/bin/env bash
# Installs OpenSCAD in Claude Code cloud sessions so models can be rendered and checked.
set -euo pipefail

# Local machines already have OpenSCAD installed by hand.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

if command -v openscad >/dev/null && command -v xvfb-run >/dev/null; then
  exit 0
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq openscad xvfb >/dev/null
openscad --version
