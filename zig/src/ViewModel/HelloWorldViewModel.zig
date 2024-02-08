const std = @import("std");
const Common = @import("root").Common;
const raylib = Common.raylib;

pub const HelloWorldViewModel = Common.ViewLocator.createViewModel(
    struct {
        pub var music: Common.Music = undefined;
    },
);
