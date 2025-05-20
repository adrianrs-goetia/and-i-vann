const std = @import("std");
const raylib = @import("raylib");
const Vector2 = raylib.Vector2;
const Vector3 = raylib.Vector3;

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
        _ = d.movement.updateMovement(delta);
    }

    // pub fn setAnim(d: *Duck, a: AnimIndex) void {
    //     d.animator.setAnim(a);
    // }

    pub fn setTargetPosition(d: *Duck, target: Vector3) void {
        _ = d.movement.setNewTargetPosition(target);
    }
};

const Movement = struct {
    currentPosition: Vector3,
    speed: f32,
    state: State,
    linearMovementLocation: f32, // Where along the linear line (start -> target) it is.
    startPosition: Vector3,
    targetPosition: Vector3,

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

    fn setNewTargetPosition(m: *Movement, target: Vector3) State {
        _ = m.setState(State.Moving);
        m.startPosition = m.currentPosition;
        m.linearMovementLocation = 0;
        m.targetPosition = target;
        return m.state;
    }

    fn updateMovement(
        m: *Movement,
        delta: f32,
    ) State {
        var state = m.state;
        switch (state) {
            State.Idle => {},
            State.Moving => state = moving(m, delta),
            State.ReachedLocation => state = State.Idle,
        }
        _ = m.setState(state);
        return m.state;
    }

    fn setState(m: *Movement, new_state: State) bool {
        if (m.state != new_state) {
            m.state = new_state;
            std.log.info("Duck new state {s}", .{m.state.toString()});
            return true;
        }
        return false;
    }

    fn moving(m: *Movement, delta: f32) State {
        const distance = calculateHorizontalDistance(m.startPosition, m.targetPosition);
        const globalSpeed = m.speed / distance;

        m.linearMovementLocation = @min(m.linearMovementLocation + (globalSpeed * delta), 1);
        const newPosition = m.startPosition.scale(1 - m.linearMovementLocation).add(m.targetPosition.scale(m.linearMovementLocation));
        m.currentPosition = newPosition;

        //
        const newDistance = calculateHorizontalDistance(m.currentPosition, m.targetPosition);
        const distanceMargin = 0.01;
        if (newDistance <= distanceMargin) {
            return State.ReachedLocation;
        } else {
            return State.Moving;
        }
    }

    fn calculateHorizontalDistance(t_start: Vector3, t_target: Vector3) f32 {
        const start = Vector3.init(t_start.x, 0, t_start.z);
        const target = Vector3.init(t_target.x, 0, t_target.z);
        return Vector3.length(start.subtract(target));
    }
};

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
