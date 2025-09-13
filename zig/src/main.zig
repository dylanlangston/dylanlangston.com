const std = @import("std");
const builtin = @import("builtin");
pub const Common = @import("Common.zig").Common;
const raylib = Common.raylib;
const emscripten = Common.emscripten;

pub fn main() !void {
    Common.init();
    defer Common.deinit();

    Common.Log.Trace("Raylib Started");
    current_view.init();
    defer current_view.deinit();

    if (Common.is_emscripten) {
        emscripten.emscripten_set_main_loop(
            &UpdateFrame,
            0,
            true,
        );
    } else {
        while (!raylib.WindowShouldClose()) {
            UpdateFrame();
        }
    }
}

var current_view: Common.ViewLocator.Views = .Mandalbrot;
pub fn UpdateFrame() callconv(.c) void {
    raylib.BeginDrawing();
    defer raylib.EndDrawing();

    current_view = current_view.update();

    if (builtin.mode == .Debug) {
        raylib.DrawFPS(10, raylib.GetScreenHeight() - 30);
    }
}

test "simple test" {
    var list = std.array_list.Managed(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
