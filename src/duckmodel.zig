const std = @import("std");
const raylib = @import("raylib");

const Duck = struct {
    position: raylib.Vector3,
    model: raylib.Model,
    scale: f32,

    pub fn draw(duck: Duck) void {
        duck.model.draw(duck.position, duck.scale, raylib.Color.white);
    }
};

pub fn loadDuckModel() raylib.RaylibError!Duck {
    const model = try raylib.loadModel("assets/duck.glb");
    return Duck{
        .model = model,
        .position = raylib.Vector3.zero(),
        .scale = 1,
    };
}
