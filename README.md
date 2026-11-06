# Inventory 3D — Wooden Frame

This project renders a wooden-frame image by launching **GIMP 3 in headless batch mode** and exporting the result to a file. The supported execution path is `runners/render.py`; the old GIMP menu plug-in and interactive Script-Fu workflow are not part of the runtime architecture.

> **Current status:** The supplied `runners/render.py` requires the renderer module to define `create_image() -> Gimp.Image`. The supplied Python source is still a GIMP plug-in entry point (`Gimp.PlugIn` and `Gimp.main()`), so it does not yet satisfy the headless runner contract. The Rust extension can be built independently, but end-to-end rendering will not work until the Python drawing code is exposed through `create_image()` and the plug-in startup code is removed from the imported renderer.

## 1. How rendering works

```text
runners/wooden-frame.sh             optional convenience command
          |
          v
runners/render.py                   validates paths and builds GIMP batch code
          |
          v
GIMP 3 (headless)                   --no-interface, python-fu-eval
          |
          v
renderers/wooden-frame/python/wooden_frame.py
          |
          |  create_image()
          |  calls _geometry.build_wooden_frame()
          v
_geometry.abi3.so                  Rust library exposed through PyO3
          |
          v
FramePlan                           rectangles, diagonal lines, outlines
          |
          v
GIMP image returned to render.py
          |
          v
PNG (or another GIMP-supported image format) exported to the output path
```

The runner imports the renderer inside GIMP's Python environment. It adds the renderer's `python/` directory to `sys.path`, calls `create_image()`, and saves the returned image. Export first goes to a temporary file; the requested output is replaced only after a successful save.

## 2. From the original `.scm` to Rust and Python

The original Script-Fu file combined geometry calculations and GIMP drawing operations in one script:

- It defined the 1080 × 1080 canvas, 360 × 960 frame, 24 px border, 11 px strips, 31 px diagonal pitch, and colours.
- It calculated the frame and inner opening positions.
- It generated the two diagonal line families and clipped their drawing to the inner opening.
- It used GIMP procedures to fill rectangles and draw lines.

The refactor separates those responsibilities:

| Component | Responsibility |
| --- | --- |
| `renderers/rust/src/params.rs` | Default dimensions, widths, colours, and frame parameters. |
| `renderers/rust/src/primitives.rs` | PyO3-exposed rectangle and line specifications. |
| `renderers/rust/src/geometry.rs` | Bounds and diagonal line endpoint calculations using `nalgebra`. |
| `renderers/rust/src/frame.rs` | Builds the `FramePlan`: base rectangles, diagonal families, and outlines. |
| `renderers/rust/src/lib.rs` | Exposes the Rust types and `build_wooden_frame()` to Python as `_geometry`. |
| `renderers/wooden-frame/python/wooden_frame.py` | GIMP drawing adapter. It must implement `create_image()` and return a `Gimp.Image`. |
| `runners/render.py` | Starts GIMP in batch mode, invokes the renderer, and exports the image. |

Rust owns the geometry. Python should only translate the Rust plan into GIMP image/layer operations. The runner owns process startup and file export.

## 3. Expected project layout

```text
inventory-3d/
├── README.md
├── runners/
│   ├── render.py
│   └── wooden-frame.sh
└── renderers/
    ├── rust/
    │   ├── Cargo.toml
    │   ├── pyproject.toml
    │   └── src/
    │       ├── lib.rs
    │       ├── params.rs
    │       ├── primitives.rs
    │       ├── geometry.rs
    │       └── frame.rs
    └── wooden-frame/
        └── python/
            ├── wooden_frame.py
            └── _geometry.abi3.so
```

`_geometry.abi3.so` is a generated build output, not Rust source. It must be placed beside `wooden_frame.py` because the runner adds that directory to the GIMP Python import path.

## 4. Requirements

For the Linux setup represented by the supplied scripts:

- GIMP 3 with the `python-fu-eval` batch interpreter.
- `gimp-console` on `PATH`, or a working `GIMP_CMD` override.
- Rust and Cargo (a current stable toolchain via `rustup` is suitable).
- Python 3.9 or newer for the build environment.
- Maturin `>=1.8,<2`.
- A C build toolchain required by native Rust dependencies (for example, `build-essential` on Debian/Ubuntu).

The PyO3 configuration uses the `abi3-py39` stable Python ABI. The extension still has to match the operating system and CPU architecture on which GIMP runs. Build for the same platform/environment used by GIMP.

## 5. Build the Rust/PyO3 extension

Run from the repository root:

```bash
cd renderers/rust

# Create and activate an isolated build environment.
python3 -m venv .venv
source .venv/bin/activate

# Install Maturin.
python -m pip install --upgrade pip
python -m pip install 'maturin>=1.8,<2'

# Optional source checks.
cargo fmt --check
cargo test --release

# Build the release wheel containing the native _geometry module.
maturin build --release --strip
```

The Rust package is named `inventory-3d-geometry`; the Python extension module name is `_geometry`. Its dependencies are `nalgebra = "0.34"` and `pyo3 = "0.25"` with the `abi3-py39` and `extension-module` features.

### Copy the native module beside the renderer

Maturin places the wheel in `target/wheels/`. Extract the shared library from the wheel into the renderer's Python directory. Run this snippet while still in `renderers/rust/`:

