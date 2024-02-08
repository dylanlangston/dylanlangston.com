const std = @import("std");
const Common = @import("root").Common;
const raylib = Common.raylib;

pub const HelloWorldViewModel = Common.ViewLocator.createViewModel(
    struct {
        pub var music: Common.Music = undefined;
    },
    .{
        .init = init,
    },
);

fn init() void {
    HelloWorldViewModel.music = Common.Music.Get(.Test);
}
