
/* /home/emporas/repos/inventory-3d/rust/src/primitives.rs */

use pyo3::prelude::*;

pub type Rgb8 = (u8, u8, u8);

#[pyclass]
#[derive(Clone, Copy, Debug)]
pub struct RectSpec {
    #[pyo3(get)]
    pub x: i32,
    #[pyo3(get)]
    pub y: i32,
    #[pyo3(get)]
    pub width: i32,
    #[pyo3(get)]
    pub height: i32,
    #[pyo3(get)]
    pub color: Rgb8,
}

#[pymethods]
impl RectSpec {
    #[new]
    pub fn new(
        x: i32,
        y: i32,
        width: i32,
        height: i32,
        color: Rgb8,
    ) -> Self {
        Self {
            x,
            y,
            width,
            height,
            color,
        }
    }
}

#[pyclass]
#[derive(Clone, Copy, Debug)]
pub struct LineSpec {
    #[pyo3(get)]
    pub x1: f64,
    #[pyo3(get)]
    pub y1: f64,
    #[pyo3(get)]
    pub x2: f64,
    #[pyo3(get)]
    pub y2: f64,
    #[pyo3(get)]
    pub width: i32,
    #[pyo3(get)]
    pub color: Rgb8,
}

#[pymethods]
impl LineSpec {
    #[new]
    pub fn new(
        x1: f64,
        y1: f64,
        x2: f64,
        y2: f64,
        width: i32,
        color: Rgb8,
    ) -> Self {
        Self {
            x1,
            y1,
            x2,
            y2,
            width,
            color,
        }
    }
}
