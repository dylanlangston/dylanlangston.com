const std = @import("std");
const builtin = @import("builtin");

const assets: []const assetType = &[_]assetType{
    .{ .path = "music", .module_name = "music_assets", .allowed_exts = &[_][]const u8{".ogg"} },
};

// The Max size for a single file in bytes
const maxSizeInBytes = 1000000;

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
    var paths = std.ArrayList([]const u8).init(b.allocator);
    var names = std.ArrayList([]const u8).init(b.allocator);
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
                // try sources.append(b.dupe(try std.fmt.allocPrint(b.allocator, ".{s}{s}", .{
                //     std.fs.path.sep_str,
                //     b.pathJoin(&[_][]const u8{ path, entry.path }),
                // })));
                const fileName = b.pathJoin(&[_][]const u8{ "./zig", "assets", path[0..path.len], entry.path });

                try paths.append(fileName);
                try names.append(try b.allocator.dupe(u8, entry.basename));
            }
        }
    }

    const file_name = try std.mem.concat(b.allocator, u8, &[_][]const u8{ module_name, ".zig" }); // module_name ++ ".zig";
    const format =
        \\pub const {s} = struct {{
        \\  pub const data = [_][]const u8 {{ "{s}" }};
        \\  pub const names = [_][]const u8 {{ "{s}" }};
        \\}};
    ;

    const string = try std.fmt.allocPrint(b.allocator, format, .{
        module_name,
        try std.mem.join(b.allocator, "\", \"", paths.items),
        try std.mem.join(b.allocator, "\", \"", names.items),
    });

    const files_step = b.addWriteFiles();
    const file = files_step.add(file_name, string);

    // const module = b.addModule(module_name, .{
    //     .root_source_file = file.dupe(b),
    // });
    // c.step.dependOn(&files_step.step);
    // c.root_module.addImport(module_name, module);
    c.root_module.addAnonymousImport(module_name, .{
        .root_source_file = file.dupe(b),
    });

    //c.addModule(module_name, module);
}
