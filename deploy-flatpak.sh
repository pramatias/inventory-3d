#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SO=$(find "$ROOT/rust/target" -type f -name '_geometry*.so' | head -n 1)

if [ -z "$SO" ]; then
    echo "No built _geometry shared object found."
    echo "Run: ~/.venv/bin/maturin build --release --strip"
    exit 1
fi

DEST="$HOME/.config/GIMP/3.2/plug-ins/inventory-3d"
mkdir -p "$DEST"

cp "$ROOT/gimp-plugin/inventory-3d/inventory-3d.py" \
   "$DEST/inventory-3d.py"
cp "$SO" "$DEST/_geometry.abi3.so"

chmod +x "$DEST/inventory-3d.py"

echo "Installed:"
ls -lh "$DEST"
