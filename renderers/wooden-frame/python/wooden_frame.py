#!/usr/bin/python3
#/home/emporas/repos/inventory-3d/renderers/python/wooden-frame.py

import sys

import gi

gi.require_version("Gimp", "3.0")
gi.require_version("Gegl", "0.4")

from gi.repository import Gimp, Gegl, GLib, Babl

import _geometry


PROC_NAME = "plug-in-inventory-3d-wooden-frame"


def _color(rgb):
    r, g, b = rgb

    color = Gegl.Color.new("white")

    srgb = Babl.space("sRGB")

    color.set_rgba_with_space(
        r / 255.0,
        g / 255.0,
        b / 255.0,
        1.0,
        srgb,
    )

    return color

def _set_foreground(rgb):
    Gimp.context_set_foreground(_color(rgb))


def _fill_rect(image, layer, rect):
    _set_foreground(tuple(rect.color))

    if not image.select_rectangle(
        Gimp.ChannelOps.REPLACE,
        rect.x,
        rect.y,
        rect.width,
        rect.height,
    ):
        raise RuntimeError("Failed to select rectangle")

    if not layer.edit_fill(Gimp.FillType.FOREGROUND):
        raise RuntimeError("Failed to fill rectangle")

def _stroke_line(layer, line):
    _set_foreground(tuple(line.color))
    Gimp.context_set_brush_size(line.width)

    strokes = [
        float(line.x1),
        float(line.y1),
        float(line.x2),
        float(line.y2),
    ]

    if not Gimp.paintbrush_default(layer, strokes):
        raise RuntimeError("Failed to paint line")

def _draw_plan(image, layer, plan):
    # Base rectangles: wood frame, then white opening.
    for rect in plan.base_rectangles:
        _fill_rect(image, layer, rect)

    # +45 pattern — clipped by the inner opening.
    image.select_rectangle(
        Gimp.ChannelOps.REPLACE,
        plan.inner.x,
        plan.inner.y,
        plan.inner.width,
        plan.inner.height,
    )
    for line in plan.positive_diagonals:
        _stroke_line(layer, line)
    Gimp.Selection.none(image)

    # -45 pattern — clipped by the inner opening.
    image.select_rectangle(
        Gimp.ChannelOps.REPLACE,
        plan.inner.x,
        plan.inner.y,
        plan.inner.width,
        plan.inner.height,
    )
    for line in plan.negative_diagonals:
        _stroke_line(layer, line)
    Gimp.Selection.none(image)

    # Outer and inner borders.
    for line in plan.outlines:
        _stroke_line(layer, line)


def run(procedure, run_mode, image, drawables, config, data):
    del run_mode, image, drawables, config, data

    try:
        plan = _geometry.build_wooden_frame()

        print("=== inventory-3d wooden frame ===")
        print("Python:", sys.version)
        print("Python executable:", sys.executable)
        print("Rust module:", _geometry)
        print(
            "Canvas:",
            plan.canvas.width,
            "x",
            plan.canvas.height,
        )
        print(
            "Frame:",
            plan.frame.width,
            "x",
            plan.frame.height,
        )
        print(
            "Inner:",
            plan.inner.width,
            "x",
            plan.inner.height,
        )
        print("Strip width:", plan.strip_width)
        print("Diagonal pitch:", plan.diagonal_pitch)
        print(
            "Generated:",
            len(plan.positive_diagonals),
            "+45 lines,",
            len(plan.negative_diagonals),
            "-45 lines,",
            len(plan.outlines),
            "outline lines",
        )

        new_image = Gimp.Image.new(
            plan.canvas.width,
            plan.canvas.height,
            Gimp.ImageBaseType.RGB,
        )

        layer = Gimp.Layer.new(
            new_image,
            "Wooden Frame",
            plan.canvas.width,
            plan.canvas.height,
            Gimp.ImageType.RGBA_IMAGE,
            100.0,
            Gimp.LayerMode.NORMAL,
        )
        new_image.insert_layer(layer, None, 0)

        Gimp.context_push()
        try:
            Gimp.context_set_defaults()
            Gimp.context_set_default_colors()
            # Start with a white layer like the original Script-Fu.
            if not layer.edit_fill(Gimp.FillType.WHITE):
                raise RuntimeError("Failed to initialize white layer")

            _draw_plan(new_image, layer, plan)
        finally:
            Gimp.Selection.none(new_image)
            Gimp.context_pop()

        Gimp.Display.new(new_image)

        return procedure.new_return_values(
            Gimp.PDBStatusType.SUCCESS,
            None,
        )

    except Exception as exc:
        print(f"inventory-3d error: {exc}", file=sys.stderr)
        return procedure.new_return_values(
            Gimp.PDBStatusType.EXECUTION_ERROR,
            GLib.Error(str(exc)),
        )


class Inventory3D(Gimp.PlugIn):
    def do_query_procedures(self):
        return [PROC_NAME]

    def do_create_procedure(self, name):
        procedure = Gimp.ImageProcedure.new(
            self,
            name,
            Gimp.PDBProcType.PLUGIN,
            run,
            None,
        )

        # This plug-in creates a new image and does not require a
        # selected drawable in the current image.
        procedure.set_image_types("*")
        procedure.set_sensitivity_mask(
            Gimp.ProcedureSensitivityMask.DRAWABLE
            | Gimp.ProcedureSensitivityMask.NO_DRAWABLES
        )

        procedure.set_menu_label("_Wooden Frame")
        procedure.add_menu_path("<Image>/Filters/Inventory 3D")

        procedure.set_documentation(
            "Wooden Frame",
            "Generate the rectangular wooden frame using Rust geometry.",
            None,
        )

        procedure.set_attribution(
            "emporas",
            "emporas",
            "2026",
        )

        return procedure

Gimp.main(Inventory3D.__gtype__, sys.argv)
