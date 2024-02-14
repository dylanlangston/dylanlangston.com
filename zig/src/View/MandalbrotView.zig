const std = @import("std");
const Common = @import("root").Common;
const raylib = Common.raylib;

const MandalbrotViewModel = Common.ViewLocator.getViewModel(.Mandalbrot);

pub const MandalbrotView = Common.ViewLocator.createView(
    struct {
        var frame: f32 = 0;

        pub fn draw() Common.ViewLocator.Views {
            const screenSize = Common.Helpers.ScreenSize();

            frame += raylib.GetFrameTime();

            raylib.SetShaderValue(
                MandalbrotViewModel.waveShader.shader,
                MandalbrotViewModel.waveTimeLoc,
                &frame,
                raylib.SHADER_UNIFORM_FLOAT,
            );

            // New render texture on resize
            if (@as(f32, @floatFromInt(MandalbrotViewModel.target.texture.width - 100)) != screenSize.x or @as(f32, @floatFromInt(MandalbrotViewModel.target.texture.height - 100)) != screenSize.y) {
                raylib.UnloadRenderTexture(MandalbrotViewModel.target);
                MandalbrotViewModel.target = raylib.LoadRenderTexture(@intFromFloat(screenSize.x + 100), @intFromFloat(screenSize.y + 100));

                raylib.SetShaderValue(
                    MandalbrotViewModel.waveShader.shader,
                    MandalbrotViewModel.waveScreenSizeLoc,
                    &raylib.Vector2{
                        .x = screenSize.x + 100,
                        .y = screenSize.y + 100,
                    },
                    raylib.SHADER_UNIFORM_VEC2,
                );

                raylib.SetMousePosition(@intFromFloat(screenSize.x / 2), @intFromFloat(screenSize.y / 2));
            }

            // Increment/decrement c value with time
            if (MandalbrotViewModel.increment) {
                if (MandalbrotViewModel.c[0] > -0.3) {
                    MandalbrotViewModel.increment = false;
                }
                const dc = raylib.GetFrameTime() * MandalbrotViewModel.incrementSpeed * 0.0005;
                MandalbrotViewModel.c[0] += dc;
                MandalbrotViewModel.c[1] += dc;
            } else {
                if (MandalbrotViewModel.c[0] < -0.35) {
                    MandalbrotViewModel.increment = true;
                }
                const dc = raylib.GetFrameTime() * MandalbrotViewModel.incrementSpeed * 0.0005;
                MandalbrotViewModel.c[0] -= dc;
                MandalbrotViewModel.c[1] -= dc;
            }
            raylib.SetShaderValue(
                MandalbrotViewModel.juliaShader.shader,
                MandalbrotViewModel.cLoc,
                &MandalbrotViewModel.c,
                raylib.SHADER_UNIFORM_VEC2,
            );

            raylib.BeginTextureMode(MandalbrotViewModel.target); // Enable drawing to texture
            raylib.BeginShaderMode(MandalbrotViewModel.juliaShader.shader);
            raylib.ClearBackground(raylib.BLANK); // Clear the render texture
            const mousePosition = Common.Input.PointerPosition();
            raylib.DrawCircleV(
                raylib.Vector2{
                    .x = (screenSize.x - mousePosition.x),
                    .y = (mousePosition.y + 50),
                },
                @max(screenSize.x, screenSize.y) * 1.5,
                raylib.BLANK,
            );
            raylib.EndShaderMode();
            raylib.EndTextureMode();

            raylib.ClearBackground(raylib.BLANK); // Clear screen background

            // Draw the saved texture and rendered julia set with shader
            // NOTE: We do not invert texture on Y, already considered inside shader
            raylib.BeginShaderMode(MandalbrotViewModel.waveShader.shader);
            raylib.DrawTextureEx(MandalbrotViewModel.target.texture, raylib.Vector2{ .x = 0.0, .y = -50.0 }, 0.0, 1.0, raylib.WHITE);
            raylib.EndShaderMode();

            return .Mandalbrot;
        }
    },
    struct {
        pub fn init() void {
            const screenSize = Common.Helpers.ScreenSize();

            raylib.SetMousePosition(@intFromFloat(screenSize.x / 2), @intFromFloat(screenSize.y / 2));

            MandalbrotViewModel.juliaShader = Common.Shader.Get(null, .julia);
            MandalbrotViewModel.waveShader = Common.Shader.Get(null, .wave);
            MandalbrotViewModel.target = raylib.LoadRenderTexture(@intFromFloat(screenSize.x + 200), @intFromFloat(screenSize.y + 100));
            //raylib.SetTextureFilter(MandalbrotViewModel.target.texture, raylib.TEXTURE_FILTER_ANISOTROPIC_8X);

            // Randomize starting position
            const random = Common.Random.Get();
            const randomMod = random.float(f32) * (MandalbrotViewModel.startingC[0] + 0.3);
            MandalbrotViewModel.c = MandalbrotViewModel.startingC;
            MandalbrotViewModel.c[0] -= randomMod;
            MandalbrotViewModel.c[1] -= randomMod;
            MandalbrotViewModel.increment = random.boolean();

            MandalbrotViewModel.cLoc = raylib.GetShaderLocation(MandalbrotViewModel.juliaShader.shader, "c");
            MandalbrotViewModel.zoomLoc = raylib.GetShaderLocation(MandalbrotViewModel.juliaShader.shader, "zoom");
            MandalbrotViewModel.offsetLoc = raylib.GetShaderLocation(MandalbrotViewModel.juliaShader.shader, "offset");

            raylib.SetShaderValue(
                MandalbrotViewModel.juliaShader.shader,
                MandalbrotViewModel.cLoc,
                &MandalbrotViewModel.c,
                raylib.SHADER_UNIFORM_VEC2,
            );
            raylib.SetShaderValue(
                MandalbrotViewModel.juliaShader.shader,
                MandalbrotViewModel.zoomLoc,
                &MandalbrotViewModel.startingZoom,
                raylib.SHADER_UNIFORM_FLOAT,
            );
            raylib.SetShaderValue(
                MandalbrotViewModel.juliaShader.shader,
                MandalbrotViewModel.offsetLoc,
                &MandalbrotViewModel.offset,
                raylib.SHADER_UNIFORM_VEC2,
            );

            MandalbrotViewModel.waveScreenSizeLoc = raylib.GetShaderLocation(MandalbrotViewModel.waveShader.shader, "size");
            MandalbrotViewModel.waveTimeLoc = raylib.GetShaderLocation(MandalbrotViewModel.waveShader.shader, "seconds");

            raylib.SetShaderValue(
                MandalbrotViewModel.waveShader.shader,
                MandalbrotViewModel.waveScreenSizeLoc,
                &raylib.Vector2{
                    .x = screenSize.x + 100,
                    .y = screenSize.y + 100,
                },
                raylib.SHADER_UNIFORM_VEC2,
            );

            raylib.SetShaderValue(
                MandalbrotViewModel.waveShader.shader,
                MandalbrotViewModel.waveTimeLoc,
                &0,
                raylib.SHADER_UNIFORM_FLOAT,
            );
        }
        pub fn deinit() void {
            raylib.UnloadRenderTexture(MandalbrotViewModel.target);
        }
    },
);
