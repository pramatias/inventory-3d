use pyo3::prelude::*;

use crate::primitives::Rgb8;

pub const CANVAS_WIDTH: i32 = 1080;
pub const CANVAS_HEIGHT: i32 = 1080;

pub const FRAME_WIDTH: i32 = 360;
pub const FRAME_HEIGHT: i32 = 960;

pub const BORDER_WIDTH: i32 = 24;
pub const STRIP_WIDTH: i32 = 11;
pub const BASE_LINE_WIDTH: i32 = 6;

pub const WOOD: Rgb8 = (196, 145, 85);
pub const WOOD_LINE: Rgb8 = (96, 62, 30);
pub const BG: Rgb8 = (255, 255, 255);

#[pyclass]
#[derive(Clone, Copy, Debug)]
pub struct FrameParams {
    #[pyo3(get, set)]
    pub canvas_width: i32,
    #[pyo3(get, set)]
    pub canvas_height: i32,
    #[pyo3(get, set)]
    pub frame_width: i32,
    #[pyo3(get, set)]
    pub frame_height: i32,
    #[pyo3(get, set)]
    pub border_width: i32,
    #[pyo3(get, set)]
    pub strip_width: i32,
    #[pyo3(get, set)]
    pub base_line_width: i32,
}

impl FrameParams {
    pub fn defaults() -> Self {
        Self {
            canvas_width: CANVAS_WIDTH,
            canvas_height: CANVAS_HEIGHT,
            frame_width: FRAME_WIDTH,
            frame_height: FRAME_HEIGHT,
            border_width: BORDER_WIDTH,
            strip_width: STRIP_WIDTH,
            base_line_width: BASE_LINE_WIDTH,
        }
    }
}

#[pymethods]
impl FrameParams {
    #[new]
    #[pyo3(signature = (
        canvas_width = CANVAS_WIDTH,
        canvas_height = CANVAS_HEIGHT,
        frame_width = FRAME_WIDTH,
        frame_height = FRAME_HEIGHT,
        border_width = BORDER_WIDTH,
        strip_width = STRIP_WIDTH,
        base_line_width = BASE_LINE_WIDTH,
    ))]
    #[allow(clippy::too_many_arguments)]
    pub fn new(
        canvas_width: i32,
        canvas_height: i32,
        frame_width: i32,
        frame_height: i32,
        border_width: i32,
        strip_width: i32,
        base_line_width: i32,
    ) -> Self {
        Self {
            canvas_width,
            canvas_height,
            frame_width,
            frame_height,
            border_width,
            strip_width,
            base_line_width,
        }
    }

    /// The perpendicular strip-plus-gap pitch projected onto x/y
    /// for a 45 degree family, rounded to an integer pixel pitch.
    pub fn diagonal_pitch(&self) -> i32 {
        (
            2.0
                * f64::from(self.strip_width)
                * 2.0_f64.sqrt()
        )
        .round() as i32
    }
}
