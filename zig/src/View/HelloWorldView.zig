const std = @import("std");
const Common = @import("../Common.zig").Common;
const raylib = Common.raylib;
const Views = @import("Views").Views;
const View = @import("View.zig").View;

inline fn DrawSplashScreen() Views {
    const screen_color = raylib.Color.white;
    raylib.clearBackground(screen_color);

    return .HelloWorldView;
}

fn DrawFunction() Views {
    return DrawSplashScreen();
}

pub const HelloWorldView = View{
    .DrawRoutine = DrawFunction,
};
