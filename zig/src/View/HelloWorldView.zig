const std = @import("std");
const Common = @import("root").Common;
const raylib = Common.raylib;

const vmStruct = struct {
    music: Common.Music,
};

pub const HelloWorldView = Common.ViewLocator.createView(struct {
    const VM = Common.ViewLocator.getViewModel(.HelloWorldView);

    pub fn draw() Common.ViewLocator.Views {
        const screen_color = raylib.Color{ .r = 0, .g = 0, .b = 0, .a = 0 };
        raylib.ClearBackground(screen_color);

        raylib.DrawText("Hello OpenGL World", 190, 200, 20, raylib.LIGHTGRAY);

        var buf: [64:0]u8 = undefined;
        if (std.fmt.bufPrintZ(&buf, "Mouse X: {}, Mouse Y: {}, Click: {}", .{ raylib.GetMouseX(), raylib.GetMouseY(), raylib.IsMouseButtonDown(raylib.MOUSE_BUTTON_LEFT) })) |_| {
            raylib.DrawText(&buf, 190, 225, 20, raylib.LIGHTGRAY);
        } else |_| {
            raylib.DrawText("Failed to get mouse position!", 190, 225, 20, raylib.LIGHTGRAY);
        }

        const music: Common.Music = VM.music;
        if (Common.Input.A_Held()) {
            raylib.DrawText("Space Pressed", 190, 250, 20, raylib.LIGHTGRAY);

            music.Play();
        } else {
            music.Pause();
        }

        return .HelloWorldView;
    }
});
