const mod = @This();
const std = @import("std");
const rl = @import("raylib");

var GPA = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = GPA.allocator();

const file = "assets/lilypad512.glb";
const num = 100;
const baseYPos = 0.1;

pub const Instance = struct {
    position: rl.Vector2,
    rotationYaw: f32,
    scale: f32,
};

pub const Manager = struct {
    model: *rl.Model,
    instances: *[num]Instance,

    pub usingnamespace mod;
};

pub fn draw(m: *Manager) !void {
    const transforms = try gpa.create([num]rl.Matrix);
    defer gpa.destroy(transforms);
    for (m.instances[0..], transforms[0..]) |*inst, *t| {
        _ = t;
        // t.* = rl.Matrix.rotateY(-inst.rotationYaw);
        // t.* = t.*.multiply(rl.Matrix.scale(inst.scale, inst.scale, inst.scale));
        // t.* = rl.Matrix.translate(inst.position.x, baseYPos, inst.position.y);
        m.model.*.transform = rl.Matrix.rotateY(inst.rotationYaw);
        rl.drawModel(m.model.*, rl.Vector3{ .x = inst.position.x, .y = baseYPos, .z = inst.position.y }, inst.scale, rl.Color.white);
    }
    // TODO? loop through meshes?
    // rl.drawMeshInstanced(m.model.meshes[0], m.model.materials[0], transforms);
}

pub fn initMod() !Manager {
    const model = try gpa.create(rl.Model);
    model.* = try rl.loadModel(file);
    const m = Manager{
        .model = model,
        .instances = try gpa.create([num]Instance),
    };
    for (0..num, m.instances[0..]) |i, *inst| {
        inst.* = Instance{ //
            .position = rl.Vector2{ .x = @floatFromInt(i), .y = 1 },
            .rotationYaw = @as(f32, @floatFromInt(rl.getRandomValue(0, 314))) / 100,
            .scale = @as(f32, @floatFromInt(rl.getRandomValue(0, 80))) / 10,
        };
    }
    return m;
}

pub fn deinitMod(m: *Manager) void {
    rl.unloadModel(m.model.*);
    gpa.destroy(m.instances);
}
