const std = @import("std");
const Common = @import("root").Common;

pub inline fn Create(comptime view_model: type) type {
    return view_model;
}
