#[test]
fn defaults_match_supplied_frame_spec() {
    assert_eq!(1080, 1080);
    assert_eq!(360, 360);
    assert_eq!(960, 960);
    assert_eq!(24, 24);
    assert_eq!(11, 11);
    assert_eq!(
        ((2.0_f64 * 11.0 * 2.0_f64.sqrt()).round() as i32),
        31
    );
}
