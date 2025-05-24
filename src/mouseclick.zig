/// Mouseclick and raycast to the horizontal plane to return a position
const std = @import("std");
const raylib = @import("raylib");
const Vector3 = raylib.Vector3;
const duck = @import("duckmodel.zig");

pub const CollisionError = error{
    NoCollisionHit,
};

pub const ClickResult = struct {
    point: Vector3,
};

pub fn planeCollision(c: raylib.Camera3D) CollisionError!ClickResult {
    const ray = raylib.getScreenToWorldRay(raylib.getMousePosition(), c);
    const collision = raylib.getRayCollisionQuad(ray, //
        Vector3{ .x = 100, .y = 0, .z = 100 }, //
        Vector3{ .x = -100, .y = 0, .z = 100 }, //
        Vector3{ .x = -100, .y = 0, .z = -100 }, //
        Vector3{ .x = 100, .y = 0, .z = -100 }); //

    if (!collision.hit) {
        return CollisionError.NoCollisionHit;
    }

    return ClickResult{ .point = collision.point };
}

pub fn drawCube(v: Vector3) void {
    const size = 0.8;
    raylib.drawCube(v, size, size, size, raylib.Color.blue);
}
