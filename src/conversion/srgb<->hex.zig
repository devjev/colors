const std = @import("std");
const structs = @import("../structs.zig");
const errors = @import("../errors.zig");
const assert = @import("../assert.zig");

const HexCode = [6:0]u8;

pub fn srgb_to_hex(
    comptime float_t: type,
    srgb: *const structs.sRGB(float_t),
) errors.ColorError!HexCode {
    comptime assert.chunky_float(float_t);

    if (!srgb.is_valid()) {
        return errors.ColorError.RGBColorValuesInvalid;
    }

    const red_int: u8 = @intFromFloat(srgb.red * 255.0);
    const green_int: u8 = @intFromFloat(srgb.green * 255.0);
    const blue_int: u8 = @intFromFloat(srgb.blue * 255.0);

    var result: HexCode = undefined;

    var red_code: [2]u8 = undefined;
    var green_code: [2]u8 = undefined;
    var blue_code: [2]u8 = undefined;

    _ = std.fmt.bufPrint(&red_code, "{X:0>2}", .{red_int}) catch {
        return errors.ColorError.HexColorCodeInvalid; // TODO error could be better
    };
    _ = std.fmt.bufPrint(&green_code, "{X:0>2}", .{green_int}) catch {
        return errors.ColorError.HexColorCodeInvalid;
    };
    _ = std.fmt.bufPrint(&blue_code, "{X:0>2}", .{blue_int}) catch {
        return errors.ColorError.HexColorCodeInvalid;
    };

    result[0] = red_code[0];
    result[1] = red_code[1];
    result[2] = green_code[0];
    result[3] = green_code[1];
    result[4] = blue_code[0];
    result[5] = blue_code[1];

    return result;
}

pub fn hex_to_srgb(
    comptime float_t: type,
    hex: *const HexCode,
) errors.ColorError!structs.sRGB(float_t) {
    comptime assert.chunky_float(float_t);

    const red_code = hex[0..2];
    const red_255_u8 = std.fmt.parseInt(u8, red_code, 16) catch {
        return error.HexColorCodeInvalid;
    };
    const red_255_f: float_t = @floatFromInt(red_255_u8);
    const red: float_t = red_255_f / 255.0;

    const green_code = hex[2..4];
    const green_255_u8 = std.fmt.parseInt(u8, green_code, 16) catch {
        return error.HexColorCodeInvalid;
    };
    const green_255_f: float_t = @floatFromInt(green_255_u8);
    const green: float_t = green_255_f / 255.0;

    const blue_code = hex[4..6];
    const blue_255_u8 = std.fmt.parseInt(u8, blue_code, 16) catch {
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
    const expected: HexCode = "FFD700".*;
    const yellow_xyz = structs.sRGB(f32){
        .red = 1.0,
        .green = 0.8431372549,
        .blue = 0.0,
    };

    const got = try srgb_to_hex(f32, &yellow_xyz);

    try std.testing.expectEqual(expected, got);
}

test "Yello: HEX -> sRGB" {
    const utils = @import("../testing-utils.zig");
    const source: HexCode = "FFD700".*;
    const yellow_srgb = structs.sRGB(f32){
        .red = 1.0,
        .green = 0.8431372549,
        .blue = 0.0,
    };

    const got = try hex_to_srgb(f32, &source);

    try utils.expect_equal_srgb_colors(f32, &yellow_srgb, &got);
}
