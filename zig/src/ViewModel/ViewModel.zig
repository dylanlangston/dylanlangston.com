const std = @import("std");
const Common = @import("root").Common;

pub inline fn Create(comptime view_model: type, options: ?VMCreationOptions) type {
    if (options != null) {
        return struct {
            pub const init: ?*const fn () void = options.?.init;
            pub const deinit: ?*const fn () void = options.?.deinit;

            pub usingnamespace view_model;
        };
    }
    return struct {
        pub const init = null;
        pub const deinit = null;
        pub usingnamespace view_model;
    };
}

pub const VMCreationOptions = struct {
    init: ?*const fn () void = null,
    deinit: ?*const fn () void = null,
};
