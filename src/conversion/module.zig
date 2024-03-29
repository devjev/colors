const srgb_hex = @import("srgb<->hex.zig");
pub const srgb_to_hex = srgb_hex.srgb_to_hex;
pub const hex_to_srgb = srgb_hex.hex_to_srgb;

const srgb_xyz = @import("srgb<->xyz.zig");
pub const srgb_to_xyz = srgb_xyz.srgb_to_xyz;
pub const xyz_to_srgb = srgb_xyz.xyz_to_srgb;

const xyz_lab = @import("xyz<->lab.zig");
pub const xyz_to_lab = xyz_lab.xyz_to_lab;
pub const lab_to_xyz = xyz_lab.lab_to_xyz;
