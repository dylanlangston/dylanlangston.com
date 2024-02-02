const std = @import("std");
const builtin = @import("builtin");

const assets: []const assetType = &[_]assetType{
    .{ .path = "music", .module_name = "music_assets", .allowed_exts = &[_][]const u8{".ogg"} },
};

const assetType = struct {
    path: [:0]const u8,
    module_name: [:0]const u8,
    allowed_exts: []const []const u8,
};

pub inline fn addAssets(
    b: *std.Build,
    c: *std.Build.Step.Compile,
) !void {
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
                try names.append(try b.allocator.dupe(u8, entry.basename));
            }
        }
    }

    const file_name = try std.mem.concat(b.allocator, u8, &[_][]const u8{ module_name, ".zig" }); // module_name ++ ".zig";
    const format =
        \\pub const {s} = struct {{
        \\  pub const files = enum {{ 
        \\  {s},
        \\
        \\  pub const filesTable = [@typeInfo(files).Enum.fields.len][:0]const u8{{
        \\      @embedFile("{s}")
        \\  }};
        \\  pub inline fn data(self: files) [:0]const u8 {{
        \\      return filesTable[@intFromEnum(self)];
        \\  }}
        \\ }};
        \\}};
    ;

    const string = try std.fmt.allocPrint(b.allocator, format, .{
        module_name,
        try std.mem.join(b.allocator, ", ", enums.items),
        try std.mem.join(b.allocator, "\"), @embedFile(\"", names.items),
    });

    const file = files_step.add(file_name, string);

    c.root_module.addAnonymousImport(module_name, .{
        .root_source_file = file.dupe(b),
    });
}
