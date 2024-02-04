const std = @import("std");
const Common = @import("Common.zig").Common;
const raylib = Common.raylib;

pub const AssetManager = struct {
    pub inline fn init() void {
        raylib.SetLoadFileDataCallback(&LoadFileDataCallback);
        raylib.SetLoadFileTextCallback(&LoadFileTextCallback);
    }

    fn LoadFileDataCallback(fileName: [*c]const u8, bytesRead: [*c]c_int) callconv(.C) [*c]u8 {
        // Todo: need to split this into multiple codepaths for each asset type that gets loaded
        const file: ?Music = Music.fromName(std.mem.span(fileName));
        if (file == null) @panic("Failed to find file!");
        bytesRead.* = file.?.size();
        return std.heap.raw_c_allocator.dupeZ(u8, file.?.data()) catch |err| {
            std.builtin.panicUnwrapError(null, err);
        };
    }
    fn LoadFileTextCallback(fileName: [*c]const u8) callconv(.C) [*c]u8 {
        // Todo: need to split this into multiple codepaths for each asset type that gets loaded
        const file: ?Music = Music.fromName(std.mem.span(fileName));
        if (file == null) @panic("Failed to find file!");
        return std.heap.raw_c_allocator.dupeZ(u8, file.?.data()) catch |err| {
            std.builtin.panicUnwrapError(null, err);
        };
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
            Fonts,
            raylib.Font,
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
            Music,
            raylib.Music,
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
            Sounds,
            raylib.Sound,
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
            Textures,
            raylib.Texture,
            key,
            &LoadedTextures,
            LoadTexture,
        );
    }

    var LoadedShaders: [Fragment_Shaders.count * Vertex_Shaders.count]raylib.Shader = .{};
    var LoadedShadersHashes: [Fragment_Shaders.count * Vertex_Shaders.count]u64 = .{};

    pub const Fragment_Shaders = @import("Fragment_Shaders").Fragment_Shaders;
    pub const Vertex_Shaders = @import("Vertex_Shaders").Vertex_Shaders;
    fn LoadShader(fs: Fragment_Shaders, vs: Vertex_Shaders) raylib.Shader {
        const s = raylib.LoadShaderFromMemory(vs.data(), fs.data());
        return s;
    }
    // pub inline fn GetFragmentShader(fs: Fragment_Shaders, vs: Vertex_Shaders) raylib.Shader {

    //     return LoadFromCacheFirst(
    //         Fragment_Shaders,
    //         raylib.Shader,
    //         key,
    //         &LoadShader,
    //         LoadFragmentShader,
    //     );
    // }

    inline fn LoadFromCacheFirst(
        comptime E: type,
        comptime T: type,
        key: E,
        map: *std.EnumMap(E, T),
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
