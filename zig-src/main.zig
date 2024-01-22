const std = @import("std");
const builtin = @import("builtin");
const rl = @cImport({
    @cInclude("raylib.h");
});

pub fn main() !void {
    if (builtin.mode != .Debug) rl.SetTraceLogLevel(rl.LOG_NONE);

    rl.InitWindow(800, 450, undefined);
    defer rl.CloseWindow();

    rl.SetTargetFPS(0);

    rl.TraceLog(rl.LOG_INFO, "Raylib Started");

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        if (builtin.mode == .Debug) {
            rl.DrawFPS(10, 430);
        }

        rl.ClearBackground(rl.Color{ .r = 0, .g = 0, .b = 0, .a = 0 });
        rl.DrawText("Hello OpenGL World", 190, 200, 20, rl.LIGHTGRAY);

        var buf: [64:0]u8 = undefined;
        if (std.fmt.bufPrintZ(&buf, "Mouse X: {}, Mouse Y: {}, Click: {}", .{ rl.GetMouseX(), rl.GetMouseY(), rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) })) |_| {
            rl.DrawText(CString(&buf), 190, 225, 20, rl.LIGHTGRAY);
        } else |_| {
            rl.DrawText("Failed to get mouse position!", 190, 225, 20, rl.LIGHTGRAY);
        }

        if (rl.IsKeyDown(rl.KEY_SPACE)) {
            rl.DrawText("Space Pressed", 190, 250, 20, rl.LIGHTGRAY);
        }
    }
}

fn CString(string: [:0]u8) [*c]const u8 {
    return @as([*c]const u8, @ptrCast(string));
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
