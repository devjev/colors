// Structs to represent colors in different color spaces

const assert = @import("assert.zig");

// Standard RGB color
pub fn sRGB(comptime float_t: type) type {
    comptime assert.chunky_float(float_t);
    return struct {
        red: float_t,
        green: float_t,
        blue: float_t,

        // Per convention, color structs may have an is_valid routine, to check
        // if the values in the struct are what we expect.
        pub fn is_valid(self: *const sRGB(float_t)) bool {
            return !((self.*.red < @as(float_t, 0.0)) or
                (self.*.red > @as(float_t, 1.0)) or
                (self.*.green < @as(float_t, 0.0)) or
                (self.*.green > @as(float_t, 1.0)) or
                (self.*.blue < @as(float_t, 0.0)) or
                (self.*.blue > @as(float_t, 1.0)));
        }
    };
}

// CIE XYZ Color
pub fn XYZ(comptime float_t: type) type {
    comptime assert.chunky_float(float_t);
    return struct {
        X: float_t,
        Y: float_t,
        Z: float_t,
        illuminant: Illuminant,
    };
}

// CIE Lab Color
pub fn Lab(comptime float_t: type) type {
    comptime assert.chunky_float(float_t);
    return struct {
        L: float_t,
        a: float_t,
        b: float_t,
        illuminant: Illuminant,
    };
}

pub const Illuminant = enum {
    // Incandescent/tungsten
    A_2,

    // Old direct sunlight at noon
    B_2,

    // Old daylight
    C_2,

    // ICC profile PCS
    D50_2,

    // Mid-morning daylight
    D55_2,

    // Daylight, sRGB, Adobe-RGB
    D65_2,

    // North sky daylight
    D75_2,

    // Equal energy
    E_2,
};
