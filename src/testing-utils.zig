const std = @import("std");
const testing = std.testing;
const assert = @import("assert.zig");
const structs = @import("structs.zig");

pub const EPSILON = 1E-2; // TODO this is very low accuracy. Research how to improve.

pub fn expect_equal_srgb_colors(
    comptime float_t: type,
    expected_color: *const structs.sRGB(float_t),
    actual_color: @TypeOf(expected_color),
) anyerror!void {
    try testing.expectApproxEqAbs(
        expected_color.red,
        actual_color.red,
        EPSILON,
    );
    try testing.expectApproxEqAbs(
        expected_color.green,
        actual_color.green,
        EPSILON,
    );
    try testing.expectApproxEqAbs(
        expected_color.blue,
        actual_color.blue,
        EPSILON,
    );
}

pub fn expect_equal_xyz_colors(
    comptime float_t: type,
    expected_color: *const structs.XYZ(float_t),
    actual_color: @TypeOf(expected_color),
) anyerror!void {
    try testing.expectApproxEqAbs(expected_color.X, actual_color.X, EPSILON);
    try testing.expectApproxEqAbs(expected_color.Y, actual_color.Y, EPSILON);
    try testing.expectApproxEqAbs(expected_color.Z, actual_color.Z, EPSILON);
    try testing.expectEqual(
        expected_color.illuminant,
        actual_color.illuminant,
    );
}

pub fn expect_equal_lab_colors(
    comptime float_t: type,
    expected_color: *const structs.Lab(float_t),
    actual_color: @TypeOf(expected_color),
) anyerror!void {
    try testing.expectApproxEqAbs(expected_color.L, actual_color.L, EPSILON);
    try testing.expectApproxEqAbs(expected_color.a, actual_color.a, EPSILON);
    try testing.expectApproxEqAbs(expected_color.b, actual_color.b, EPSILON);
    try testing.expectEqual(
        expected_color.illuminant,
        actual_color.illuminant,
    );
}
