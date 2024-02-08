const std = @import("std");
const Common = @import("root").Common;
const raylib = Common.raylib;
const emscripten = Common.emscripten;

pub const Inputs = struct {
    pub inline fn Up_Held() bool {
        if (raylib.IsKeyDown(raylib.KEY_W)) return true;
        if (raylib.IsKeyDown(raylib.KEY_UP)) return true;

        return false;
    }
    pub inline fn Down_Held() bool {
        if (raylib.IsKeyDown(raylib.KEY_S)) return true;
        if (raylib.IsKeyDown(raylib.KEY_DOWN)) return true;

        return false;
    }
    pub inline fn Left_Held() bool {
        if (raylib.IsKeyDown(raylib.KEY_A)) return true;
        if (raylib.IsKeyDown(raylib.KEY_LEFT)) return true;

        return false;
    }
    pub inline fn Right_Held() bool {
        if (raylib.IsKeyDown(raylib.KEY_D)) return true;
        if (raylib.IsKeyDown(raylib.KEY_RIGHT)) return true;

        return false;
    }
    pub inline fn A_Held() bool {
        if (raylib.IsKeyDown(raylib.KEY_SPACE)) return true;
        if (raylib.IsKeyDown(raylib.KEY_ENTER)) return true;

        return false;
    }

    pub inline fn Start_Held() bool {
        if (raylib.IsKeyDown(raylib.KEY_ESCAPE)) return true;

        return false;
    }

    pub inline fn Up_Pressed() bool {
        if (raylib.IsKeyPressed(raylib.KEY_W)) return true;
        if (raylib.IsKeyPressed(raylib.KEY_UP)) return true;

        return false;
    }
    pub inline fn Down_Pressed() bool {
        if (raylib.IsKeyPressed(raylib.KEY_S)) return true;
        if (raylib.IsKeyPressed(raylib.KEY_DOWN)) return true;

        return false;
    }
    pub inline fn Left_Pressed() bool {
        if (raylib.IsKeyPressed(raylib.KEY_A)) return true;
        if (raylib.IsKeyPressed(raylib.KEY_LEFT)) return true;

        return false;
    }
    pub inline fn Right_Pressed() bool {
        if (raylib.IsKeyPressed(raylib.KEY_D)) return true;
        if (raylib.IsKeyPressed(raylib.KEY_RIGHT)) return true;

        return false;
    }
    pub inline fn A_Pressed() bool {
        if (raylib.IsKeyPressed(raylib.KEY_ENTER)) return true;
        if (raylib.IsKeyPressed(raylib.KEY_SPACE)) return true;

        return false;
    }
    pub inline fn Start_Pressed() bool {
        if (raylib.IsKeyPressed(raylib.KEY_ESCAPE)) return true;

        return false;
    }
};
