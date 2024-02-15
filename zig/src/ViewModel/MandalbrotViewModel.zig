const std = @import("std");
const Common = @import("root").Common;
const raylib = Common.raylib;

pub const MandalbrotViewModel = Common.ViewLocator.createViewModel(
    struct {
        pub const zoomSpeed: f32 = 1.01;
        pub const offsetSpeedMul: f32 = 2.0;

        pub const startingZoom: f32 = 0.75;

        pub var increment: bool = false;

        // julia shader set
        pub var juliaShader: Common.Shader = undefined;
        // wave shader set
        pub var waveShader: Common.Shader = undefined;
        // RenderTexture2D to be used for render to texture
        pub var juliaTarget: raylib.RenderTexture2D = undefined;
        pub var waveTarget: raylib.RenderTexture2D = undefined;

        pub const startingC: [2]f32 = .{ -0.35, 0.607167 };

        // c constant to use in z^2 + c
        pub var c: [2]f32 = startingC;

        // Offset and zoom to draw the julia set at. (centered on screen and default size)
        pub var offset: [2]f32 = undefined;

        // Get variable (uniform) locations on the shader to connect with the program
        // NOTE: If uniform variable could not be found in the shader, function returns -1
        pub var cLoc: i32 = undefined;
        pub var zoomLoc: i32 = undefined;
        pub var offsetLoc: i32 = undefined;

        pub var waveScreenSizeLoc: i32 = undefined;
        pub var waveTimeLoc: i32 = undefined;

        pub var incrementSpeed: f32 = 3.0; // Multiplier of speed to change c value

        pub var frame: f32 = 0;

        pub var incrementX: bool = true;
        pub var incrementY: bool = true;
        pub var position: raylib.Vector2 = raylib.Vector2{ .x = 0, .y = 0 };
    },
);
