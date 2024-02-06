const std = @import("std");
const Common = @import("root").Common;
const raylib = Common.raylib;
const View = Common.ViewLocator.View;
const ViewModel = Common.ViewLocator.ViewModel;
const Views = Common.ViewLocator.Views;

inline fn DrawSplashScreen(self: View) Views {
    _ = self;
    const screen_color = raylib.Color{ .r = 0, .g = 0, .b = 0, .a = 0 };
    raylib.ClearBackground(screen_color);

    raylib.DrawText("Hello OpenGL World", 190, 200, 20, raylib.LIGHTGRAY);

    var buf: [64:0]u8 = undefined;
    if (std.fmt.bufPrintZ(&buf, "Mouse X: {}, Mouse Y: {}, Click: {}", .{ raylib.GetMouseX(), raylib.GetMouseY(), raylib.IsMouseButtonDown(raylib.MOUSE_BUTTON_LEFT) })) |_| {
        raylib.DrawText(&buf, 190, 225, 20, raylib.LIGHTGRAY);
    } else |_| {
        raylib.DrawText("Failed to get mouse position!", 190, 225, 20, raylib.LIGHTGRAY);
    }

    // const VM = self.VM.GetVM();
    // const music = VM.music;
    if (raylib.IsKeyDown(raylib.KEY_SPACE)) {
        raylib.DrawText("Space Pressed", 190, 250, 20, raylib.LIGHTGRAY);

        //music.Play();
    } else {
        //music.Pause();
    }

    return .HelloWorldView;
}

fn DrawFunction(self: View) Views {
    return DrawSplashScreen(self);
}

pub const HelloWorldView = View{
    .DrawRoutine = DrawFunction,
};
