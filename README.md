# Inventory 3D — Rust + Python GIMP wooden frame

This replaces the supplied Script-Fu wooden-frame generator with a thin GIMP 3
Python adapter and a Rust/PyO3 geometry engine using nalgebra.

Architecture:

    GIMP 3
      |
      v
    inventory-3d.py
      |  GIMP API only
      v
    _geometry.abi3.so
      |
      +-- params.rs
      +-- primitives.rs
      +-- geometry.rs
      +-- frame.rs
      |
      v
    nalgebra 2D geometry

The default geometry preserves the supplied Script-Fu values:

- canvas: 1080 x 1080
- frame: 360 x 960
- border: 24 px
- strip width: 11 px
- diagonal pitch: 31 px
- wood: RGB(196,145,85)
- outline: RGB(96,62,30)
- background: RGB(255,255,255)

The plug-in creates a new image and draws the frame on a new layer.

## Build

From `rust/`:

    ~/.venv/bin/maturin build --release --strip

For development:

    ~/.venv/bin/maturin develop --release

Copy the built module into:

    gimp-plugin/inventory-3d/_geometry.abi3.so

Then install the plug-in directory under:

    ~/.config/GIMP/3.2/plug-ins/

For the exact layout from the original setup:

    ~/.config/GIMP/3.2/plug-ins/inventory-3d/
        inventory-3d.py
        _geometry.abi3.so

Make the Python launcher executable:

    chmod +x ~/.config/GIMP/3.2/plug-ins/inventory-3d/inventory-3d.py

Restart GIMP. The command is:

    Filters -> Inventory 3D -> Wooden Frame

## Design rule

Python does not calculate frame coordinates, diagonal constants, or line
endpoints. It only:

1. asks Rust for a `FramePlan`;
2. creates the GIMP image/layer;
3. applies fills and strokes using GIMP 3;
4. displays the image.

This makes the Rust layer the single source of truth for geometry.
