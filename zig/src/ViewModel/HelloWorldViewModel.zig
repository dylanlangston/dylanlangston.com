const std = @import("std");
const Common = @import("root").Common;
const raylib = Common.raylib;

pub const HelloWorldViewModel = Common.ViewLocator.ViewModel.Create(
    struct {
        pub var music: Common.Music = undefined;
    },
    .{
        .Init = init,
    },
);

fn init() void {
    HelloWorldViewModel.GetVM().music = Common.Music.Get(.Test);
}
