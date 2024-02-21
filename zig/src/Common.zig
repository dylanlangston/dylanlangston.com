const builtin = @import("builtin");
const std = @import("std");
const RndGen = std.rand.DefaultPrng;
const AssetLoader = @import("AssetLoader.zig").AssetLoader;
const Logger = @import("Logger.zig").Logger;
const Inputs = @import("Inputs.zig").Inputs;
const MiscellaneousHelpers = @import("MiscellaneousHelpers.zig").MiscellaneousHelpers;
const Generics = @import("Generics.zig");

pub const Common = struct {
    pub const raylib = @cImport({
        @cInclude("raylib.h");
        @cInclude("raymath.h");
        @cInclude("rlgl.h");
    });
    pub const raygui = @cImport({
        @cInclude("raygui.h");
    });
    pub const is_emscripten: bool = builtin.os.tag == .emscripten or builtin.os.tag == .wasi;
    pub const emscripten = if (is_emscripten) @cImport({
        @cInclude("emscripten.h");
        @cInclude("emscripten/html5.h");
    }) else null;

    const Alloc = struct {
        pub var gp: std.heap.GeneralPurposeAllocator(.{
            .enable_memory_limit = true,
        }) = GetGPAllocator();
        inline fn GetGPAllocator() std.heap.GeneralPurposeAllocator(.{
            .enable_memory_limit = true,
        }) {
            if (builtin.mode == .Debug) {
                if (is_emscripten) {
                    return undefined;
                }
                var gpAlloc = std.heap.GeneralPurposeAllocator(.{
                    .enable_memory_limit = true,
                }){};
                // 512mb
                gpAlloc.setRequestedMemoryLimit(536870912);
                return gpAlloc;
            }

            return undefined;
        }
        pub const allocator: std.mem.Allocator = InitAllocator();
        inline fn InitAllocator() std.mem.Allocator {
            if (is_emscripten) {
                return std.heap.raw_c_allocator;
            } else if (builtin.mode == .Debug) {
                return gp.allocator();
            } else {
                return std.heap.c_allocator;
            }
        }
    };

    pub inline fn GetAllocator() std.mem.Allocator {
        return Alloc.allocator;
    }

    pub const Log = Logger;

    pub const Input = Inputs;

    pub const Helpers = MiscellaneousHelpers;

    pub const Generic = Generics;

    pub const Time = struct {
        pub inline fn getTimestamp() i64 {
            if (is_emscripten) {
                return @intFromFloat(emscripten.emscripten_get_now());
            }
            return std.time.milliTimestamp();
        }
    };

    pub const Random = struct {
        var random: std.rand.Random = undefined;
        inline fn init() void {
            const now: u64 = @intCast(Time.getTimestamp());
            var rng = RndGen.init(now);
            random = rng.random();
        }
        pub inline fn Get() std.rand.Random {
            return random;
        }
    };

    pub const Text = struct {
        pub inline fn DrawTextWithFontCentered(
            text: [:0]const u8,
            color: raylib.Color,
            font: Font,
            fontSize: f32,
            screenWidth: f32,
            positionY: f32,
        ) raylib.Vector2 {
            const TitleTextSize = raylib.MeasureTextEx(
                font.font,
                text,
                fontSize,
                @floatFromInt(font.glyphPadding),
            );
            raylib.DrawTextEx(
                font.font,
                text,
                raylib.Vector2{
                    (screenWidth - TitleTextSize.x) / 2,
                    positionY,
                },
                TitleTextSize.y,
                @floatFromInt(font.glyphPadding),
                color,
            );
            return TitleTextSize;
        }
        pub inline fn DrawTextCentered(
            text: [:0]const u8,
            color: raylib.Color,
            fontSize: f32,
            screenWidth: f32,
            positionY: f32,
        ) i32 {
            const TitleTextSize = raylib.MeasureText(text, @intFromFloat(fontSize));
            raylib.DrawText(
                text,
                @divFloor((@as(i32, @intFromFloat(screenWidth)) - TitleTextSize), 2),
                @intFromFloat(positionY),
                @intFromFloat(fontSize),
                color,
            );
            return TitleTextSize;
        }
        pub inline fn DrawTextWithFontRightAligned(
            text: [:0]const u8,
            color: raylib.Color,
            font: Font,
            fontSize: f32,
            screenWidth: f32,
            positionY: f32,
        ) void {
            const TitleTextSize = raylib.MeasureTextEx(
                font.font,
                text,
                fontSize,
                @floatFromInt(font.glyphPadding),
            );
            raylib.DrawTextEx(
                font.font,
                text,
                raylib.Vector2{
                    screenWidth - TitleTextSize.x,
                    positionY,
                },
                TitleTextSize.y,
                @floatFromInt(font.glyphPadding),
                color,
            );
        }
        pub inline fn DrawTextRightAligned(
            text: [:0]const u8,
            color: raylib.Color,
            fontSize: f32,
            screenWidth: f32,
            positionY: f32,
        ) void {
            const TitleTextSize = raylib.MeasureText(text, @intFromFloat(fontSize));
            raylib.DrawText(
                text,
                @as(i32, @intFromFloat(screenWidth)) - TitleTextSize,
                @intFromFloat(positionY),
                @intFromFloat(fontSize),
                color,
            );
        }
    };

    pub const Font = struct {
        font: raylib.Font,

        pub fn Get(font: AssetLoader.Fonts) Font {
            return Font{
                .font = AssetLoader.GetFont(font),
            };
        }
    };

    pub const Texture = struct {
        texture: raylib.Texture,

        pub fn Get(texture: AssetLoader.Textures) Texture {
            return Texture{
                .texture = AssetLoader.GetTexture(texture),
            };
        }
    };

    pub const Shader = struct {
        shader: raylib.Shader,

        pub fn Get(vs: ?AssetLoader.Vertex_Shaders, fs: ?AssetLoader.Fragment_Shaders) Shader {
            return Shader{ .shader = AssetLoader.GetShader(vs, fs) };
        }
    };

    pub const Sound = struct {
        sound: raylib.Sound,

        pub fn Get(sound: AssetLoader.Sounds) Sound {
            return Sound{
                .sound = AssetLoader.GetSound(sound),
            };
        }

        pub inline fn Play(sound: Sound) void {
            raylib.PlaySound(sound.sound);
        }
        pub inline fn PlaySingleVoice(sound: Sound) void {
            raylib.PlaySound(sound.sound);
        }
        pub inline fn Pause(sound: Sound) void {
            raylib.PauseSound(sound.sound);
        }
        pub inline fn Resume(sound: Sound) void {
            raylib.ResumeSound(sound.sound);
        }
        pub inline fn Stop(sound: Sound) void {
            raylib.StopSound(sound.sound);
        }
    };

    pub const Music = struct {
        music: raylib.Music,

        pub fn Get(music: AssetLoader.Music) Music {
            return Music{
                .music = AssetLoader.GetMusic(music),
            };
        }

        pub inline fn Play(self: Music) void {
            if (!raylib.IsMusicStreamPlaying(self.music)) {
                raylib.PlayMusicStream(self.music);
            } else {
                raylib.UpdateMusicStream(self.music);
            }
        }
        pub inline fn Pause(self: Music) void {
            if (raylib.IsMusicStreamPlaying(self.music)) {
                raylib.PauseMusicStream(self.music);
            }
        }
        pub inline fn Resume(self: Music) void {
            raylib.ResumeMusicStream(self.music);
        }
        pub inline fn Stop(self: Music) void {
            if (raylib.IsMusicStreamPlaying(self.music)) {
                raylib.StopMusicStream(self.music);
            }
        }
        pub inline fn SetVolume(self: Music, volume: f32) void {
            raylib.SetMusicVolume(self.music, volume);
        }
    };

    pub const ViewLocator = @import("ViewLocator").ViewLocator;

    pub inline fn init() void {
        Random.init();

        AssetLoader.init();

        Logger.init();

        if (builtin.mode == .Debug) {
            raylib.SetTraceLogLevel(raylib.LOG_ALL);
        } else raylib.SetTraceLogLevel(raylib.LOG_NONE);

        raylib.SetTargetFPS(0);
        raylib.SetConfigFlags(raylib.FLAG_VSYNC_HINT | raylib.FLAG_MSAA_4X_HINT);

        if (is_emscripten) {
            // Handle Resize
            _ = emscripten.emscripten_set_resize_callback(2, null, 1, &struct {
                fn resize(t: c_int, data: [*c]const emscripten.struct_EmscriptenUiEvent, callback: ?*anyopaque) callconv(.C) c_int {
                    _ = t;
                    _ = callback;
                    emscripten.emscripten_set_canvas_size(
                        data.*.windowInnerWidth,
                        data.*.windowInnerHeight,
                    );
                    Log.Info_Formatted("Resized: {}", .{data.*.windowInnerWidth});

                    // Update frame on resize so there isn't a flicker
                    @import("root").UpdateFrame();
                    return 1;
                }
            }.resize);

            // Set initial Window Size
            var width: c_int = undefined;
            var height: c_int = undefined;
            var fullscreen: c_int = undefined;
            emscripten.emscripten_get_canvas_size(&width, &height, &fullscreen);
            raylib.InitWindow(width, height, null);
        } else {
            raylib.InitWindow(1600, 900, "dylanlangston.com");
        }

        raylib.InitAudioDevice();
    }

    pub inline fn deinit() void {
        defer AssetLoader.deinit();
        // GeneralPurposeAllocator
        defer (if (!is_emscripten and builtin.mode == .Debug) {
            _ = Alloc.gp.deinit();
        });
        defer raylib.CloseWindow();
        defer raylib.CloseAudioDevice();
    }
};
