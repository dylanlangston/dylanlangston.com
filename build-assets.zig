const std = @import("std");
const builtin = @import("builtin");

const assetType = struct {
    path: [:0]const u8,
    module_name: [:0]const u8,
    allowed_exts: []const []const u8,
};

pub inline fn getAssets(target: std.Build.ResolvedTarget) []const assetType {
    const web_build = target.query.cpu_arch == .wasm32 or target.query.cpu_arch == .wasm64;

    return &[_]assetType{
        .{ .path = "music", .module_name = "Music", .allowed_exts = &[_][]const u8{".ogg"} },
        .{ .path = "sound", .module_name = "Sounds", .allowed_exts = &[_][]const u8{".ogg"} },
        .{ .path = "font", .module_name = "Fonts", .allowed_exts = &[_][]const u8{".ttf"} },
        .{ .path = "texture", .module_name = "Texture", .allowed_exts = &[_][]const u8{".png"} },
        .{ .path = if (web_build) "shader_fragment/100" else "shader_fragment/300", .module_name = "Fragment_Shaders", .allowed_exts = &[_][]const u8{".fs"} },
        .{ .path = if (web_build) "shader_vertex/100" else "shader_vertex/300", .module_name = "Vertex_Shaders", .allowed_exts = &[_][]const u8{".vs"} },
    };
}

pub inline fn addAssets(b: *std.Build, c: *std.Build.Step.Compile, assets: []const assetType) !void {
    // Embed Assets
    for (assets) |asset| {
        try embedFiles(
            asset.path,
            asset.module_name,
            asset.allowed_exts,
            b,
            c,
        );
    }
}

inline fn embedFiles(
    path: [:0]const u8,
    module_name: [:0]const u8,
    allowed_exts: []const []const u8,
    b: *std.Build,
    c: *std.Build.Step.Compile,
) !void {
    const files_step = b.addWriteFiles();

    var names = std.ArrayList([]const u8).init(b.allocator);
    var extensions = std.ArrayList([]const u8).init(b.allocator);
    var hashes = std.ArrayList([]const u8).init(b.allocator);
    var enums = std.ArrayList([]const u8).init(b.allocator);
    {
        var dir = try std.fs.cwd().openDir(b.pathJoin(&[_][]const u8{
            "zig", "assets", path,
        }), .{
            .access_sub_paths = true,
            .iterate = true,
        });
        var walker = try dir.walk(b.allocator);
        defer walker.deinit();
        while (try walker.next()) |entry| {
            const ext = std.fs.path.extension(entry.basename);
            const include_file = for (allowed_exts) |e| {
                if (std.mem.eql(u8, ext, e))
                    break true;
            } else false;

            if (include_file) {
                const filePath = b.pathJoin(&[_][]const u8{ "./zig", "assets", path[0..path.len], entry.path });
                const fileEnum = b.dupe(entry.basename[0 .. entry.basename.len - ext.len]);

                _ = files_step.addCopyFile(.{
                    .path = filePath,
                }, entry.basename);

                try enums.append(fileEnum);
                try extensions.append(try b.allocator.dupe(u8, ext));
                try hashes.append(try std.fmt.allocPrint(b.allocator, "{}", .{std.hash_map.hashString(entry.basename)}));
                try names.append(try b.allocator.dupe(u8, entry.basename));
            }
        }
    }

    const file_name = try std.mem.concat(b.allocator, u8, &[_][]const u8{ module_name, ".zig" }); // module_name ++ ".zig";
    const format =
        \\const std = @import("std");
        \\pub const {s} = enum {{
        \\  {s}{s}
        \\
        \\  const filesTable = [@typeInfo(@This()).Enum.fields.len][:0]const u8{{
        \\      @embedFile("{s}")
        \\  }};
        \\  const extensionsTable = [@typeInfo(@This()).Enum.fields.len][:0]const u8{{
        \\      "{s}"
        \\  }};
        \\  const hashTable = [@typeInfo(@This()).Enum.fields.len]u64 {{
        \\      {s}
        \\  }};
        \\  pub inline fn extension(self: @This()) [:0]const u8 {{
        \\      return extensionsTable[@intFromEnum(self)];
        \\  }}
        \\  pub inline fn data(self: @This()) [:0]const u8 {{
        \\      return filesTable[@intFromEnum(self)];
        \\  }}
        \\  pub inline fn size(self: @This()) usize {{
        \\      return filesTable[@intFromEnum(self)].len;
        \\  }}
        \\  pub inline fn hash(self: @This()) u64 {{
        \\      return hashTable[@intFromEnum(self)];
        \\  }}
        \\  pub inline fn fromName(value: [:0]const u8) ?@This() {{
        \\      const index = std.mem.indexOfScalar(u64, &hashTable, std.hash_map.hashString(value));
        \\      if (index == null) {{
        \\          return null;
        \\      }}
        \\      return @enumFromInt(index.?);
        \\  }}
        \\  pub const count: usize = {};
        \\}};
    ;

    const string = try std.fmt.allocPrint(b.allocator, format, .{
        module_name,
        try std.mem.join(b.allocator, ", ", enums.items),
        if (names.items.len == 0) "" else ",",
        try std.mem.join(b.allocator, "\"), @embedFile(\"", names.items),
        try std.mem.join(b.allocator, "\", \"", extensions.items),
        try std.mem.join(b.allocator, ", ", hashes.items),
        names.items.len,
    });

    const file = files_step.add(file_name, string);

    c.root_module.addAnonymousImport(module_name, .{
        .root_source_file = file.dupe(b),
    });
}
