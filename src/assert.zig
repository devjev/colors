// Various utility functions

const std = @import("std");
const trait = std.meta.trait;

pub fn chunky_float(comptime t: type) void {
    comptime if (!trait.isFloat(t) or @sizeOf(t) < @sizeOf(f32)) {
        @compileError(
            \\ Expected compile-time type parameter to be a 
            \\ floating point at least 32 bits wide.
        );
    };
}
