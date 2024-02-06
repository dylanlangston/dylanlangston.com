const std = @import("std");
const Common = @import("root").Common;

pub const ViewModel = struct {
    Init: ?*const fn () void = null,
    DeInit: ?*const fn () void = null,
    Get: *const fn () void,
    BypassDeinit: *const bool = undefined,

    pub inline fn Create(comptime view_model: type, options: ?VMCreationOptions) ViewModel {
        const Inner = struct {
            fn func() type {
                return view_model;
            }
        };

        if (options != null) {
            const init = options.?.Init;
            const deinit = options.?.DeInit;
            const bypassDeinit = &options.?.BypassDeinit;
            return ViewModel{
                .Get = @constCast(@ptrCast(&Inner.func)),
                .Init = init,
                .DeInit = deinit,
                .BypassDeinit = bypassDeinit,
            };
        }

        return ViewModel{
            .Get = @constCast(@ptrCast(&Inner.func)),
        };
    }

    pub inline fn GetVM(self: ViewModel) type {
        const vm: *const fn () type = @ptrCast(self.Get);
        return vm.*();
    }
};

pub const VMCreationOptions = struct {
    Init: ?*const fn () void = null,
    DeInit: ?*const fn () void = null,
    BypassDeinit: bool = false,
};
