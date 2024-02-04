const builtin = @import("builtin");
const std = @import("std");
const RndGen = std.rand.DefaultPrng;
const AssetManager = @import("AssetManager.zig").AssetManager;

pub const Common = struct {
    pub const raylib = @cImport({
        @cInclude("raylib.h");
    });
    pub const is_emscripten: bool = builtin.os.tag == .emscripten;
    pub const emscripten = if (is_emscripten) @cImport({
        @cInclude("emscripten.h");
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

    pub const Time = struct {
        extern fn WASMTimestamp() i64;

        pub inline fn getTimestamp() i64 {
            if (builtin.os.tag == .wasi) {
                return WASMTimestamp();
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

    pub const Font = struct {
        pub fn Get(font: AssetManager.Fonts) raylib.Font {
            return AssetManager.GetFont(font);
        }
    };

    pub const Texture = struct {
        pub fn Get(texture: AssetManager.Textures) raylib.Texture {
            return AssetManager.GetTexture(texture);
        }
    };

    pub const Shader = struct {
        pub fn Get(vs: AssetManager.Fragment_Shaders, fs: AssetManager.Fragment_Shaders) raylib.Shader {
            return AssetManager.GetShader(vs, fs);
        }
    };

    pub const Sound = struct {
        pub fn Get(sound: AssetManager.Sounds) raylib.Sound {
            return AssetManager.GetSound(sound);
        }

        pub inline fn Play(sound: AssetManager.Sounds) void {
            const s = Get(sound);
            raylib.PlaySound(s);
        }
        pub inline fn PlaySingleVoice(sound: AssetManager.Sounds) void {
            const s = Get(sound);
            raylib.PlaySound(s);
        }
        pub inline fn Pause(sound: AssetManager.Sounds) void {
            const s = Get(sound);
            raylib.PauseSound(s);
        }
        pub inline fn Resume(sound: AssetManager.Sounds) void {
            const s = Get(sound);
            raylib.ResumeSound(s);
        }
        pub inline fn Stop(sound: AssetManager.Sounds) void {
            const s = Get(sound);
            raylib.StopSound(s);
        }
    };

    pub const Music = struct {
        pub fn Get(music: AssetManager.Music) raylib.Music {
            return AssetManager.GetMusic(music);
        }

        pub inline fn Play(music: AssetManager.Music) void {
            const s = Get(music);
            if (!raylib.IsMusicStreamPlaying(s)) {
                raylib.PlayMusicStream(s);
            } else {
                raylib.UpdateMusicStream(s);
            }
        }
        pub inline fn Pause(music: AssetManager.Music) void {
            const s = Get(music);
            if (raylib.IsMusicStreamPlaying(s)) {
                raylib.PauseMusicStream(s);
            }
        }
        pub inline fn Resume(music: AssetManager.Music) void {
            const s = Get(music);
            raylib.ResumeMusicStream(s);
        }
        pub inline fn Stop(music: AssetManager.Music) void {
            const s = Get(music);
            if (raylib.IsMusicStreamPlaying(s)) {
                raylib.StopMusicStream(s);
            }
        }
        pub inline fn SetVolume(music: AssetManager.Music, volume: f32) void {
            const s = Get(music);
            raylib.SetMusicVolume(s, volume);
        }
    };

    pub inline fn init() void {
        Random.init();

        AssetManager.init();

        if (builtin.mode == .Debug) {
            raylib.SetTraceLogLevel(raylib.LOG_ALL);
        } else raylib.SetTraceLogLevel(raylib.LOG_NONE);

        raylib.SetTargetFPS(0);

        raylib.SetConfigFlags(raylib.FLAG_VSYNC_HINT | raylib.FLAG_MSAA_4X_HINT);
    }

    pub inline fn deinit() void {
        if (!is_emscripten) {
            // GeneralPurposeAllocator
            _ = Alloc.gp.deinit();
        }
    }
};
