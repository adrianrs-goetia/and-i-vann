const raylib = @import("raylib");
const Vector3 = raylib.Vector3;

pub const Up = Vector3{ .x = 0, .y = 1, .z = 0 };
pub const Forward = Vector3{ .x = 1, .y = 0, .z = 0 };
pub const Right = Vector3{ .x = 0, .y = 0, .z = 1 };
