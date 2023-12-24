const std = @import("std");
const math = std.math;
const structs = @import("../structs.zig");
const assert = @import("../assert.zig");
const Illuminant = structs.Illuminant;
const XYZ = structs.XYZ;
const Lab = structs.Lab;
const ColorError = @import("../errors.zig").ColorError;

pub fn xyz_to_lab(
    comptime float_t: type,
    xyz: *const XYZ(float_t),
) ColorError!Lab(float_t) {
    comptime assert.chunky_float(float_t);

    const refs = xyz_ref_values(float_t, xyz.*.illuminant);
    var x = xyz.*.X / refs.X;
    var y = xyz.*.Y / refs.Y;
    var z = xyz.*.Z / refs.Z;

    x = _xyz_to_lab_adj(x);
    y = _xyz_to_lab_adj(y);
    z = _xyz_to_lab_adj(z);

    const L = 116.0 * y - 16.0;
    const a = 500.0 * (x - y);
    const b = 200.0 * (y - z);

    return Lab(float_t){
        .L = L,
        .a = a,
        .b = b,
        .illuminant = xyz.*.illuminant,
    };
}

// TODO this seems to be inaccurate, as the X channel diverges at 3 decimal
// See tests marked as 'XYZ -> Lab' below.
pub fn lab_to_xyz(
    comptime float_t: type,
    lab: *const Lab(float_t),
) ColorError!XYZ(float_t) {
    var y = (lab.L + 16.0) / 116.0;
    var x = (lab.a / 500.0) + y;
    var z = y - (lab.b / 200.0);

    x = _lab_to_xyz_adj(x);
    y = _lab_to_xyz_adj(y);
    z = _lab_to_xyz_adj(z);

    const refs = xyz_ref_values(float_t, lab.*.illuminant);

    x = x * refs.X;
    y = y * refs.Y;
    z = z * refs.Z;

    return XYZ(float_t){
        .X = x,
        .Y = y,
        .Z = z,
        .illuminant = lab.*.illuminant,
    };
}

test "Yellow: XYZ -> Lab" {
    const utils = @import("../testing-utils.zig");

    const float_t = f32;

    const xyz_y012c = XYZ(float_t){
        .X = 65.544,
        .Y = 69.865,
        .Z = 10.033,
        .illuminant = Illuminant.D65_2,
    };

    const lab_y012c = Lab(float_t){
        .L = 86.931,
        .a = -1.924,
        .b = 87.132,
        .illuminant = Illuminant.D65_2,
    };

    const result = try xyz_to_lab(float_t, &xyz_y012c);

    try utils.expect_equal_lab_colors(
        float_t,
        &lab_y012c,
        &result,
    );
}

test "Yellow: XYZ <- Lab" {
    const utils = @import("../testing-utils.zig");

    const float_t = f32;

    const xyz_y012c = XYZ(float_t){
        .X = 65.544,
        .Y = 69.865,
        .Z = 10.033,
        .illuminant = Illuminant.D65_2,
    };

    const lab_y012c = Lab(float_t){
        .L = 86.931,
        .a = -1.924,
        .b = 87.132,
        .illuminant = Illuminant.D65_2,
    };

    const result = try lab_to_xyz(float_t, &lab_y012c);

    try utils.expect_equal_xyz_colors(
        float_t,
        &xyz_y012c,
        &result,
    );
}

test "Blue: XYZ <- Lab" {
    const utils = @import("../testing-utils.zig");

    const float_t = f32;

    const xyz_2935c = XYZ(float_t){
        .X = 11.952,
        .Y = 10.234,
        .Z = 46.136,
        .illuminant = Illuminant.D65_2,
    };
    const lab_2935c = Lab(float_t){
        .L = 38.259,
        .a = 16.627,
        .b = -56.669,
        .illuminant = Illuminant.D65_2,
    };

    const result = try lab_to_xyz(float_t, &lab_2935c);

    try utils.expect_equal_xyz_colors(
        float_t,
        &xyz_2935c,
        &result,
    );
}

test "Blue: XYZ -> Lab" {
    const utils = @import("../testing-utils.zig");

    const float_t = f32;

    const xyz_2935c = XYZ(float_t){
        .X = 11.952,
        .Y = 10.234,
        .Z = 46.136,
        .illuminant = Illuminant.D65_2,
    };
    const lab_2935c = Lab(float_t){
        .L = 38.259,
        .a = 16.627,
        .b = -56.669,
        .illuminant = Illuminant.D65_2,
    };

    const result = try xyz_to_lab(float_t, &xyz_2935c);

    try utils.expect_equal_lab_colors(
        float_t,
        &lab_2935c,
        &result,
    );
}

