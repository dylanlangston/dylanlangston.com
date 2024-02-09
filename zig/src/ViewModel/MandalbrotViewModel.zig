const std = @import("std");
const Common = @import("root").Common;
const raylib = Common.raylib;

pub const MandalbrotViewModel = Common.ViewLocator.createViewModel(
    struct {
        // A few good julia sets
        pub const pointsOfInterest: [6][2]f32 = .{
            .{ -0.348827, 0.607167 },
            .{ -0.786268, 0.169728 },
            .{ -0.8, 0.156 },
            .{ 0.285, 0.0 },
            .{ -0.835, -0.2321 },
            .{ -0.70176, -0.3842 },
        };

        pub const screenWidth: i32 = 800;
        pub const screenHeight: i32 = 450;
        pub const zoomSpeed: f32 = 1.01;
        pub const offsetSpeedMul: f32 = 2.0;

        pub const startingZoom: f32 = 0.75;

        // julia set shader
        pub var shader: Common.Shader = undefined;
        // RenderTexture2D to be used for render to texture
        pub var target: raylib.RenderTexture2D = undefined;

        // c constant to use in z^2 + c
        pub var c: [2]f32 = .{ pointsOfInterest[0][0], pointsOfInterest[0][1] };

        // Offset and zoom to draw the julia set at. (centered on screen and default size)
        pub var offset: [2]f32 = undefined;
        pub var zoom: f32 = startingZoom;

        // Get variable (uniform) locations on the shader to connect with the program
        // NOTE: If uniform variable could not be found in the shader, function returns -1
        pub var cLoc: i32 = undefined;
        pub var zoomLoc: i32 = undefined;
        pub var offsetLoc: i32 = undefined;

        pub var incrementSpeed: f32 = 3.0; // Multiplier of speed to change c value
        pub var showControls: bool = false; // Show controls
    },
);
