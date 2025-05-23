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
        const state = d.movement.updateMovement(delta);
        d.animator.setAnimByMovementState(state);
    }

    pub fn setTargetPosition(d: *Duck, target: Vector3) void {
        const state = d.movement.setNewTargetPosition(target);
        d.animator.setAnimByMovementState(state);

        const angle = d.movement.getAngleToCachedTarget();
        d.model.transform = raylib.Matrix.rotateY(-angle + (std.math.pi * 0.5));
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

    fn getAngleToCachedTarget(m: *const Movement) f32 {
        const forward = Vector3{ .x = 1, .y = 0, .z = 0 };
        const direction = Vector3.normalize(m.targetPosition.subtract(m.startPosition));
        var angle = std.math.acos(direction.dotProduct(forward));
        if (direction.z < 0) {
            angle = (std.math.pi * 2) - angle;
        }
        return angle;
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

const Animator = struct {
    active: bool,
    activeIndex: AnimIndex,
    currentFrame: i32,
    anims: []raylib.ModelAnimation,

    const AnimIndex = enum(usize) {
        Idle = 0,
        Swim = 1,
    };

    fn toggleActive(a: *Animator) void {
        a.active = !a.active;
    }

    fn getActiveAnim(a: Animator) raylib.ModelAnimation {
        return a.anims[@intFromEnum(a.activeIndex)];
    }

    fn setAnimByMovementState(a: *Animator, s: Movement.State) void {
        var index: ?AnimIndex = null;
        switch (s) {
            Movement.State.Idle => index = AnimIndex.Idle,
            Movement.State.Moving => index = AnimIndex.Swim,
            Movement.State.ReachedLocation => {},
        }
        a.mutateActiveIndex(index);
    }

    fn mutateActiveIndex(a: *Animator, index: ?AnimIndex) void {
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
