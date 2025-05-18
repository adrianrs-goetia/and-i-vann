const Camera3D = @import("raylib").Camera3D;
const CameraProjection = @import("raylib").CameraProjection;
const Vector3 = @import("raylib").Vector3;

pub fn initCamera() Camera3D {
    return Camera3D{
        .position = Vector3{ .x = 10, .y = 10, .z = 10 },
        .target = Vector3.zero(),
        .fovy = 45,
        .projection = CameraProjection.perspective,
        .up = Vector3{ .x = 0, .y = 1, .z = 0 },
    };
}
