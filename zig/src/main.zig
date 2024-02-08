const std = @import("std");
const builtin = @import("builtin");
pub const Common = @import("Common.zig").Common;
const raylib = Common.raylib;
const emscripten = Common.emscripten;

pub fn main() !void {
    Common.init();
    defer Common.deinit();

    Common.Log.Trace("Raylib Started");

    if (Common.is_emscripten) {
        emscripten.emscripten_set_main_loop(
            &UpdateFrame,
            0,
            1,
        );
    } else {
        while (!raylib.WindowShouldClose()) {
            UpdateFrame();
        }
    }
}

var current_view: Common.ViewLocator.Views = .Test;
fn UpdateFrame() callconv(.C) void {
    raylib.BeginDrawing();
    defer raylib.EndDrawing();

    // _ = Common.Shader.Get(.base, .base);
    // const shader = Common.Shader.Get(.base, .scanlines);
    // raylib.BeginShaderMode(shader);
    // defer raylib.EndShaderMode();

    //const viewModel = Common.ViewLocator.Views.viewModelTable[0];
    //const view = Common.ViewLocator.getView(current_view);
    const viewModel = Common.ViewLocator.getViewModel(.HelloWorld);
    if (viewModel.init != null) viewModel.init.?();
    current_view = Common.ViewLocator.getDrawFunction(current_view)();

    if (builtin.mode == .Debug) {
        raylib.DrawFPS(10, 430);
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
