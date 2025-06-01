const mod = @This();
const std = @import("std");
const rl = @import("raylib");
const mouseclick = @import("mouseclick.zig");

pub const WaterPlane = struct {
    pub const Size = 100;
    pub const Plane = rl.Vector2{ .x = Size, .y = Size };
    pub const Position = rl.Vector3{ .x = 0, .y = -0.1, .z = 0 };
    const ShaderWs = "assets/shaders/watervs.glsl";
    const ShaderFs = "assets/shaders/waterfs.glsl";

    material: rl.Material,
    mesh: rl.Mesh,
    waterclick: WaterClick,

    pub usingnamespace mod;
};

const WaterClick = struct {
    const MaxLifetime = 1.8;

    alive: bool,
    position: rl.Vector3,
    lifetime: f32,

    fn activate(wc: *WaterClick, position: rl.Vector3) void {
        wc.alive = true;
        wc.lifetime = 0;
        wc.position = position;
    }

    fn update(wc: *WaterClick, delta: f32) void {
        wc.lifetime += delta;
        if (WaterClick.MaxLifetime < wc.lifetime) {
            wc.alive = false;
        }
    }

    fn getStrength(wc: *WaterClick) f32 {
        return (MaxLifetime - wc.lifetime) / MaxLifetime;
    }

    fn setUniforms(wc: *WaterClick, shader: rl.Shader) void {
        rl.setShaderValue(shader, rl.getShaderLocation(shader, "waterclick.alive"), @as(*const anyopaque, &wc.alive), rl.ShaderUniformDataType.int);
        rl.setShaderValue(shader, rl.getShaderLocation(shader, "waterclick.position"), @as(*const anyopaque, &wc.position), rl.ShaderUniformDataType.vec3);
        rl.setShaderValue(shader, rl.getShaderLocation(shader, "waterclick.lifetime"), @as(*const anyopaque, &wc.lifetime), rl.ShaderUniformDataType.float);
        rl.setShaderValue(shader, rl.getShaderLocation(shader, "waterclick.maxLifetime"), @as(*const anyopaque, &@as(f32, MaxLifetime)), rl.ShaderUniformDataType.float);
        rl.setShaderValue(shader, rl.getShaderLocation(shader, "waterclick.strength"), @as(*const anyopaque, &wc.getStrength()), rl.ShaderUniformDataType.float);
    }
};

pub fn update(w: *WaterPlane, delta: f32) void {
    w.waterclick.update(delta);
}

pub fn draw(w: *WaterPlane) void {
    w.material.shader.activate();
    w.waterclick.setUniforms(w.material.shader);
    w.mesh.draw(w.material, rl.Matrix.identity());
    w.material.shader.deactivate();
}

pub fn mouseClick(w: *WaterPlane, m: mouseclick.ClickResult) void {
    w.waterclick.activate(m.point);
}

pub fn createWaterPlane() !WaterPlane {
    const shader = try rl.loadShader(WaterPlane.ShaderWs, WaterPlane.ShaderFs);
    var material = try rl.loadMaterialDefault();
    material.shader = shader;
    const mesh = rl.genMeshPlane(WaterPlane.Size, WaterPlane.Size, 1, 1);
    return WaterPlane{
        .material = material, //
        .mesh = mesh,
        .waterclick = WaterClick{
            .alive = false,
            .lifetime = 0,
            .position = rl.Vector3.zero(),
        },
    };
}
