#!/usr/bin/env bash
#/home/emporas/repos/inventory-3d/runners/wooden-frame.sh

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

usage() {
    cat >&2 <<EOF
Usage:
  $0 OUTPUT

Examples:
  $0 ./output/wooden-frame.png
  GIMP_CMD='flatpak run org.gimp.GIMP' $0 ./output/wooden-frame.png

The renderer is:
  $REPO_ROOT/renderers/wooden-frame/python/wooden_frame.py
EOF
}

if [[ $# -ne 1 ]]; then
    usage
    exit 2
fi

exec python3 "$REPO_ROOT/runners/render.py" \
    wooden-frame \
    "$1"
