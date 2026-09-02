//! Rust geometry engine for the GIMP wooden-frame plug-in.
//!
//! Python is intentionally a thin GIMP orchestration layer.
//! Geometry and layout stay in Rust and use nalgebra.

mod frame;
mod geometry;
mod params;
mod primitives;

use frame::FramePlan;
use params::FrameParams;
use primitives::{LineSpec, RectSpec};

use pyo3::prelude::*;

#[pymodule]
fn _geometry(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_class::<FrameParams>()?;
    m.add_class::<RectSpec>()?;
    m.add_class::<LineSpec>()?;
    m.add_class::<FramePlan>()?;
    m.add_function(wrap_pyfunction!(build_wooden_frame, m)?)?;
    Ok(())
}

#[pyfunction]
#[pyo3(signature = (params = None))]
fn build_wooden_frame(
    params: Option<FrameParams>,
) -> FramePlan {
    let params =
        params.unwrap_or_else(FrameParams::defaults);

    FramePlan::build(&params)
}
