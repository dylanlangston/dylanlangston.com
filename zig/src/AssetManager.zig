const std = @import("std");
const Common = @import("Common.zig").Common;
const raylib = Common.raylib;
const Maps = @import("Generics.zig").Maps;

pub const AssetManager = struct {
    pub inline fn init() void {
        const Callbacks = struct {
            fn LoadFileData(fileName: [*c]const u8, bytesRead: [*c]c_int) callconv(.C) [*c]u8 {
                _ = fileName;
                _ = bytesRead;
                @panic("Not implemented");
                // Todo: need to split this into multiple codepaths for each asset type that gets loaded
                // const file: ?Music = Music.fromName(std.mem.span(fileName));
                // if (file == null) @panic("Failed to find file!");
                // bytesRead.* = file.?.size();
                // return std.heap.raw_c_allocator.dupeZ(u8, file.?.data()) catch |err| {
                //     std.builtin.panicUnwrapError(null, err);
                // };
            }
            fn LoadFileText(fileName: [*c]const u8) callconv(.C) [*c]u8 {
                _ = fileName;
                @panic("Not implemented");
                // Todo: need to split this into multiple codepaths for each asset type that gets loaded
                // const file: ?Music = Music.fromName(std.mem.span(fileName));
                // if (file == null) @panic("Failed to find file!");
                // return std.heap.raw_c_allocator.dupeZ(u8, file.?.data()) catch |err| {
                //     std.builtin.panicUnwrapError(null, err);
                // };
            }
        };
        raylib.SetLoadFileDataCallback(&Callbacks.LoadFileData);
        raylib.SetLoadFileTextCallback(&Callbacks.LoadFileText);
    }
    pub inline fn deinit() void {
        // for (LoadedFonts.values) |font| {
        //     raylib.UnloadFont(font);
        // }
        for (LoadedMusic.values) |music| {
            raylib.UnloadMusicStream(music);
        }
        // for (LoadedSounds.values) |sound| {
        //     raylib.UnloadSound(sound);
        // }
        // for (LoadedTextures.values) |texture| {
        //     raylib.UnloadTexture(texture);
        // }
        // for (LoadedShaders.values) |shader| {
        //     raylib.UnloadShader(shader);
        // }
    }

    pub const Fonts = @import("Fonts").Fonts;
    var LoadedFonts: std.EnumMap(Fonts, raylib.Font) = std.EnumMap(Fonts, raylib.Font){};
    fn LoadFont(asset: Fonts) raylib.Font {
        var fontChars: [250]i32 = .{};
        inline for (0..fontChars.len) |i| fontChars[i] = @as(i32, @intCast(i)) + 32;
        const f = raylib.LoadFontFromMemory(asset.extension(), asset.data(), asset.size(), 100, &fontChars, fontChars.len);
        raylib.SetTextureFilter(
            f.texture,
            @intFromEnum(raylib.TextureFilter.texture_filter_trilinear),
        );
        return f;
    }
    pub inline fn GetFont(key: Fonts) raylib.Font {
        return LoadFromCacheFirst(
            @TypeOf(key),
            raylib.Font,
            @TypeOf(LoadedFonts),
            key,
            &LoadedFonts,
            LoadFont,
        );
    }

    pub const Music = @import("Music").Music;
    var LoadedMusic: std.EnumMap(Music, raylib.Music) = std.EnumMap(Music, raylib.Music){};
    fn LoadMusic(asset: Music) raylib.Music {
        const m = raylib.LoadMusicStreamFromMemory(asset.extension(), asset.data(), asset.size());
        return m;
    }
    pub inline fn GetMusic(key: Music) raylib.Music {
        return LoadFromCacheFirst(
            @TypeOf(key),
            raylib.Music,
            @TypeOf(LoadedMusic),
            key,
            &LoadedMusic,
            LoadMusic,
        );
    }

    pub const Sounds = @import("Sounds").Sounds;
    var LoadedSounds: std.EnumMap(Sounds, raylib.Sound) = std.EnumMap(Sounds, raylib.Sound){};
    fn LoadSound(asset: Sounds) raylib.Sound {
        const w = raylib.LoadWaveFromMemory(asset.extension(), asset.data(), asset.size());
        const s = raylib.LoadSoundFromWave(w);
        return s;
    }
    pub inline fn GetSound(key: Sounds) raylib.Sound {
        return LoadFromCacheFirst(
            @TypeOf(key),
            raylib.Sound,
            @TypeOf(LoadedSounds),
            key,
            &LoadedSounds,
            LoadSound,
        );
    }

    pub const Textures = @import("Textures").Textures;
    var LoadedTextures: std.EnumMap(Textures, raylib.Texture) = std.EnumMap(Textures, raylib.Texture){};
    fn LoadTexture(asset: Textures) raylib.Texture {
        const i = raylib.LoadImageFromMemory(asset.extension(), asset.data(), asset.size());
        const t = raylib.LoadTextureFromImage(i);
        raylib.SetTextureFilter(
            t,
            @intFromEnum(raylib.TextureFilter.texture_filter_trilinear),
        );
        return t;
    }
    pub inline fn GetTexture(key: Textures) raylib.Texture {
        return LoadFromCacheFirst(
            @TypeOf(key),
            raylib.Texture,
            @TypeOf(LoadedTextures),
            key,
            &LoadedTextures,
            LoadTexture,
        );
    }

    const ShaderPair = struct {
        Vertext: Vertex_Shaders,
        Fragment: Fragment_Shaders,
    };
    pub fn ShaderPairMap() type {
        return Maps.FixedLengthHashMap(ShaderPair, raylib.Shader, struct {
            pub const length: usize = Fragment_Shaders.count * Vertex_Shaders.count;
            pub fn hash(s: ShaderPair) u64 {
                return s.Fragment.hash() ^ s.Vertext.hash();
            }
        });
    }

    pub const Fragment_Shaders = @import("Fragment_Shaders").Fragment_Shaders;
    pub const Vertex_Shaders = @import("Vertex_Shaders").Vertex_Shaders;
    var LoadedShaders: ShaderPairMap() = ShaderPairMap(){};

    fn LoadShader(shaderPair: ShaderPair) raylib.Shader {
        const s = raylib.LoadShaderFromMemory(shaderPair.Vertext.data(), shaderPair.Fragment.data());
        return s;
    }
    pub inline fn GetShader(vs: Vertex_Shaders, fs: Fragment_Shaders) raylib.Shader {
        const key = ShaderPair{
            .Vertext = vs,
            .Fragment = fs,
        };

        return LoadFromCacheFirst(
            @TypeOf(key),
            raylib.Shader,
            @TypeOf(LoadedShaders),
            key,
            &LoadedShaders,
            LoadShader,
        );
    }

    inline fn LoadFromCacheFirst(
        comptime E: type,
        comptime T: type,
        comptime M: type,
        key: E,
        map: *M,
        loadFn: *const fn (rawAsset: E) T,
    ) T {
        if (map.contains(key)) {
            return map.get(key).?;
        }

        const loadedAsset = loadFn(key);
        map.put(key, loadedAsset);
        return loadedAsset;
    }
};
