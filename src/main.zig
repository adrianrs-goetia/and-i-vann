//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.

const std = @import("std");
const raylib = @import("raylib");
const duckMod = @import("duckmodel.zig");
const waterMod = @import("water.zig");
const cameraMod = @import("camera.zig");
const mouseclick = @import("mouseclick.zig");
const lillypad = @import("lillypad.zig");
const def = @import("definitions.zig");

pub fn main() !void {
    // Init window
    raylib.initWindow(1400, 1000, "Hello world");
    defer raylib.closeWindow();
    raylib.setConfigFlags(.{ .window_resizable = true });
    raylib.setTargetFPS(60);

    // Camera
    const camera = cameraMod.initCamera();

    // Model
    var duck = try duckMod.loadDuck();
    defer duckMod.unloadDuck(duck);

    // Water
    var water = try waterMod.createWaterPlane();

    var lillypadsManager = try lillypad.initMod();
    defer lillypadsManager.deinitMod();

    // Game loop
    while (!raylib.windowShouldClose()) {
        // Init draw. Required for gui elements
        raylib.beginDrawing();
        defer raylib.endDrawing();
        raylib.clearBackground(raylib.Color.gray);
        {
            // Init draw3d
            camera.begin();
            defer camera.end();

            water.draw();
            try lillypadsManager.draw();
            duck.update(raylib.getFrameTime());
            duck.draw();

            if (raylib.isMouseButtonDown(raylib.MouseButton.left)) {
                const clickResult = try mouseclick.planeCollision(camera);
                duck.setTargetPosition(clickResult);
                water.mouseClick(clickResult);
            }

            // Degug help
            // drawAxis();
        }

        raylib.drawFPS(10, 10);
    }
}

fn drawAxis() void {
    const scalar = 10;
    raylib.drawLine3D(raylib.Vector3.zero(), def.Forward.scale(scalar), raylib.Color.red);
    raylib.drawLine3D(raylib.Vector3.zero(), def.Right.scale(scalar), raylib.Color.blue);
    raylib.drawLine3D(raylib.Vector3.zero(), def.Up.scale(scalar), raylib.Color.green);
}
