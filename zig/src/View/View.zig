const std = @import("std");
const Common = @import("root").Common;

pub const View = struct {
    DrawRoutine: *const fn (self: View) Common.ViewLocator.Views,
    VM: *const Common.ViewLocator.ViewModel = undefined,

    var initializedViews: std.EnumSet(Common.ViewLocator.Views) = std.EnumSet(Common.ViewLocator.Views).initEmpty();

    pub inline fn draw(self: View) Common.ViewLocator.Views {
        return self.DrawRoutine(self);
    }
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
