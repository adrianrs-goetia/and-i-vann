const std = @import("std");
const def = @import("definitions.zig");
const raylib = @import("raylib");
const Vector2 = raylib.Vector2;
const Vector3 = raylib.Vector3;
const mod = @This();

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const file = "assets/duck2.glb";

pub const Duck = struct {
    model: raylib.Model,
    scale: f32,
    animator: Animator,
    movement: *Movement,

    pub usingnamespace API;
};

pub const Movement = struct {
    currentPosition: Vector3,
    speed: f32,
    state: State,
    linearMovementLocation: f32, // Where along the linear line (start -> target) it is.
    startPosition: Vector3,
    targetPosition: Vector3,

    pub usingnamespace API;

    const State = enum {
        Idle,
        Moving,
        ReachedLocation,

        fn toString(self: State) []const u8 {
            switch (self) {
                State.Idle => return "Idle",
                State.Moving => return "Moving",
                State.ReachedLocation => return "ReachedLocation",
            }
        }
    };
};

const Animator = struct {
    active: bool,
    activeIndex: AnimIndex,
    currentFrame: i32,
    anims: []raylib.ModelAnimation,

    pub usingnamespace API;

    const AnimIndex = enum(usize) {
        Idle = 0,
        Swim = 1,
    };
};

const API = struct {
    pub fn draw(d: *Duck) void {
        d.model.draw(d.movement.currentPosition, d.scale, raylib.Color.white);
    }

    pub fn update(d: *Duck, delta: f32) void {
        if (d.animator.active) {
            raylib.updateModelAnimation(d.model, d.animator.getActiveAnim(), d.animator.getCurrentFrame());
        }
        const state = d.movement.updateMovement(delta);
        d.animator.setAnimByMovementState(state);
    }

    pub fn setTargetPosition(d: *Duck, target: Vector3) void {
        const state = d.movement.setNewTargetPosition(target);
        d.animator.setAnimByMovementState(state);
        setModelYawAngle(&d.model, d.movement.getAngleToCachedTarget());
    }

    fn setModelYawAngle(m: *raylib.Model, angle: f32) void {
        m.transform = raylib.Matrix.rotateY(-angle + (std.math.pi * 0.5));
    }

    fn setNewTargetPosition(m: *Movement, target: Vector3) Movement.State {
        _ = m.setState(Movement.State.Moving);
        m.startPosition = m.currentPosition;
        m.linearMovementLocation = 0;
        m.targetPosition = target;
        return m.state;
    }

    fn getAngleToCachedTarget(m: *const Movement) f32 {
        const direction = Vector3.normalize(m.targetPosition.subtract(m.startPosition));
        var angle = std.math.acos(direction.dotProduct(def.Forward));
        if (direction.z < 0) {
            angle = (std.math.pi * 2) - angle;
        }
        return angle;
    }

    fn updateMovement(
        m: *Movement,
        delta: f32,
    ) Movement.State {
        var state = m.state;
        switch (state) {
            Movement.State.Idle => {},
            Movement.State.Moving => state = moving(m, delta),
            Movement.State.ReachedLocation => state = Movement.State.Idle,
        }
        _ = m.setState(state);
        return m.state;
    }

    fn setState(m: *Movement, new_state: Movement.State) bool {
        if (m.state != new_state) {
            m.state = new_state;
            return true;
        }
        return false;
    }

    fn moving(m: *Movement, delta: f32) Movement.State {
        const distance = calculateHorizontalDistance(m.startPosition, m.targetPosition);
        const globalSpeed = m.speed / distance;

        m.linearMovementLocation = @min(m.linearMovementLocation + (globalSpeed * delta), 1);
        const newPosition = m.startPosition.scale(1 - m.linearMovementLocation).add(m.targetPosition.scale(m.linearMovementLocation));
        m.currentPosition = newPosition;

        //
        const newDistance = calculateHorizontalDistance(m.currentPosition, m.targetPosition);
        const distanceMargin = 0.01;
        if (newDistance <= distanceMargin) {
            return Movement.State.ReachedLocation;
        } else {
            return Movement.State.Moving;
        }
    }

    fn calculateHorizontalDistance(t_start: Vector3, t_target: Vector3) f32 {
        const start = Vector3.init(t_start.x, 0, t_start.z);
        const target = Vector3.init(t_target.x, 0, t_target.z);
        return Vector3.length(start.subtract(target));
    }

    fn toggleActive(a: *Animator) void {
        a.active = !a.active;
    }

    fn getActiveAnim(a: Animator) raylib.ModelAnimation {
        return a.anims[@intFromEnum(a.activeIndex)];
    }

    fn setAnimByMovementState(a: *Animator, s: Movement.State) void {
        var index: ?Animator.AnimIndex = null;
        switch (s) {
            Movement.State.Idle => index = Animator.AnimIndex.Idle,
            Movement.State.Moving => index = Animator.AnimIndex.Swim,
            Movement.State.ReachedLocation => {},
        }
        a.mutateActiveIndex(index);
    }

    fn mutateActiveIndex(a: *Animator, index: ?Animator.AnimIndex) void {
        if (index) |i| {
            if (a.activeIndex != i) {
                a.activeIndex = i;
            }
        }
    }

    fn getCurrentFrame(a: *Animator) i32 {
        const anim = &a.anims[@intFromEnum(a.activeIndex)];
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
        .currentPosition = Vector3.zero(),
        .speed = 10,
        .state = Movement.State.Idle,
        .linearMovementLocation = 0,
        .startPosition = raylib.Vector3.zero(),
        .targetPosition = raylib.Vector3.zero(),
    };
    return Duck{
        .model = model,
        .scale = 3,
        .animator = Animator{
            .active = true,
            .activeIndex = Animator.AnimIndex.Idle,
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
