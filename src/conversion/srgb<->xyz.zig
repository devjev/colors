const std = @import("std");
const math = std.math;
const structs = @import("../structs.zig");
const errors = @import("../errors.zig");
const assert = @import("../assert.zig");

const Illuminant = structs.Illuminant;
const sRGB = structs.sRGB;
const XYZ = structs.XYZ;
const ColorError = errors.ColorError;

pub fn srgb_to_xyz(
    comptime float_t: type,
    rgb: *const sRGB(float_t),
) ColorError!XYZ(float_t) {
    comptime assert.chunky_float(float_t);
    if (!rgb.*.is_valid()) return ColorError.RGBValuesMustBeBetweenZeroAndOne;

    var r = rgb.*.red;
    var g = rgb.*.green;
    var b = rgb.*.blue;

    r = _rgb_to_xyz_adj(float_t, r);
    g = _rgb_to_xyz_adj(float_t, g);
    b = _rgb_to_xyz_adj(float_t, b);

    const x = (r * @as(float_t, 0.4124) +
        g * @as(float_t, 0.3576) +
        b * @as(float_t, 0.1805)) * @as(float_t, 100.0);

    const y = (r * @as(float_t, 0.2126) +
        g * @as(float_t, 0.7152) +
        b * @as(float_t, 0.0722)) * @as(float_t, 100.0);

    const z = (r * @as(float_t, 0.0193) +
        g * @as(float_t, 0.1192) +
        b * @as(float_t, 0.9505)) * @as(float_t, 100.0);

    return XYZ(float_t){
        .X = x,
        .Y = y,
        .Z = z,
        .illuminant = Illuminant.D65_2,
    };
}

pub fn xyz_to_srgb(
    comptime float_t: type,
    xyz: *const XYZ(float_t),
) ColorError!sRGB(float_t) {
    comptime assert.chunky_float(float_t);

    var x = xyz.*.X / 100.0;
    var y = xyz.*.Y / 100.0;
    var z = xyz.*.Y / 100.0;

    var r = x * 3.2406 + y * (-1.5372) + z * (-0.4986);
    var g = x * (-0.9689) + y * 1.8758 + z * 0.0415;
    var b = x * 0.0557 + y * (-0.2040) + z * 1.0570;

    r = _xyz_to_rgb_adj(float_t, r);
    g = _xyz_to_rgb_adj(float_t, g);
    b = _xyz_to_rgb_adj(float_t, b);

    return sRGB(float_t){
        .red = r,
        .green = g,
        .blue = b,
    };
}

// Private functions -----------------------------------------------------------

inline fn _rgb_to_xyz_adj(
    comptime float_t: type,
    chan_value: float_t,
) float_t {
    if (chan_value > @as(float_t, 0.04045)) {
        const a = (chan_value + @as(float_t, 0.055));
        const b = a / @as(float_t, 1.055);
        const c = math.pow(float_t, b, @as(float_t, 2.4));
        return c;
    } else {
        return chan_value / @as(float_t, 12.92);
    }
}

inline fn _xyz_to_rgb_adj(
    comptime float_t: type,
    chan_value: float_t,
) float_t {
    if (chan_value > 0.0031308) {
        return 1.055 * math.pow(chan_value, 1.0 / 2.4) - 0.055;
    } else {
        return 12.92 * chan_value;
    }
}
