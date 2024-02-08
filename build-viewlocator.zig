const std = @import("std");
const builtin = @import("builtin");

pub inline fn importViews(
    comptime viewPath: [:0]const u8,
    comptime viewModelPath: [:0]const u8,
    comptime module_name: [:0]const u8,
    b: *std.Build,
    t: std.Build.ResolvedTarget,
    o: std.builtin.OptimizeMode,
    c: *std.Build.Step.Compile,
) !void {
    _ = t;
    _ = o;

    var views = std.ArrayList([]const u8).init(b.allocator);
    var viewModels = std.ArrayList([]const u8).init(b.allocator);
    var viewNames = std.ArrayList([]const u8).init(b.allocator);
    var viewModelNames = std.ArrayList([]const u8).init(b.allocator);
    var enumNames = std.ArrayList([]const u8).init(b.allocator);
    {
        const cwd = std.fs.cwd();
        const dir = try cwd.openDir(b.pathJoin(&[_][]const u8{
            "zig", "src", viewPath,
        }), .{
            .access_sub_paths = true,
            .iterate = true,
        });
        var walker = try dir.walk(b.allocator);
        defer walker.deinit();
        while (try walker.next()) |entry| {
            if (std.mem.eql(u8, entry.basename, "View.zig")) continue;
            const ext = std.fs.path.extension(entry.basename);
            const include_file = std.mem.eql(u8, ext, ".zig");
            if (include_file) {
                const enumName = b.dupe(entry.basename[0 .. entry.basename.len - 8]);
                std.mem.replaceScalar(
                    u8,
                    enumName,
                    ' ',
                    '_',
                );
                try enumNames.append(enumName);

                const name = b.pathJoin(&[_][]const u8{
                    "./zig", "src", viewPath, entry.path,
                });

                const viewModelFileName = try std.fmt.allocPrint(b.allocator, "./zig/src/{s}/{s}ViewModel.zig", .{
                    viewModelPath,
                    enumName,
                });
                const viewModelFile: ?std.fs.File = std.fs.openFileAbsolute(b.pathFromRoot(viewModelFileName), .{}) catch null;
                if (viewModelFile != null) {
                    viewModelFile.?.close();
                    try viewModelNames.append(viewModelFileName);
                    try viewModels.append(try std.fmt.allocPrint(b.allocator, "@import(\"{s}\").{s}ViewModel", .{
                        viewModelFileName,
                        enumName,
                    }));
                } else {
                    try viewModels.append("undefined");
                }

                try viewNames.append(name);
                try views.append(try std.fmt.allocPrint(b.allocator, "@constCast(&@import(\"{s}\").{s}View.draw)", .{
                    name,
                    enumName,
                }));
            }
        }
    }

    const file_name = module_name ++ ".zig";
    const format =
        \\pub const {s} = struct {{
        \\  pub const createView = @import("ViewImport").Create;
        \\  pub const createViewModel = @import("ViewModelImport").Create;
        \\
        \\  pub const Views = enum {{
        \\    {s}{s}
        \\
        \\    pub const drawFunctionTable = [@typeInfo(@This()).Enum.fields.len] *fn () Views {{
        \\      {s}
        \\    }};
        \\    pub const viewModelTable = [@typeInfo(@This()).Enum.fields.len] type {{
        \\      {s}
        \\    }};
        \\
        \\    pub inline fn foo(self: Views) void {{
        \\      
        \\    }};
        \\  }};
        \\
        \\  pub inline fn getDrawFunction(self: Views) *fn () Views {{
        \\    return Views.drawFunctionTable[@intFromEnum(self)];
        \\  }}
        \\  pub inline fn getViewModel(comptime self: Views) type {{
        \\    return Views.viewModelTable[@intFromEnum(self)];
        \\  }}
        \\}};
    ;

    const string = try std.fmt.allocPrint(b.allocator, format, .{
        module_name,
        try std.mem.join(b.allocator, ", ", enumNames.items),
        if (viewNames.items.len == 0) "" else ",",
        try std.mem.join(b.allocator, ", ", views.items),
        try std.mem.join(b.allocator, ", ", viewModels.items),
    });

    const files_step = b.addWriteFiles();
    const file = files_step.add(file_name, string);
    const module = b.addModule(module_name, .{
        .root_source_file = file.dupe(b),
    });
    module.addAnonymousImport("ViewImport", .{
        .root_source_file = .{
            .path = b.pathJoin(&[_][]const u8{
                "./zig", "src", viewPath, viewPath ++ ".zig",
            }),
        },
    });
    module.addAnonymousImport("ViewModelImport", .{
        .root_source_file = .{
            .path = b.pathJoin(&[_][]const u8{
                "./zig", "src", viewModelPath, viewModelPath ++ ".zig",
            }),
        },
    });
    for (viewNames.items) |name| {
        module.addAnonymousImport(name, .{
            .root_source_file = .{
                .path = name,
            },
        });
    }
    for (viewModelNames.items) |name| {
        module.addAnonymousImport(name, .{
            .root_source_file = .{
                .path = name,
            },
        });
    }
    c.root_module.addImport(module_name, module);
}
