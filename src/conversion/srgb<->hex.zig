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

    if (!srgb.is_valid()) {
        return errors.ColorError.RGBColorValuesInvalid;
    }

    const red_int = @as(u8, srgb.*.red * 255.0);
    const green_int = @as(u8, srgb.*.green * 255.0);
    const blue_int = @as(u8, srgb.*.blue * 255.0);

    var buf: HexCode = undefined;
    std.fmt.bufPrint(buf[0..2], "{X}", .{red_int});
    std.fmt.bufPrint(buf[2..4], "{X}", .{green_int});
    std.fmt.bufPrint(buf[4..6], "{X}", .{blue_int});

    return buf;
}

pub fn hex_to_srgb(
    comptime float_t: type,
    hex: *const HexCode,
) errors.ColorError!structs.sRGB(float_t) {
    comptime assert.chunky_float(float_t);

    const red_code = hex[0..2];
    const red_255_u8 = try std.fmt.parseInt(u8, red_code, 16) catch {
        return error.HexColorCodeInvalid;
    };
    const red_255_f: float_t = @floatFromInt(red_255_u8);
    const red: float_t = red_255_f / 255.0;

    const green_code = hex[2..4];
    const green_255_u8 = try std.fmt.parseInt(u8, green_code, 16) catch {
        return error.HexColorCodeInvalid;
    };
    const green_255_f: float_t = @floatFromInt(green_255_u8);
    const green: float_t = green_255_f / 255.0;

    const blue_code = hex[4..6];
    const blue_255_u8 = try std.fmt.parseInt(u8, blue_code, 16) catch {
        return error.HexColorCodeInvalid;
    };
    const blue_255_f: float_t = @floatFromInt(blue_255_u8);
    const blue: float_t = blue_255_f / 255.0;

    return structs.sRGB(float_t){
        .red = red,
        .green = green,
        .blue = blue,
    };
}

test "Yellow: sRGB -> hex code" {
    const expected: HexCode = "FFD700";
    const yellow_xyz = structs.sRGB(f32){
        .red = 1.0,
        .green = 0.8431372549,
        .blue = 0.0,
    };

    const got = try srgb_to_hex(f32, &yellow_xyz);

    std.testing.expectEqual(expected, got);
}

test "Yello: HEX -> sRGB" {
    const utils = @import("../testing-utils.zig");
    const source: HexCode = "FFD700";
    const yellow_srgb = structs.sRGB(f32){
        .red = 1.0,
        .green = 0.8431372549,
        .blue = 0.0,
    };

    const got = try hex_to_srgb(f32, &source);

    try utils.expect_equal_srgb_colors(f32, &yellow_srgb, &got);
}
