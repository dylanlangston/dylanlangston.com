const builtin = @import("builtin");
const std = @import("std");
const Common = @import("root").Common;
const raylib = Common.raylib;

pub const MiscellaneousHelpers = struct {
    pub inline fn ScreenSize() raylib.Vector2 {
        const current_screen = raylib.Vector2{
            .x = @floatFromInt(raylib.GetScreenWidth()),
            .y = @floatFromInt(raylib.GetScreenHeight()),
        };
        return current_screen;
    }
};
