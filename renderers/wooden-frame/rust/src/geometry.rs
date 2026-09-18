
/* /home/emporas/repos/inventory-3d/rust/src/geometry.rs */

use nalgebra::{Point2, Vector2};

#[derive(Clone, Copy, Debug)]
pub struct Bounds {
    pub left: i32,
    pub top: i32,
    pub right: i32,
    pub bottom: i32,
}

impl Bounds {
    pub fn from_xywh(x: i32, y: i32, width: i32, height: i32) -> Self {
        Self {
            left: x,
            top: y,
            right: x + width,
            bottom: y + height,
        }
    }

    pub fn width(&self) -> i32 {
        self.right - self.left
    }

    pub fn height(&self) -> i32 {
        self.bottom - self.top
    }

    pub fn centre(&self) -> Point2<f64> {
        Point2::new(
            f64::from(self.left + self.right) * 0.5,
            f64::from(self.top + self.bottom) * 0.5,
        )
    }
}

pub fn positive_diagonal(
    c: i32,
    x_start: i32,
    x_end: i32,
) -> (Point2<f64>, Point2<f64>) {
    let direction = Vector2::new(1.0_f64, 1.0_f64).normalize();
    let _normal = Vector2::new(-direction.y, direction.x);

    (
        Point2::new(
            f64::from(x_start),
            f64::from(x_start + c),
        ),
        Point2::new(
            f64::from(x_end),
            f64::from(x_end + c),
        ),
    )
}

pub fn negative_diagonal(
    c: i32,
    x_start: i32,
    x_end: i32,
) -> (Point2<f64>, Point2<f64>) {
    let direction = Vector2::new(1.0_f64, -1.0_f64).normalize();
    let _normal = Vector2::new(-direction.y, direction.x);

    (
        Point2::new(
            f64::from(x_start),
            f64::from(c - x_start),
        ),
        Point2::new(
            f64::from(x_end),
            f64::from(c - x_end),
        ),
    )
}
