const std = @import("std");
const builtin = @import("builtin");
const Common = @import("Common.zig").Common;
const raylib = Common.raylib;
const emscripten = Common.emscripten;

pub fn main() !void {
    Common.init();
    defer Common.deinit();

    raylib.InitWindow(800, 450, "dylanlangston.com");
    defer raylib.CloseWindow();

    raylib.InitAudioDevice();
    defer raylib.CloseAudioDevice();

    raylib.TraceLog(raylib.LOG_TRACE, "Raylib Started");

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

fn UpdateFrame() callconv(.C) void {
    raylib.BeginDrawing();
    defer raylib.EndDrawing();

    // const shader = Common.Shader.Get(.base, .base);
    // raylib.BeginShaderMode(shader);
    // defer raylib.EndShaderMode();

    if (builtin.mode == .Debug) {
        raylib.DrawFPS(10, 430);
    }

    raylib.ClearBackground(raylib.Color{ .r = 0, .g = 0, .b = 0, .a = 0 });
    raylib.DrawText("Hello OpenGL World", 190, 200, 20, raylib.LIGHTGRAY);

    var buf: [64:0]u8 = undefined;
    if (std.fmt.bufPrintZ(&buf, "Mouse X: {}, Mouse Y: {}, Click: {}", .{ raylib.GetMouseX(), raylib.GetMouseY(), raylib.IsMouseButtonDown(raylib.MOUSE_BUTTON_LEFT) })) |_| {
        raylib.DrawText(&buf, 190, 225, 20, raylib.LIGHTGRAY);
    } else |_| {
        raylib.DrawText("Failed to get mouse position!", 190, 225, 20, raylib.LIGHTGRAY);
    }

    if (raylib.IsKeyDown(raylib.KEY_SPACE)) {
        raylib.DrawText("Space Pressed", 190, 250, 20, raylib.LIGHTGRAY);

        Common.Music.Play(.Test);
    } else {
        Common.Music.Pause(.Test);
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
