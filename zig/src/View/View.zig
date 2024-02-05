const std = @import("std");
const Common = @import("../Common.zig").Common;
const ViewModel = @import("../ViewModel/ViewModel.zig").ViewModel;
const Views = @import("../ViewLocator.zig").Views;

pub const View = struct {
    DrawRoutine: *const fn (self: View) Views,
    VM: *const ViewModel = undefined,

    var initializedViews: std.EnumSet(Views) = std.EnumSet(Views).initEmpty();

    pub inline fn init(self: View) void {
        if (!initializedViews.contains(self.Key)) {
            if ((@intFromPtr(self.VM) != 0) and self.VM.*.Init != null) {
                self.VM.*.Init.?();
            }
            initializedViews.insert(self.Key);
        }
    }
    pub inline fn deinit(self: View) void {
        if (initializedViews.contains(self.Key)) {
            if ((@intFromPtr(self.VM) != 0) and self.VM.*.DeInit != null) {
                self.VM.*.DeInit.?();
            }
            initializedViews.remove(self.Key);
        }
    }
    pub inline fn shouldBypassDeinit(self: View) bool {
        return (@intFromPtr(self.VM) != 0 and self.VM.*.BypassDeinit.*);
    }
};
