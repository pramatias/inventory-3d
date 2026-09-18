#!/usr/bin/env python3
"""Run an inventory-3d renderer inside a short-lived, headless GIMP 3 process.

Renderer layout:
    renderers/<name>/python/<name_with_underscores>.py

Renderer contract:
    def create_image() -> Gimp.Image:
        ...

The renderer may import local Rust/PyO3 extensions (for example `_geometry`).
Those extensions can live next to the Python module.

Usage:
    ./runners/render.py wooden-frame output.png

Override the GIMP command when necessary:
    GIMP_CMD='flatpak run org.gimp.GIMP' ./runners/render.py wooden-frame output.png
"""

from __future__ import annotations

import argparse
import importlib
import os
from pathlib import Path
import shlex
import subprocess
import sys
import textwrap
import uuid

REPO_ROOT = Path(__file__).resolve().parents[1]
RENDERERS_ROOT = REPO_ROOT / "renderers"
DEFAULT_GIMP_CMD = "gimp-console"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run an inventory-3d renderer in headless GIMP 3."
    )
    parser.add_argument(
        "renderer",
        help="Renderer directory under renderers/, for example: wooden-frame",
    )
    parser.add_argument(
        "output",
        type=Path,
        help="Output image path. Existing output is replaced after successful export.",
    )
    return parser.parse_args()


def resolve_renderer(renderer_name: str) -> tuple[Path, Path, str]:
    if not renderer_name or renderer_name in {".", ".."}:
        raise ValueError("invalid renderer name")
    if "/" in renderer_name or "\\" in renderer_name:
        raise ValueError("renderer must be a directory name, not a path")

    renderer_dir = RENDERERS_ROOT / renderer_name
    python_dir = renderer_dir / "python"
    module_name = renderer_name.replace("-", "_")
    module_file = python_dir / f"{module_name}.py"

    if not renderer_dir.is_dir():
        raise FileNotFoundError(f"renderer not found: {renderer_dir}")
    if not python_dir.is_dir():
        raise FileNotFoundError(f"renderer has no python directory: {python_dir}")
    if not module_file.is_file():
        raise FileNotFoundError(f"renderer module not found: {module_file}")

    return renderer_dir, python_dir, module_name


def build_batch_code(python_dir: Path, module_name: str, output_path: Path) -> str:
    """Return multiline Python executed by GIMP's python-fu-eval interpreter."""
    python_dir_literal = repr(str(python_dir.resolve()))
    output_literal = repr(str(output_path.resolve()))
    module_literal = repr(module_name)

    return textwrap.dedent(
        f"""
        import importlib
        import os
        from pathlib import Path
        import sys
        import traceback
        import uuid

        import gi
        gi.require_version("Gimp", "3.0")
        from gi.repository import Gimp, Gio

        python_dir = {python_dir_literal}
        output_path = Path({output_literal})
        module_name = {module_literal}

        sys.path.insert(0, python_dir)
        module = importlib.import_module(module_name)

        if not hasattr(module, "create_image"):
            raise RuntimeError(
                f"Renderer {{module_name!r}} must define create_image()"
            )

        output_path.parent.mkdir(parents=True, exist_ok=True)

        if not output_path.suffix:
            raise RuntimeError(
                f"Output path must have an image extension: {{output_path}}"
            )

        # Keep the real extension so GIMP selects the correct exporter.
        # Export to a temporary file first so a failed render does not destroy
        # a previously successful output.
        temporary_path = output_path.with_name(
            f"{{output_path.stem}}.gimp-tmp-{{uuid.uuid4().hex}}{{output_path.suffix}}"
        )

        image = None
        try:
            image = module.create_image()
            if image is None:
                raise RuntimeError("create_image() returned None")

            if not isinstance(image, Gimp.Image):
                raise TypeError(
                    f"create_image() returned {{type(image).__name__}}, expected Gimp.Image"
                )

            ok = Gimp.file_save(
                Gimp.RunMode.NONINTERACTIVE,
                image,
                Gio.File.new_for_path(str(temporary_path)),
                None,
            )
            if not ok:
                raise RuntimeError(f"GIMP failed to save {{temporary_path}}")

            os.replace(temporary_path, output_path)
            print(f"Rendered {{module_name}} -> {{output_path}}")
        finally:
            if temporary_path.exists():
                temporary_path.unlink()
            if image is not None:
                try:
                    image.delete()
                except Exception:
                    pass
        """
    ).strip() + "\n"


def main() -> int:
    args = parse_args()

    try:
        _, python_dir, module_name = resolve_renderer(args.renderer)
        output_path = args.output.expanduser().resolve()

        gimp_cmd = os.environ.get("GIMP_CMD", DEFAULT_GIMP_CMD)
        gimp_argv = shlex.split(gimp_cmd)
        if not gimp_argv:
            raise ValueError("GIMP_CMD is empty")

        batch_code = build_batch_code(python_dir, module_name, output_path)

        command = [
            *gimp_argv,
            "--no-interface",
            "--no-splash",
            "--console-messages",
            "--batch-interpreter=python-fu-eval",
            "--batch=-",
            "--quit",
        ]

        print(f"Renderer: {args.renderer}")
        print(f"Output:   {output_path}")
        print(f"GIMP:     {' '.join(shlex.quote(x) for x in gimp_argv)}")

        result = subprocess.run(
            command,
            input=batch_code,
            text=True,
            check=False,
        )

        if result.returncode != 0:
            print(
                f"render.py: GIMP exited with status {result.returncode}",
                file=sys.stderr,
            )
            return result.returncode

        if not output_path.is_file():
            print(
                f"render.py: GIMP exited successfully but did not create {output_path}",
                file=sys.stderr,
            )
            return 1

        return 0

    except (FileNotFoundError, RuntimeError, TypeError, ValueError) as exc:
        print(f"render.py: error: {exc}", file=sys.stderr)
        return 2
    except KeyboardInterrupt:
        print("render.py: interrupted", file=sys.stderr)
        return 130


if __name__ == "__main__":
    raise SystemExit(main())
