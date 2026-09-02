#!/usr/bin/env sh

set -e

tree

ls -l inventory-3d/

flatpak run --command=sh org.gimp.GIMP -c '
echo "HOME=$HOME"
echo "XDG_CONFIG_HOME=$XDG_CONFIG_HOME"
echo
echo "GIMP config:"
find "$HOME/.config/GIMP" -maxdepth 4 -type d -print 2>/dev/null
'

ls -l ~/.config/GIMP/3.2/plug-ins/

flatpak run --command=sh org.gimp.GIMP -c '
ls -la "$HOME/.config/GIMP/3.2/plug-ins/inventory-3d"
'

flatpak run --command=python3 org.gimp.GIMP -c '
import sys
print(sys.version)
print(sys.path)
'

flatpak run --command=python3 org.gimp.GIMP -c '
import os

p = "/home/emporas/.config/GIMP/3.2/plug-ins/inventory-3d"
print(os.path.isdir(p))
print(os.listdir(p))
'

ls -lh target/wheels/

~/.venv/bin/python -c '
import _geometry
print(_geometry.__file__)
'

ls -la ~/.config/GIMP/3.2/plug-ins/inventory-3d/

cat <<'EOF'

The final structure we're building toward:

/home/emporas/repos/inventory-3d/
│
├── 431_wooden_frame.scm
├── first-floor.scm
├── palette.scm
│
├── gimp-plugin/
│   └── inventory-3d/
│       ├── inventory-3d.py
│       └── _geometry.abi3.so
│
└── rust/
    ├── Cargo.toml
    ├── pyproject.toml
    ├── src/
    │   └── lib.rs
    └── target/
        └── wheels/

EOF

~/.venv/bin/maturin --version

cp "$(
    ~/.venv/bin/python -c 'import _geometry; print(_geometry.__file__)'
)" \
"/home/emporas/repos/inventory-3d/gimp-plugin/inventory-3d/_geometry.abi3.so"

cat <<'EOF'

The resulting setup:

~/.venv/bin/maturin
        │
        ▼
   Rust + PyO3
        │
        ▼
_geometry.abi3.so
        │
        ▼
gimp-plugin/inventory-3d/
    ├── inventory-3d.py
    └── _geometry.abi3.so
        │
        ▼
GIMP Flatpak
Python 3.13
        │
        ▼
      _geometry

EOF
