const std = @import("std");
const builtin = @import("builtin");

pub const assetType = struct {
    path: [:0]const u8,
    module_name: [:0]const u8,
    allowed_exts: []const []const u8,
};

pub inline fn addAssets(b: *std.Build, t: std.Build.ResolvedTarget, o: std.builtin.OptimizeMode, c: *std.Build.Step.Compile, assets: []const assetType) !void {
    // Embed Assets
    for (assets) |asset| {
        try embedFiles(
            asset.path,
            asset.module_name,
            asset.allowed_exts,
            b,
            t,
            o,
            c,
        );
    }
}

inline fn embedFiles(
    path: [:0]const u8,
    module_name: [:0]const u8,
    allowed_exts: []const []const u8,
    b: *std.Build,
    t: std.Build.ResolvedTarget,
    o: std.builtin.OptimizeMode,
    c: *std.Build.Step.Compile,
) !void {
    _ = t;
    _ = o;

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

                try enums.append(fileEnum);
                try extensions.append(b.dupe(ext));
                try hashes.append(try std.fmt.allocPrint(b.allocator, "{}", .{std.hash_map.hashString(entry.basename)}));
                try names.append(filePath);
            }
        }
    }

    const file_name = try std.mem.concat(b.allocator, u8, &[_][]const u8{ module_name, ".zig" }); // module_name ++ ".zig";
    const format =
        \\const std = @import("std");
        \\pub const {s} = enum {{
        \\  {s}{s}
        \\
        \\  const filesTable = [@typeInfo(@This()).@"enum".fields.len][:0]const u8{{
        \\      @embedFile("{s}")
        \\  }};
        \\  const extensionsTable = [@typeInfo(@This()).@"enum".fields.len][:0]const u8{{
        \\      "{s}"
        \\  }};
        \\  const hashTable = [@typeInfo(@This()).@"enum".fields.len]u64 {{
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

    const files_step = b.addWriteFiles();
    const file = files_step.add(file_name, string);
    const module = b.addModule(module_name, .{
        .root_source_file = file.dupe(b),
    });
    for (names.items) |name| {
        module.addAnonymousImport(name, .{
            .root_source_file = b.path(name),
        });
    }
    c.root_module.addImport(module_name, module);
}
