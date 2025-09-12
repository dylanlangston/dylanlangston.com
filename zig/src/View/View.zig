const std = @import("std");
const Common = @import("root").Common;

pub inline fn Create(view: type, options: ?type) type {
    return struct {
        fn noop() void {}

        pub const init: fn () void = if (options != null and @hasDecl(options.?, "init")) options.?.init else noop;
        pub const deinit: fn () void = if (options != null and @hasDecl(options.?, "deinit")) options.?.deinit else noop;

        pub const draw: fn () Common.ViewLocator.Views = view.draw;

        pub const self = view;
    };
}
