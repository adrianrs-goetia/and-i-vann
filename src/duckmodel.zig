const std = @import("std");
const raylib = @import("raylib");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const file = "assets/duck2.glb";

const Duck = struct {
    model: raylib.Model,
    scale: f32,
    animator: Animator,
    movement: *Movement,

    pub fn draw(d: Duck) void {
        d.model.draw(d.movement.currentPosition, d.scale, raylib.Color.white);
    }

    pub fn update(d: *Duck, delta: f32) void {
        if (d.animator.active) {
            raylib.updateModelAnimation(d.model, d.animator.getActiveAnim(), d.animator.getCurrentFrame());
        }
        d.movement.updateMovement(delta);
    }

    // pub fn setAnim(d: *Duck, a: AnimIndex) void {
    //     d.animator.setAnim(a);
    // }

    pub fn setTargetPosition(d: *Duck, target: raylib.Vector3) void {
        d.movement.setNewTargetPosition(target);
    }
};

const Movement = struct {
    currentPosition: raylib.Vector3,
    speed: f32,
    linearPosition: f32,
    startPosition: raylib.Vector3,
    targetPosition: raylib.Vector3,

    fn setNewTargetPosition(m: *Movement, target: raylib.Vector3) void {
        m.startPosition = m.currentPosition;
        m.linearPosition = 0;
        m.targetPosition = target;
    }

    fn updateMovement(
        m: *Movement,
        delta: f32,
    ) void {
        m.linearPosition = @min(m.linearPosition + m.speed * delta, 1);
        const newPosition = m.startPosition.scale(1 - m.linearPosition).add(m.targetPosition.scale(m.linearPosition));
        m.currentPosition = newPosition;
    }
};

// test "movement" {
//     var movement = try allocator.create(Movement);
//     movement.* = Movement{
//         .currentPosition = raylib.Vector3.zero(),
//         .speed = 1,
//         .linearPosition = 0,
//         .startPosition = raylib.Vector3.zero(),
//         .targetPosition = raylib.Vector3.one(),
//     };
// }

const AnimIndex = enum(usize) {
    ANIM_IDLE = 0,
    ANIM_SWIM = 1,
};

const Animator = struct {
    active: bool,
    activeIndex: usize,
    currentFrame: i32,
    anims: []raylib.ModelAnimation,

    fn toggleActive(a: *Animator) void {
        a.active = !a.active;
    }

    fn getActiveAnim(a: Animator) raylib.ModelAnimation {
        return a.anims[a.activeIndex];
    }

    // fn setAnim(a: *Animator, index: AnimIndex) void {
    //     if (a.anims.len < index) {
    //         return .{};
    //     }
    //     a.activeIndex = index;
    // }

    fn getCurrentFrame(a: *Animator) i32 {
        const anim = &a.anims[a.activeIndex];
        const frameCount: i32 = @max(anim.frameCount, 1);
        a.currentFrame = @rem(a.currentFrame + 1, frameCount);
        return a.currentFrame;
    }
};

pub fn loadDuck() !Duck {
    const model = try raylib.loadModel(file);
    const anims = try raylib.loadModelAnimations(file);
    const movement = try allocator.create(Movement);
    movement.* = Movement{
        .currentPosition = raylib.Vector3.zero(),
        .speed = 1,
        .linearPosition = 0,
        .startPosition = raylib.Vector3.zero(),
        .targetPosition = raylib.Vector3.zero(),
    };
    return Duck{
        .model = model,
        .scale = 3,
        .animator = Animator{
            .active = true,
            .activeIndex = 0,
            .currentFrame = 0,
            .anims = anims,
        },
        .movement = movement,
    };
}

pub fn unloadDuck(d: Duck) void {
    d.model.unload();
    allocator.destroy(d.movement);
    for (d.animator.anims) |anim| {
        raylib.unloadModelAnimation(anim);
    }
}
