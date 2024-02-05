const std = @import("std");
const builtin = @import("builtin");
const Common = @import("./Common.zig").Common;
const BaseViewModel = @import("./ViewModel/ViewModel.zig").ViewModel;
const BaseView = @import("./View/View.zig").View;
pub const Views = @import("Views").Views;

pub const ViewLocator = struct {

    inline fn GetView(view: Views) BaseView {
        return Views.typeTable[0]
    }

    pub inline fn Build(view: Views) BaseView {
        const BuiltView = GetView(view);
        BuiltView.init();
        return BuiltView;
    }

    pub inline fn Destroy(view: Views) void {
        const BuiltView = GetView(view);
        BuiltView.deinit();
    }
};
