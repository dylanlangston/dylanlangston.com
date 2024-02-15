const std = @import("std");
const Common = @import("root").Common;
const raylib = Common.raylib;

const MandalbrotViewModel = Common.ViewLocator.getViewModel(.Mandalbrot);

pub const MandalbrotView = Common.ViewLocator.createView(
    struct {
        pub fn draw() Common.ViewLocator.Views {
            const screenSize = Common.Helpers.ScreenSize();
            const mousePosition = Common.Input.PointerPosition();

            if (mousePosition.x != MandalbrotViewModel.currentPosition.x or mousePosition.y != MandalbrotViewModel.currentPosition.y) {
                MandalbrotViewModel.currentPosition = mousePosition;
                MandalbrotViewModel.frame += raylib.GetFrameTime();
            } else {
                MandalbrotViewModel.frame += raylib.GetFrameTime() / 5;
            }

            raylib.SetShaderValue(
                MandalbrotViewModel.waveShader.shader,
                MandalbrotViewModel.waveTimeLoc,
                &MandalbrotViewModel.frame,
                raylib.SHADER_UNIFORM_FLOAT,
            );

            // New render texture on resize
            if (raylib.IsWindowResized()) {
                raylib.UnloadRenderTexture(MandalbrotViewModel.juliaTarget);
                MandalbrotViewModel.juliaTarget = raylib.LoadRenderTexture(@intFromFloat(screenSize.x + 100), @intFromFloat(screenSize.y + 100));

                raylib.UnloadRenderTexture(MandalbrotViewModel.waveTarget);
                MandalbrotViewModel.waveTarget = raylib.LoadRenderTexture(@intFromFloat(screenSize.x + 100), @intFromFloat(screenSize.y + 100));

                raylib.SetShaderValue(
                    MandalbrotViewModel.waveShader.shader,
                    MandalbrotViewModel.waveScreenSizeLoc,
                    &raylib.Vector2{
                        .x = screenSize.x + 100,
                        .y = screenSize.y + 100,
                    },
                    raylib.SHADER_UNIFORM_VEC2,
                );
            }

            if (MandalbrotViewModel.position.x < 0) {
                MandalbrotViewModel.incrementX = true;
                MandalbrotViewModel.position = raylib.Vector2{
                    .x = 0,
                    .y = MandalbrotViewModel.position.y,
                };
            } else if (MandalbrotViewModel.position.x > screenSize.x) {
                MandalbrotViewModel.incrementX = false;
                MandalbrotViewModel.position = raylib.Vector2{
                    .x = screenSize.x,
                    .y = MandalbrotViewModel.position.y,
                };
            }
            if (MandalbrotViewModel.position.y < 0) {
                MandalbrotViewModel.incrementY = true;
                MandalbrotViewModel.position = raylib.Vector2{
                    .x = MandalbrotViewModel.position.x,
                    .y = 0,
                };
            } else if (MandalbrotViewModel.position.y > screenSize.y) {
                MandalbrotViewModel.incrementY = false;
                MandalbrotViewModel.position = raylib.Vector2{
                    .x = MandalbrotViewModel.position.x,
                    .y = screenSize.y,
                };
            }

            const movMod = 0.5;
            MandalbrotViewModel.position = raylib.Vector2{
                .x = if (MandalbrotViewModel.incrementX) MandalbrotViewModel.position.x + movMod else MandalbrotViewModel.position.x - movMod,
                .y = if (MandalbrotViewModel.incrementY) MandalbrotViewModel.position.y + movMod else MandalbrotViewModel.position.y - movMod,
            };

            // Increment/decrement c value with time
            const dc = raylib.GetFrameTime() * MandalbrotViewModel.incrementSpeed * 0.0005;

            if (MandalbrotViewModel.increment) {
                if (MandalbrotViewModel.c[0] > -0.3) {
                    MandalbrotViewModel.increment = false;
                } else {
                    MandalbrotViewModel.c[0] += dc;
                    MandalbrotViewModel.c[1] += dc;
                }
            } else {
                if (MandalbrotViewModel.c[0] < -0.35) {
                    MandalbrotViewModel.increment = true;
                } else {
                    MandalbrotViewModel.c[0] -= dc;
                    MandalbrotViewModel.c[1] -= dc;
                }
            }
            raylib.SetShaderValue(
                MandalbrotViewModel.juliaShader.shader,
                MandalbrotViewModel.cLoc,
                &MandalbrotViewModel.c,
                raylib.SHADER_UNIFORM_VEC2,
            );

            raylib.BeginTextureMode(MandalbrotViewModel.juliaTarget);
            raylib.BeginShaderMode(MandalbrotViewModel.juliaShader.shader);
            raylib.DrawCircleV(
                MandalbrotViewModel.position,
                @max(screenSize.x, screenSize.y) * 1.25,
                raylib.WHITE,
            );
            raylib.EndShaderMode();
            raylib.EndTextureMode();

            raylib.BeginTextureMode(MandalbrotViewModel.waveTarget);
            raylib.ClearBackground(raylib.BLANK);
            raylib.BeginShaderMode(MandalbrotViewModel.waveShader.shader);
            raylib.DrawTextureEx(MandalbrotViewModel.juliaTarget.texture, raylib.Vector2{ .x = 0.0, .y = 0.0 }, 0.0, 1.0, raylib.WHITE);
            raylib.EndShaderMode();
            raylib.EndTextureMode();

            raylib.ClearBackground(raylib.BLANK);
            raylib.DrawTexturePro(
                MandalbrotViewModel.waveTarget.texture,
                raylib.Rectangle{
                    .x = 0,
                    .y = 0,
                    .width = screenSize.x,
                    .height = -screenSize.y,
                },
                raylib.Rectangle{
                    .x = -50,
                    .y = 0,
                    .width = screenSize.x + 50,
                    .height = screenSize.y + 50,
                },
                raylib.Vector2{ .x = 0.0, .y = 0.0 },
                0,
                raylib.WHITE,
            );

            return .Mandalbrot;
        }
    },
    struct {
        pub fn init() void {
            const screenSize = Common.Helpers.ScreenSize();

            MandalbrotViewModel.juliaShader = Common.Shader.Get(null, .julia);
            MandalbrotViewModel.waveShader = Common.Shader.Get(null, .wave);
            MandalbrotViewModel.juliaTarget = raylib.LoadRenderTexture(@intFromFloat(screenSize.x + 200), @intFromFloat(screenSize.y + 100));
            MandalbrotViewModel.waveTarget = raylib.LoadRenderTexture(@intFromFloat(screenSize.x + 200), @intFromFloat(screenSize.y + 100));
            //raylib.SetTextureFilter(MandalbrotViewModel.target.texture, raylib.TEXTURE_FILTER_ANISOTROPIC_8X);

            // Randomize starting position
            const random = Common.Random.Get();
            const randomMod = random.float(f32) * (MandalbrotViewModel.startingC[0] + 0.3);
            MandalbrotViewModel.c = MandalbrotViewModel.startingC;
            MandalbrotViewModel.c[0] -= randomMod;
            MandalbrotViewModel.c[1] -= randomMod;
            MandalbrotViewModel.increment = random.boolean();
            MandalbrotViewModel.position = raylib.Vector2{
                .x = screenSize.x * random.float(f32),
                .y = screenSize.y * random.float(f32),
            };
            MandalbrotViewModel.incrementX = random.boolean();
            MandalbrotViewModel.incrementY = random.boolean();

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
            raylib.UnloadRenderTexture(MandalbrotViewModel.juliaTarget);
            raylib.UnloadRenderTexture(MandalbrotViewModel.waveTarget);
        }
    },
);
