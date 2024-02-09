const std = @import("std");
const Common = @import("root").Common;
const raylib = Common.raylib;

const MandalbrotViewModel = Common.ViewLocator.getViewModel(.Mandalbrot);

pub const MandalbrotView = Common.ViewLocator.createView(
    struct {
        pub fn draw() Common.ViewLocator.Views {
            // Update
            //----------------------------------------------------------------------------------
            // Press [1 - 6] to reset c to a point of interest
            if (raylib.IsKeyPressed(raylib.KEY_ONE) or
                raylib.IsKeyPressed(raylib.KEY_TWO) or
                raylib.IsKeyPressed(raylib.KEY_THREE) or
                raylib.IsKeyPressed(raylib.KEY_FOUR) or
                raylib.IsKeyPressed(raylib.KEY_FIVE) or
                raylib.IsKeyPressed(raylib.KEY_SIX))
            {
                if (raylib.IsKeyPressed(raylib.KEY_ONE)) {
                    MandalbrotViewModel.c[0] = MandalbrotViewModel.pointsOfInterest[0][0];
                    MandalbrotViewModel.c[1] = MandalbrotViewModel.pointsOfInterest[0][1];
                } else if (raylib.IsKeyPressed(raylib.KEY_TWO)) {
                    MandalbrotViewModel.c[0] = MandalbrotViewModel.pointsOfInterest[1][0];
                    MandalbrotViewModel.c[1] = MandalbrotViewModel.pointsOfInterest[1][1];
                } else if (raylib.IsKeyPressed(raylib.KEY_THREE)) {
                    MandalbrotViewModel.c[0] = MandalbrotViewModel.pointsOfInterest[2][0];
                    MandalbrotViewModel.c[1] = MandalbrotViewModel.pointsOfInterest[2][1];
                } else if (raylib.IsKeyPressed(raylib.KEY_FOUR)) {
                    MandalbrotViewModel.c[0] = MandalbrotViewModel.pointsOfInterest[3][0];
                    MandalbrotViewModel.c[1] = MandalbrotViewModel.pointsOfInterest[3][1];
                } else if (raylib.IsKeyPressed(raylib.KEY_FIVE)) {
                    MandalbrotViewModel.c[0] = MandalbrotViewModel.pointsOfInterest[4][0];
                    MandalbrotViewModel.c[1] = MandalbrotViewModel.pointsOfInterest[4][1];
                } else if (raylib.IsKeyPressed(raylib.KEY_SIX)) {
                    MandalbrotViewModel.c[0] = MandalbrotViewModel.pointsOfInterest[5][0];
                    MandalbrotViewModel.c[1] = MandalbrotViewModel.pointsOfInterest[5][1];
                }

                raylib.SetShaderValue(
                    MandalbrotViewModel.shader.shader,
                    MandalbrotViewModel.cLoc,
                    &MandalbrotViewModel.c,
                    raylib.SHADER_UNIFORM_VEC2,
                );
            }

            // If "R" is pressed, reset zoom and offset.
            if (raylib.IsKeyPressed(raylib.KEY_R)) {
                MandalbrotViewModel.zoom = MandalbrotViewModel.startingZoom;
                MandalbrotViewModel.offset[0] = 0.0;
                MandalbrotViewModel.offset[1] = 0.0;
                raylib.SetShaderValue(
                    MandalbrotViewModel.shader.shader,
                    MandalbrotViewModel.zoomLoc,
                    &MandalbrotViewModel.zoom,
                    raylib.SHADER_UNIFORM_FLOAT,
                );
                raylib.SetShaderValue(
                    MandalbrotViewModel.shader.shader,
                    MandalbrotViewModel.offsetLoc,
                    &MandalbrotViewModel.offset,
                    raylib.SHADER_UNIFORM_VEC2,
                );
            }

            if (raylib.IsKeyPressed(raylib.KEY_SPACE)) MandalbrotViewModel.incrementSpeed = 0; // Pause animation (c change)
            if (raylib.IsKeyPressed(raylib.KEY_F1)) MandalbrotViewModel.showControls = !MandalbrotViewModel.showControls; // Toggle whether or not to show controls

            if (raylib.IsKeyPressed(raylib.KEY_RIGHT)) {
                MandalbrotViewModel.incrementSpeed += 1;
            } else if (raylib.IsKeyPressed(raylib.KEY_LEFT)) {
                MandalbrotViewModel.incrementSpeed -= 1;
            }

            // If either left or right button is pressed, zoom in/out.
            if (raylib.IsMouseButtonDown(raylib.MOUSE_BUTTON_LEFT) or raylib.IsMouseButtonDown(raylib.MOUSE_BUTTON_RIGHT)) {
                // Change zoom. If Mouse left -> zoom in. Mouse right -> zoom out.
                MandalbrotViewModel.zoom *= if (raylib.IsMouseButtonDown(raylib.MOUSE_BUTTON_LEFT)) MandalbrotViewModel.zoomSpeed else 1.0 / MandalbrotViewModel.zoomSpeed;

                const mousePos: raylib.Vector2 = raylib.GetMousePosition();
                var offsetVelocity: raylib.Vector2 = undefined;
                // Find the velocity at which to change the camera. Take the distance of the mouse
                // from the center of the screen as the direction, and adjust magnitude based on
                // the current zoom.
                offsetVelocity.x = (mousePos.x / @as(f32, @floatFromInt(raylib.GetScreenWidth())) - 0.5) * MandalbrotViewModel.offsetSpeedMul / MandalbrotViewModel.zoom;
                offsetVelocity.y = (mousePos.y / @as(f32, @floatFromInt(raylib.GetScreenHeight())) - 0.5) * MandalbrotViewModel.offsetSpeedMul / MandalbrotViewModel.zoom;

                // Apply move velocity to camera
                MandalbrotViewModel.offset[0] += raylib.GetFrameTime() * offsetVelocity.x;
                MandalbrotViewModel.offset[1] += raylib.GetFrameTime() * offsetVelocity.y;

                // Update the shader uniform values!
                raylib.SetShaderValue(
                    MandalbrotViewModel.shader.shader,
                    MandalbrotViewModel.zoomLoc,
                    &MandalbrotViewModel.zoom,
                    raylib.SHADER_UNIFORM_FLOAT,
                );
                raylib.SetShaderValue(
                    MandalbrotViewModel.shader.shader,
                    MandalbrotViewModel.offsetLoc,
                    &MandalbrotViewModel.offset,
                    raylib.SHADER_UNIFORM_VEC2,
                );
            }

            // Increment c value with time
            const dc = raylib.GetFrameTime() * MandalbrotViewModel.incrementSpeed * 0.0005;
            MandalbrotViewModel.c[0] += dc;
            MandalbrotViewModel.c[1] += dc;
            raylib.SetShaderValue(
                MandalbrotViewModel.shader.shader,
                MandalbrotViewModel.cLoc,
                &MandalbrotViewModel.c,
                raylib.SHADER_UNIFORM_VEC2,
            );
            //----------------------------------------------------------------------------------

            // Draw
            //----------------------------------------------------------------------------------
            // Using a render texture to draw Julia set
            raylib.BeginTextureMode(MandalbrotViewModel.target); // Enable drawing to texture
            raylib.ClearBackground(raylib.BLANK); // Clear the render texture

            // Draw a rectangle in shader mode to be used as shader canvas
            // NOTE: Rectangle uses font white character texture coordinates,
            // so shader can not be applied here directly because input vertexTexCoord
            // do not represent full screen coordinates (space where want to apply shader)
            raylib.DrawRectangle(0, 0, raylib.GetScreenWidth(), raylib.GetScreenHeight(), raylib.BLANK);
            raylib.EndTextureMode();

            raylib.ClearBackground(raylib.BLANK); // Clear screen background

            // Draw the saved texture and rendered julia set with shader
            // NOTE: We do not invert texture on Y, already considered inside shader
            raylib.BeginShaderMode(MandalbrotViewModel.shader.shader);
            // WARNING: If FLAG_WINDOW_HIGHDPI is enabled, HighDPI monitor scaling should be considered
            // when rendering the RenderTexture2D to fit in the HighDPI scaled Window
            raylib.DrawTextureEx(MandalbrotViewModel.target.texture, raylib.Vector2{ .x = 0.0, .y = 0.0 }, 0.0, 1.0, raylib.BLANK);
            raylib.EndShaderMode();

            if (MandalbrotViewModel.showControls) {
                raylib.DrawText("Press Mouse buttons right/left to zoom in/out and move", 10, 15, 10, raylib.RAYWHITE);
                raylib.DrawText("Press KEY_F1 to toggle these controls", 10, 30, 10, raylib.RAYWHITE);
                raylib.DrawText("Press KEYS [1 - 6] to change point of interest", 10, 45, 10, raylib.RAYWHITE);
                raylib.DrawText("Press KEY_LEFT | KEY_RIGHT to change speed", 10, 60, 10, raylib.RAYWHITE);
                raylib.DrawText("Press KEY_SPACE to stop movement animation", 10, 75, 10, raylib.RAYWHITE);
                raylib.DrawText("Press KEY_R to recenter the camera", 10, 90, 10, raylib.RAYWHITE);
            }
            //----------------------------------------------------------------------------------

            return .Mandalbrot;
        }
    },
    struct {
        pub fn init() void {
            const screenWidth = raylib.GetScreenWidth();
            const screenHeight = raylib.GetScreenHeight();

            MandalbrotViewModel.shader = Common.Shader.Get(null, .julia);
            MandalbrotViewModel.target = raylib.LoadRenderTexture(screenWidth, screenHeight);
            raylib.SetTextureFilter(MandalbrotViewModel.target.texture, raylib.TEXTURE_FILTER_TRILINEAR);

            MandalbrotViewModel.cLoc = raylib.GetShaderLocation(MandalbrotViewModel.shader.shader, "c");
            MandalbrotViewModel.zoomLoc = raylib.GetShaderLocation(MandalbrotViewModel.shader.shader, "zoom");
            MandalbrotViewModel.offsetLoc = raylib.GetShaderLocation(MandalbrotViewModel.shader.shader, "offset");

            raylib.SetShaderValue(
                MandalbrotViewModel.shader.shader,
                MandalbrotViewModel.cLoc,
                &MandalbrotViewModel.c,
                raylib.SHADER_UNIFORM_VEC2,
            );
            raylib.SetShaderValue(
                MandalbrotViewModel.shader.shader,
                MandalbrotViewModel.zoomLoc,
                &MandalbrotViewModel.zoom,
                raylib.SHADER_UNIFORM_FLOAT,
            );
            raylib.SetShaderValue(
                MandalbrotViewModel.shader.shader,
                MandalbrotViewModel.offsetLoc,
                &MandalbrotViewModel.offset,
                raylib.SHADER_UNIFORM_VEC2,
            );
        }
        pub fn deinit() void {
            raylib.UnloadRenderTexture(MandalbrotViewModel.target);
        }
    },
);
