const std = @import("std");
const Common = @import("root").Common;

pub inline fn Create(view: type, options: ?type) type {
    ensureDrawRoutine(view);
    return struct {
        fn noop() void {}

        pub const init: fn () void = if (options != null and @hasDecl(options.?, "init")) options.?.init else noop;
        pub const deinit: fn () void = if (options != null and @hasDecl(options.?, "deinit")) options.?.deinit else noop;

        pub usingnamespace view;
    };
}

inline fn ensureDrawRoutine(T: type) void {
    comptime {
        if (!@hasDecl(T, "draw")) @compileError("View must have decl Draw: fn() Common.ViewLocator.Views");
        if (@TypeOf(T.draw) != fn () Common.ViewLocator.Views) {
            @compileLog(T.draw);
            @compileError(
                "View.Draw must be a fn() Common.ViewLocator.Views",
            );
        }
    }
}
