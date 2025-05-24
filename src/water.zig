const std = @import("std");
const raylib = @import("raylib");

pub const WaterPlane = struct {
    pub const Size = 100;
    pub const Plane = raylib.Vector2{ .x = Size, .y = Size };
    pub const Position = raylib.Vector3{ .x = 0, .y = -0.1, .z = 0 };
    const ShaderWs = "assets/shaders/watervs.glsl";
    const ShaderFs = "assets/shaders/waterfs.glsl";

    material: raylib.Material,
    mesh: raylib.Mesh,

    pub usingnamespace API;
};

pub const API = struct {
    pub fn draw(w: *WaterPlane) void {
        w.material.shader.activate();
        // raylib.drawPlane(WaterPlane.Position, WaterPlane.Plane, raylib.Color.white);
        w.mesh.draw(w.material, raylib.Matrix.identity());
        w.material.shader.deactivate();
    }
};

pub fn createWaterPlane() !WaterPlane {
    const shader = try raylib.loadShader(WaterPlane.ShaderWs, WaterPlane.ShaderFs);
    var material = try raylib.loadMaterialDefault();
    material.shader = shader;
    const mesh = raylib.genMeshPlane(WaterPlane.Size, WaterPlane.Size, 1, 1);
    return WaterPlane{
        .material = material,
        .mesh = mesh,
    };
}
