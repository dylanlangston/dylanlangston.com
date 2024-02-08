const std = @import("std");
const Common = @import("root").Common;

pub inline fn Create(comptime view: type) type {
    ensureDrawRoutine(view);
    return struct {
        pub usingnamespace view;
    };
}

inline fn ensureDrawRoutine(comptime T: type) void {
    comptime {
        if (!@hasDecl(T, "draw")) @compileError("View must have decl Draw: fn() Common.ViewLocator.Views");
        if (@TypeOf(T.draw) != fn () Common.ViewLocator.Views) {
            @compileLog(@TypeOf(T.Draw));
            @compileError(
                "View.Draw must be a fn() Common.ViewLocator.Views",
            );
        }
    }
}