test "Black: XYZ -> Lab" {
    const utils = @import("../testing-utils.zig");

    const float_t = f32;

    const xyz_black = XYZ(float_t){
        .X = 0.0,
        .Y = 0.0,
        .Z = 0.0,
        .illuminant = Illuminant.D65_2,
    };
    const lab_black = Lab(float_t){
        .L = 0,
        .a = 0,
        .b = 0,
        .illuminant = Illuminant.D65_2,
    };

    const result = try xyz_to_lab(float_t, &xyz_black);

    try utils.expect_equal_lab_colors(
        float_t,
        &lab_black,
        &result,
    );
}

test "Black: XYZ <- Lab" {
    const utils = @import("../testing-utils.zig");

    const float_t = f32;

    const xyz_black = XYZ(float_t){
        .X = 0.0,
        .Y = 0.0,
        .Z = 0.0,
        .illuminant = Illuminant.D65_2,
    };
    const lab_black = Lab(float_t){
        .L = 0,
        .a = 0,
        .b = 0,
        .illuminant = Illuminant.D65_2,
    };

    const result = try lab_to_xyz(float_t, &lab_black);

    try utils.expect_equal_xyz_colors(
        float_t,
        &xyz_black,
        &result,
    );
}

test "White: XYZ -> Lab" {
    const utils = @import("../testing-utils.zig");

    const float_t = f32;

    const xyz_white = XYZ(float_t){
        .X = 95.047,
        .Y = 100.0,
        .Z = 108.883,
        .illuminant = Illuminant.D65_2,
    };

    const lab_white = Lab(float_t){
        .L = 100.0,
        .a = 0,
        .b = 0,
        .illuminant = Illuminant.D65_2,
    };

    const result = try xyz_to_lab(float_t, &xyz_white);

    try utils.expect_equal_lab_colors(
        float_t,
        &lab_white,
        &result,
    );
}

test "White: XYZ <- Lab" {
    const utils = @import("../testing-utils.zig");

    const float_t = f32;

    const xyz_white = XYZ(float_t){
        .X = 95.047,
        .Y = 100.0,
        .Z = 108.883,
        .illuminant = Illuminant.D65_2,
    };

    const lab_white = Lab(float_t){
        .L = 100.0,
        .a = 0,
        .b = 0,
        .illuminant = Illuminant.D65_2,
    };

    const result = try lab_to_xyz(float_t, &lab_white);

    try utils.expect_equal_xyz_colors(
        float_t,
        &xyz_white,
        &result,
    );
}

// Private functions -----------------------------------------------------------

// Fetch reference XYZ values, which are specific to illuminants and
// observers. The reference values are for each of the XYZ values, so by
// convention
fn xyz_ref_values(comptime float_t: type, illuminant: Illuminant) XYZ(float_t) {
    const ret_t = XYZ(float_t);
    return switch (illuminant) {
        .A_2 => ret_t{
            .X = 109.850,
            .Y = 100.0,
            .Z = 35.585,
            .illuminant = illuminant,
        },
        .B_2 => ret_t{
            .X = 99.0927,
            .Y = 100.0,
            .Z = 85.313,
            .illuminant = illuminant,
        },
        .C_2 => ret_t{
            .X = 98.074,
            .Y = 100.0,
            .Z = 118.232,
            .illuminant = illuminant,
        },
        .D50_2 => ret_t{
            .X = 96.422,
            .Y = 100.0,
            .Z = 82.521,
            .illuminant = illuminant,
        },
        .D55_2 => ret_t{
            .X = 95.682,
            .Y = 100.0,
            .Z = 92.149,
            .illuminant = illuminant,
        },
        .D65_2 => ret_t{
            .X = 95.047,
            .Y = 100.0,
            .Z = 108.883,
            .illuminant = illuminant,
        },
        .D75_2 => ret_t{
            .X = 94.972,
            .Y = 100.0,
            .Z = 122.638,
            .illuminant = illuminant,
        },
        .E_2 => ret_t{
            .X = 100.0,
            .Y = 100.0,
            .Z = 100.0,
            .illuminant = illuminant,
        },
    };
}

inline fn _xyz_to_lab_adj(chan_val: anytype) @TypeOf(chan_val) {
    if (chan_val > 0.008856) {
        return math.pow(@TypeOf(chan_val), chan_val, 1.0 / 3.0);
    } else {
        return 7.787 * chan_val + 16.0 / 116.0;
    }
}

inline fn _lab_to_xyz_adj(chan_val: anytype) @TypeOf(chan_val) {
    const chan_val_3 = math.pow(@TypeOf(chan_val), chan_val, 3.0);
    if (chan_val_3 > 0.008856) {
        return chan_val_3;
    } else {
        return (chan_val - 16.0 / 116.0) / 7.787;
    }
}
