use crate::geometry::{
    negative_diagonal,
    positive_diagonal,
    Bounds,
};
use crate::params::{FrameParams, BG, WOOD, WOOD_LINE};
use crate::primitives::{LineSpec, RectSpec};

use nalgebra::Point2;
use pyo3::prelude::*;

#[pyclass]
#[derive(Clone, Debug)]
pub struct FramePlan {
    #[pyo3(get)]
    pub canvas: RectSpec,
    #[pyo3(get)]
    pub frame: RectSpec,
    #[pyo3(get)]
    pub inner: RectSpec,
    #[pyo3(get)]
    pub base_rectangles: Vec<RectSpec>,
    #[pyo3(get)]
    pub positive_diagonals: Vec<LineSpec>,
    #[pyo3(get)]
    pub negative_diagonals: Vec<LineSpec>,
    #[pyo3(get)]
    pub outlines: Vec<LineSpec>,
    #[pyo3(get)]
    pub diagonal_pitch: i32,
    #[pyo3(get)]
    pub strip_width: i32,
}

impl FramePlan {
    pub fn build(params: &FrameParams) -> Self {
        assert!(params.canvas_width > 0);
        assert!(params.canvas_height > 0);
        assert!(params.frame_width > 0);
        assert!(params.frame_height > 0);
        assert!(params.border_width >= 0);
        assert!(params.frame_width > 2 * params.border_width);
        assert!(params.frame_height > 2 * params.border_width);
        assert!(params.strip_width > 0);
        assert!(params.base_line_width > 0);

        let frame_x =
            (params.canvas_width - params.frame_width) / 2;
        let frame_y =
            (params.canvas_height - params.frame_height) / 2;

        let frame_bounds = Bounds::from_xywh(
            frame_x,
            frame_y,
            params.frame_width,
            params.frame_height,
        );

        let inner_bounds = Bounds::from_xywh(
            frame_x + params.border_width,
            frame_y + params.border_width,
            params.frame_width - 2 * params.border_width,
            params.frame_height - 2 * params.border_width,
        );

        let canvas = RectSpec::new(
            0,
            0,
            params.canvas_width,
            params.canvas_height,
            BG,
        );

        let frame = RectSpec::new(
            frame_bounds.left,
            frame_bounds.top,
            frame_bounds.width(),
            frame_bounds.height(),
            WOOD,
        );

        let inner = RectSpec::new(
            inner_bounds.left,
            inner_bounds.top,
            inner_bounds.width(),
            inner_bounds.height(),
            BG,
        );

        let base_rectangles = vec![frame, inner];

        let start_x =
            inner_bounds.left - inner_bounds.height();
        let end_x =
            inner_bounds.right + inner_bounds.height();

        let pitch = params.diagonal_pitch();

        // Same integer c range and y = x + c construction as Script-Fu.
        let c_start =
            inner_bounds.top
                - inner_bounds.left
                - inner_bounds.height();
        let c_end =
            inner_bounds.top + inner_bounds.height();

        let mut positive_diagonals = Vec::new();
        let mut c = c_start;

        while c <= c_end {
            let (a, b) =
                positive_diagonal(c, start_x, end_x);

            positive_diagonals.push(LineSpec::new(
                a.x,
                a.y,
                b.x,
                b.y,
                params.strip_width,
                WOOD,
            ));

            c += pitch;
        }

        // Same integer c range and y = -x + c construction as Script-Fu.
        let c_start_neg =
            inner_bounds.left
                + inner_bounds.top
                - inner_bounds.height();
        let c_end_neg =
            inner_bounds.left
                + inner_bounds.width()
                + inner_bounds.top
                + inner_bounds.height();

        let mut negative_diagonals = Vec::new();
        let mut c = c_start_neg;

        while c <= c_end_neg {
            let (a, b) =
                negative_diagonal(c, start_x, end_x);

            negative_diagonals.push(LineSpec::new(
                a.x,
                a.y,
                b.x,
                b.y,
                params.strip_width,
                WOOD,
            ));

            c += pitch;
        }

        let outlines = build_outlines(
            &frame_bounds,
            &inner_bounds,
            params.base_line_width,
        );

        let _frame_centre: Point2<f64> =
            frame_bounds.centre();
        let _inner_centre: Point2<f64> =
            inner_bounds.centre();

        Self {
            canvas,
            frame,
            inner,
            base_rectangles,
            positive_diagonals,
            negative_diagonals,
            outlines,
            diagonal_pitch: pitch,
            strip_width: params.strip_width,
        }
    }
}

fn build_outlines(
    frame: &Bounds,
    inner: &Bounds,
    width: i32,
) -> Vec<LineSpec> {
    let mut lines = Vec::with_capacity(8);

    // Outer frame.
    lines.push(LineSpec::new(
        f64::from(frame.left),
        f64::from(frame.top),
        f64::from(frame.right),
        f64::from(frame.top),
        width,
        WOOD_LINE,
    ));
    lines.push(LineSpec::new(
        f64::from(frame.left),
        f64::from(frame.bottom),
        f64::from(frame.right),
        f64::from(frame.bottom),
        width,
        WOOD_LINE,
    ));
    lines.push(LineSpec::new(
        f64::from(frame.left),
        f64::from(frame.top),
        f64::from(frame.left),
        f64::from(frame.bottom),
        width,
        WOOD_LINE,
    ));
    lines.push(LineSpec::new(
        f64::from(frame.right),
        f64::from(frame.top),
        f64::from(frame.right),
        f64::from(frame.bottom),
        width,
        WOOD_LINE,
    ));

    // Inner opening.
    lines.push(LineSpec::new(
        f64::from(inner.left),
        f64::from(inner.top),
        f64::from(inner.right),
        f64::from(inner.top),
        width,
        WOOD_LINE,
    ));
    lines.push(LineSpec::new(
        f64::from(inner.left),
        f64::from(inner.bottom),
        f64::from(inner.right),
        f64::from(inner.bottom),
        width,
        WOOD_LINE,
    ));
    lines.push(LineSpec::new(
        f64::from(inner.left),
        f64::from(inner.top),
        f64::from(inner.left),
        f64::from(inner.bottom),
        width,
        WOOD_LINE,
    ));
    lines.push(LineSpec::new(
        f64::from(inner.right),
        f64::from(inner.top),
        f64::from(inner.right),
        f64::from(inner.bottom),
        width,
        WOOD_LINE,
    ));

    lines
}
