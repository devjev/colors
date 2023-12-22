// const srgb_xyz = @import("srgb<->xyz.zig");

const xyz_lab = @import("xyz<->lab.zig");
pub const xyz_to_lab = xyz_lab.xyz_to_lab;
pub const lab_to_xyz = xyz_lab.lab_to_xyz;
