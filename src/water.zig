const mod = @This();
const std = @import("std");
const raylib = @import("raylib");
const mouseclick = @import("mouseclick.zig");

pub const WaterPlane = struct {
    pub const Size = 100;
    pub const Plane = raylib.Vector2{ .x = Size, .y = Size };
    pub const Position = raylib.Vector3{ .x = 0, .y = -0.1, .z = 0 };
    const ShaderWs = "assets/shaders/watervs.glsl";
    const ShaderFs = "assets/shaders/waterfs.glsl";

    material: raylib.Material,
    mesh: raylib.Mesh,

    pub usingnamespace mod;
};

pub fn draw(w: *WaterPlane) void {
    w.material.shader.activate();
    w.mesh.draw(w.material, raylib.Matrix.identity());
    w.material.shader.deactivate();
}

pub fn mouseClick(w: *WaterPlane, m: mouseclick.ClickResult) void {
    const locIndex = raylib.getShaderLocation(w.material.shader, "clickPosition");
    const ptrToOpaque: *const anyopaque = @as(*const anyopaque, &m.point);
    raylib.setShaderValue(w.material.shader, locIndex, ptrToOpaque, raylib.ShaderUniformDataType.vec3);
}

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