```bash
python - <<'PY'
from pathlib import Path
from zipfile import ZipFile

wheel_dir = Path("target/wheels")
wheels = sorted(wheel_dir.glob("*.whl"), key=lambda p: p.stat().st_mtime)
if not wheels:
    raise SystemExit("No wheel found in target/wheels; run maturin build first")

wheel = wheels[-1]
with ZipFile(wheel) as archive:
    matches = [
        name for name in archive.namelist()
        if Path(name).name.startswith("_geometry") and name.endswith(".so")
    ]
    if len(matches) != 1:
        raise SystemExit(
            f"Expected one _geometry shared library in {wheel}; found {matches}"
        )
    filename = Path(matches[0]).name
    contents = archive.read(matches[0])

destination = Path("../wooden-frame/python")
destination.mkdir(parents=True, exist_ok=True)
(destination / filename).write_bytes(contents)
print(f"Installed {filename} into {destination}")
PY
```

### Check the Rust extension import

Still from `renderers/rust/`, check that the build Python can import the extension and create a plan:

```bash
PYTHONPATH=../wooden-frame/python python - <<'PY'
import _geometry

plan = _geometry.build_wooden_frame()
print("Canvas:", plan.canvas.width, "x", plan.canvas.height)
print("Frame:", plan.frame.width, "x", plan.frame.height)
print("Inner:", plan.inner.width, "x", plan.inner.height)
print("Diagonal pitch:", plan.diagonal_pitch)
PY
```

This tests the extension with the build Python. The final integration test must still be run through GIMP, because the runner imports `_geometry` inside GIMP's Python environment.

## 6. Headless renderer interface

The renderer name `wooden-frame` resolves to this module:

```text
renderers/wooden-frame/python/wooden_frame.py
```

That module must provide the following function:

```python
def create_image() -> Gimp.Image:
    ...
```

The function must create and return a `Gimp.Image`. It should import `_geometry`, call `_geometry.build_wooden_frame()`, create the image and layer, draw the returned rectangles and lines, and return the image. It must not register a GIMP menu procedure, subclass `Gimp.PlugIn` as an entry point, call `Gimp.main()`, or open a display.

**Migration still required:** The supplied Python file defines a `run(...)` procedure, a `Gimp.PlugIn` subclass, menu registration, and `Gimp.main(...)`. It does not define `create_image()`. Reuse its drawing helpers when converting it into the renderer module, but remove the plug-in lifecycle from the module imported by `render.py`. Until this is done, the headless runner cannot render the wooden frame.

## 7. Run the renderer

After the Python renderer implements the required interface and the native extension is in place, run from the repository root:

```bash
./runners/wooden-frame.sh ./output/wooden-frame.png
```

The wrapper delegates to the Python runner. You can also invoke the runner directly:

```bash
python3 ./runners/render.py wooden-frame ./output/wooden-frame.png
```

The output extension determines the GIMP exporter. The output directory is created automatically, and an existing output file is replaced only after a successful export.

### Select the GIMP executable

By default, `render.py` launches `gimp-console`. Override the command with `GIMP_CMD` when GIMP is installed under a different command or launcher:

```bash
GIMP_CMD='flatpak run org.gimp.GIMP' \
  ./runners/wooden-frame.sh ./output/wooden-frame.png
```

`GIMP_CMD` is split into command-line arguments, so it can contain a launcher and its arguments.

## 8. What is no longer part of the execution path

The following are not required by the headless renderer:

- The original `.scm` Script-Fu file. Keep it only as a historical reference or remove it once the migration has been verified.
- The old installed GIMP menu plug-in directory under `~/.config/GIMP/<version>/plug-ins/`. It is not used by `render.py` and can be uninstalled separately.
- Any old `gimp-plugin/` directory that exists solely to install/register the deprecated menu plug-in. Do not remove it until you have confirmed it contains no source still needed by the headless renderer.
- Generated build artifacts such as `renderers/rust/target/` and the local `renderers/rust/.venv/`. They can be recreated; the `.so` beside the renderer must be rebuilt/copied after deleting it.

Do **not** delete `runners/render.py`, `runners/wooden-frame.sh`, the Rust crate, the headless renderer module, or the `_geometry` extension required at runtime. In particular, do not delete the old Python drawing code until its GIMP drawing operations have been migrated into `create_image()`.

## 9. Wooden-frame geometry notes

The original Script-Fu and Rust defaults specify:

| Property | Value |
| --- | ---: |
| Canvas | 1080 × 1080 px |
| Frame | 360 × 960 px |
| Border | 24 px |
| Inner opening | 312 × 912 px |
| Strip width | 11 px |
| Diagonal pitch | 31 px |
| Wood fill | RGB(196, 145, 85) |
| Outline | RGB(96, 62, 30) |
| Background | RGB(255, 255, 255) |

The numerical dimensions and diagonal equations are carried into Rust. The following descriptions in the original Script-Fu comments are not fully consistent with the implementation:

1. The comments describe the +45° pattern as the left side and the −45° pattern as the right side. Both line families are actually drawn across the full inner opening and clipped to it, creating a crossed lattice rather than separate left/right halves.
2. The comments describe the two families as mirrored with corresponding strips. Their line equations are opposite in slope, but their starting offsets do not produce an exact reflected phase match; the reflected alignment differs by 2 px modulo the 31 px pitch.
3. The Script-Fu comment says no floating-point numbers are used. The Rust geometry represents line endpoints as `f64` values, although the default pitch and dimensions are integer-valued.

These are documentation/geometry observations only. This README does not change the rendering implementation or assert that the generated image has been visually validated.
