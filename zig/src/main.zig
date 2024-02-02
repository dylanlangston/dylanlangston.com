const std = @import("std");
const builtin = @import("builtin");
const rl = @cImport({
    @cInclude("raylib.h");
});
const is_emscripten: bool = builtin.os.tag == .emscripten;
const emscripten: type = if (is_emscripten) @cImport({
    @cInclude("./emscripten.h");
}) else null;
const music_assset = @import("music_assets").music_assets;

var music: rl.Music = undefined;
pub fn main() !void {
    if (builtin.mode == .Debug) {
        rl.SetTraceLogLevel(rl.LOG_ALL);
    } else rl.SetTraceLogLevel(rl.LOG_NONE);

    rl.SetConfigFlags(rl.FLAG_VSYNC_HINT | rl.FLAG_MSAA_4X_HINT);

    rl.InitWindow(800, 450, "Hello World");
    defer rl.CloseWindow();

    rl.InitAudioDevice();
    defer rl.CloseAudioDevice();

    rl.TraceLog(rl.LOG_TRACE, "Raylib Started");

    music = loadMusicStreamFromMemory(".ogg", std.enums.nameCast(music_assset.files, "test_music").data());

    rl.SetTargetFPS(0);

    if (is_emscripten) {
        emscripten.emscripten_set_main_loop(loop, 0, 1);
    } else {
        while (!rl.WindowShouldClose()) {
            loop();
        }
    }
}

fn loop() callconv(.C) void {
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

        if (!rl.IsMusicStreamPlaying(music)) {
            rl.PlayMusicStream(music);
        } else {
            rl.UpdateMusicStream(music);
        }
    } else {}
}

fn CString(string: [:0]u8) [*c]const u8 {
    return @as([*c]const u8, @ptrCast(string));
}

pub fn loadMusicStreamFromMemory(fileType: [:0]const u8, data: []const u8) rl.Music {
    return rl.LoadMusicStreamFromMemory(@as([*c]const u8, @ptrCast(fileType)), @as([*c]const u8, @ptrCast(data)), @as(c_int, @intCast(data.len)));
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
