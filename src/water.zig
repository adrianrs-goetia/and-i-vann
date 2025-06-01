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
    waterclicks: WaterClickContainer,

    pub usingnamespace mod;
};

const WaterClickContainer = struct {
    const Amount = 20; // Has to match NumWaterClick in waterfs.glsl

    activeIndex: u8,
    waterclicks: [Amount]WaterClick,

    fn init(shader: rl.Shader) WaterClickContainer {
        const waterclicks = [_]WaterClick{ //
            .{
                .alive = false,
                .lifetime = 0.0,
                .position = rl.Vector3.zero(),
            }} ** WaterClickContainer.Amount;

        // Explicitly setting all alive uniforms on init. Otherwise all are computed in the middle
        // fn setUniforms should fix this, but it doesn't...
        for (0..Amount, waterclicks) |i, wc| {
            if (std.fmt.allocPrintZ(std.heap.page_allocator, "waterclicks[{}].alive", .{i})) |text| {
                rl.setShaderValue(shader, rl.getShaderLocation(shader, text), @as(*const anyopaque, &wc.alive), rl.ShaderUniformDataType.int);
            } else |err| {
                std.log.err("Failed to allocate formatted string for shader uniform, err: {}", .{err});
            }
        }

        return WaterClickContainer{
            .activeIndex = 0,
            .waterclicks = waterclicks,
        };
    }

    fn activate(wcc: *WaterClickContainer, position: rl.Vector3) void {
        const wc = &wcc.waterclicks[wcc.activeIndex];
        wc.alive = true;
        wc.lifetime = 0;
        wc.position = position;
        wcc.activeIndex = (wcc.activeIndex + 1) % WaterClickContainer.Amount;
    }

    fn update(wcc: *WaterClickContainer, delta: f32) void {
        for (&wcc.waterclicks) |*wc| {
            if (wc.alive) {
                wc.lifetime += delta;
            }
            if (WaterClick.MaxLifetime < wc.lifetime) {
                wc.alive = false;
            }
        }
    }

    fn setUniforms(wcc: *WaterClickContainer, shader: rl.Shader) !void {
        const time: f32 = @as(f32, @floatCast(rl.getTime()));
        rl.setShaderValue(shader, rl.getShaderLocation(shader, "iTime"), &time, rl.ShaderUniformDataType.float);
        std.log.info("time: {d:}", .{rl.getTime()});
        for (0..Amount, &wcc.waterclicks) |i, *wc| {
            {
                const text = try std.fmt.allocPrintZ(std.heap.page_allocator, "waterclicks[{}].alive", .{i});
                rl.setShaderValue(shader, rl.getShaderLocation(shader, text), @as(*const anyopaque, &wc.alive), rl.ShaderUniformDataType.int);
            }
            {
                const text = try std.fmt.allocPrintZ(std.heap.page_allocator, "waterclicks[{}].position", .{i});
                rl.setShaderValue(shader, rl.getShaderLocation(shader, text), @as(*const anyopaque, &wc.position), rl.ShaderUniformDataType.vec3);
            }
            {
                const text = try std.fmt.allocPrintZ(std.heap.page_allocator, "waterclicks[{}].lifetime", .{i});
                rl.setShaderValue(shader, rl.getShaderLocation(shader, text), @as(*const anyopaque, &wc.lifetime), rl.ShaderUniformDataType.float);
            }
        }
    }
};

const WaterClick = struct {
    const MaxLifetime = 8.0;

    alive: bool,
    position: rl.Vector3,
    lifetime: f32,
};

pub fn update(w: *WaterPlane, delta: f32) void {
    w.waterclicks.update(delta);
}

pub fn draw(w: *WaterPlane) void {
    w.material.shader.activate();
    w.waterclicks.setUniforms(w.material.shader) catch |err| {
        std.log.err("Waterclicks set uniform error: [ {} ]", .{err});
    };
    w.mesh.draw(w.material, rl.Matrix.identity());
    w.material.shader.deactivate();
}

pub fn mouseClick(w: *WaterPlane, m: mouseclick.ClickResult) void {
    w.waterclicks.activate(m.point);
}

pub fn createWaterPlane() !WaterPlane {
    const shader = try rl.loadShader(WaterPlane.ShaderWs, WaterPlane.ShaderFs);
    var material = try rl.loadMaterialDefault();
    material.shader = shader;
    const mesh = rl.genMeshPlane(WaterPlane.Size, WaterPlane.Size, 1, 1);
    return WaterPlane{ //
        .material = material,
        .mesh = mesh,
        .waterclicks = WaterClickContainer.init(shader),
    };
}
