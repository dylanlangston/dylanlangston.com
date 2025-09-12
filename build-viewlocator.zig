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

    var views = std.array_list.Managed([]const u8).init(b.allocator);
    var viewModels = std.array_list.Managed([]const u8).init(b.allocator);
    var viewPaths = std.array_list.Managed([]const u8).init(b.allocator);
    var viewModelPaths = std.array_list.Managed([]const u8).init(b.allocator);
    var enumNames = std.array_list.Managed([]const u8).init(b.allocator);
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

                const name = entry.path[0 .. entry.path.len - 4];
                const viewImportPath = b.pathJoin(&[_][]const u8{
                    "./zig", "src", viewPath, entry.path,
                });

                const viewModelFileName = try std.fmt.allocPrint(b.allocator, "{s}Model", .{name});
                const viewModelImportPath = try std.fmt.allocPrint(b.allocator, "./zig/src/{s}/{s}ViewModel.zig", .{
                    viewModelPath,
                    enumName,
                });
                const viewModelFile: ?std.fs.File = std.fs.openFileAbsolute(b.pathFromRoot(viewModelImportPath), .{}) catch null;
                if (viewModelFile != null) {
                    viewModelFile.?.close();
                    try viewModelPaths.append(viewModelImportPath);
                    try viewModels.append(try std.fmt.allocPrint(b.allocator, ".{s} => @import(\"{s}\").{s}ViewModel,", .{
                        enumName,
                        viewModelFileName,
                        enumName,
                    }));
                } else {
                    try viewModels.append(try std.fmt.allocPrint(b.allocator, "{s}: void,", .{
                        enumName,
                    }));
                }

                try viewPaths.append(viewImportPath);
                try views.append(try std.fmt.allocPrint(b.allocator, "View{{ .draw = &@import(\"{s}\").{s}View.draw, .init = &@import(\"{s}\").{s}View.init, .deinit = &@import(\"{s}\").{s}View.deinit }}", .{
                    name,
                    enumName,
                    name,
                    enumName,
                    name,
                    enumName,
                }));
            }
        }
    }

    const file_name = module_name ++ ".zig";
    const format =
        \\const std = @import("std");
        \\pub const {s} = struct {{
        \\  pub const createView = @import("ViewImport").Create;
        \\  pub const createViewModel = @import("ViewModelImport").Create;
        \\
        \\  var initializedViews: std.EnumSet(Views) = std.EnumSet(Views).initEmpty();
        \\
        \\  const View = struct {{
        \\      draw: *const fn () Views,
        \\      init: *const fn () void,
        \\      deinit: *const fn () void,
        \\  }};
        \\
        \\  pub const Views = enum {{
        \\    {s}{s}
        \\
        \\    const drawFunctionTable = [@typeInfo(@This()).@"enum".fields.len] View {{
        \\      {s}
        \\    }};
        \\
        \\    pub inline fn draw(self: Views) Views {{
        \\      return drawFunctionTable[@intFromEnum(self)].draw();
        \\    }}
        \\
        \\    pub inline fn init(self: Views) void {{
        \\        if (!initializedViews.contains(self)) {{
        \\            drawFunctionTable[@intFromEnum(self)].init();
        \\            initializedViews.insert(self);
        \\        }}
        \\    }}
        \\
        \\    pub inline fn deinit(self: Views) void {{
        \\        if (initializedViews.contains(self)) {{
        \\            drawFunctionTable[@intFromEnum(self)].deinit();
        \\            initializedViews.remove(self);
        \\        }}
        \\    }}
        \\
        \\    pub inline fn update(self: Views) Views {{
        \\      const next_view = self.draw();
        \\      if (self != next_view) {{
        \\          self.deinit();
        \\          next_view.init();
        \\      }}
        \\      return next_view;
        \\    }}
        \\  }};
        \\
        \\  pub inline fn getViewModel(view: Views) type {{
        \\      return switch (view) {{
        \\          {s}
        \\      }};
        \\  }}
        \\}};
    ;

    const string = try std.fmt.allocPrint(b.allocator, format, .{
        module_name,
        try std.mem.join(b.allocator, ",\n    ", enumNames.items),
        if (viewPaths.items.len == 0) "" else ",",
        try std.mem.join(b.allocator, ",\n      ", views.items),
        try std.mem.join(b.allocator, "\n    ", viewModels.items),
    });

    const files_step = b.addWriteFiles();
    const file = files_step.add(file_name, string);
    const module = b.addModule(module_name, .{
        .root_source_file = file.dupe(b),
    });
    module.addAnonymousImport("ViewImport", .{
        .root_source_file = b.path(b.pathJoin(&[_][]const u8{
            "./zig", "src", viewPath, viewPath ++ ".zig",
        })),
    });
    module.addAnonymousImport("ViewModelImport", .{
        .root_source_file = b.path(b.pathJoin(&[_][]const u8{
            "./zig", "src", viewModelPath, viewModelPath ++ ".zig",
        })),
    });
    for (viewPaths.items) |name| {
        const basename = std.fs.path.basename(name);
        module.addAnonymousImport(basename[0 .. basename.len - 4], .{
            .root_source_file = b.path(name),
        });
    }
    for (viewModelPaths.items) |name| {
        const basename = std.fs.path.basename(name);
        module.addAnonymousImport(basename[0 .. basename.len - 4], .{
            .root_source_file = b.path(name),
        });
    }
    c.root_module.addImport(module_name, module);
}
