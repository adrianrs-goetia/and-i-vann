const std = @import("std");
const raylib = @import("raylib");

const file = "assets/duck2.glb";

const Duck = struct {
    position: raylib.Vector3,
    model: raylib.Model,
    scale: f32,
    animator: Animator,

    pub fn draw(d: Duck) void {
        d.model.draw(d.position, d.scale, raylib.Color.white);
    }

    pub fn update(d: *Duck) void {
        if (d.animator.active) {
            raylib.updateModelAnimation(d.model, d.animator.getActiveAnim(), d.animator.getCurrentFrame());
        }

        if (raylib.isMouseButtonPressed(raylib.MouseButton.left)) {
            d.nextAnim();
        } else if (raylib.isMouseButtonPressed(raylib.MouseButton.right)) {
            d.animator.toggleActive();
        }
    }

    pub fn nextAnim(d: *Duck) void {
        d.animator.nextAnim();
    }
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

    fn nextAnim(a: *Animator) void {
        a.activeIndex = @rem(a.activeIndex + 1, a.anims.len);
    }

    fn getCurrentFrame(a: *Animator) i32 {
        const anim = &a.anims[a.activeIndex];
        const frameCount: i32 = @max(anim.frameCount, 1);
        a.currentFrame = @rem(a.currentFrame + 1, frameCount);
        return a.currentFrame;
    }
};

pub fn loadDuck() raylib.RaylibError!Duck {
    const model = try raylib.loadModel(file);
    const anims = try raylib.loadModelAnimations(file);
    return Duck{
        .model = model,
        .position = raylib.Vector3.zero(),
        .scale = 1,
        .animator = Animator{
            .active = false,
            .activeIndex = 0,
            .currentFrame = 0,
            .anims = anims,
        },
    };
}

pub fn unloadDuck(d: Duck) void {
    d.model.unload();
    for (d.animator.anims) |anim| {
        raylib.unloadModelAnimation(anim);
    }
}
