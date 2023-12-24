const std = @import("std");
const structs = @import("../structs.zig");
const errors = @import("../errors.zig");
const assert = @import("../assert.zig");

const HexCode = [6:0]u8;

pub fn srgb_to_hex(
    comptime float_t: type,
    srgb: *const structs.sRGB(float_t),
) errors.ColorsError!HexCode {
    comptime assert.chunky_float(float_t);

    const red_int = @as(u8, srgb.*.red * 255.0);
    const green_int = @as(u8, srgb.*.green * 255.0);
    const blue_int = @as(u8, srgb.*.blue * 255.0);

    var buf: HexCode = undefined;
    std.fmt.bufPrint(buf[0..2], "{X}", .{red_int});
    std.fmt.bufPrint(buf[2..4], "{X}", .{green_int});
    std.fmt.bufPrint(buf[4..6], "{X}", .{blue_int});

    return buf;
}

test "Yellow XYZ to hex code" {
    const expected: HexCode = "FFD700";
    const yellow_xyz = structs.sRGB(f32){
        .red = 1.0,
        .green = 0.8431372549,
        .blue = 0.0,
    };

    const got = try srgb_to_hex(f32, &yellow_xyz);

    std.testing.expectEqual(expected, got);
}
