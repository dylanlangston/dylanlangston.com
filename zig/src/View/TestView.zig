const std = @import("std");
const Common = @import("root").Common;
const raylib = Common.raylib;

pub const TestView = Common.ViewLocator.createView(
    struct {
        pub fn draw() Common.ViewLocator.Views {
            const screen_color = raylib.Color{ .r = 0, .g = 0, .b = 0, .a = 0 };
            raylib.ClearBackground(screen_color);

            raylib.DrawText("Testing", 190, 200, 20, raylib.LIGHTGRAY);

            if (Common.Input.Held(.A)) {
                return .HelloWorld;
            }

            return .Test;
        }
    },
    struct {
        pub fn deinit() void {
            Common.Log.Info("Test DeInit");
        }
    },
);
