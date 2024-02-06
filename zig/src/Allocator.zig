const builtin = @import("builtin");
const std = @import("std");
const Common = @import("root").Common;

// export fn zig_malloc(s: usize) callconv(.C) *void {
//     std.heap.raw_c_allocator.rawAlloc(len: usize, ptr_align: u8, ret_addr: usize)
//     return @ptrCast((allocator.alloc(void, s) catch |err| {
//         std.builtin.panicUnwrapError(undefined, err);
//     }));
// }

// export fn zig_calloc(num: usize, size: usize) callconv(.C) *void {
//     return @ptrCast(allocator.alloc(void, num * size) catch |err| {
//         std.builtin.panicUnwrapError(undefined, err);
//     });
// }

// export fn zig_realloc(ptr: *void, resize: usize) callconv(.C) *void {
//     allocator.rawResize(std.mem.span(ptr), log2_buf_align: u8, new_len: usize, ret_addr: usize)
//     if (allocator.resize(ptr, resize)) {
//         return ptr;
//     }
//     return undefined;
// }

// export fn zig_free(ptr: *anyopaque) callconv(.C) void {
//     allocator.rawFree(buf: []u8, log2_buf_align: u8, ret_addr: usize)
//     allocator.free(ptr);
// }

pub const emscripten_allocator = std.heap.Allocator{
    .ptr = undefined,
    .vtable = &emscripten_allocator_vtable,
};
const emscripten_allocator_vtable = std.heap.Allocator.VTable{
    .alloc = rawCAlloc,
    .resize = rawCResize,
    .free = rawCFree,
};

fn rawCAlloc(
    _: *anyopaque,
    len: usize,
    log2_ptr_align: u8,
    ret_addr: usize,
) ?[*]u8 {
    _ = log2_ptr_align;
    _ = ret_addr;
    return @as(?[*]u8, @ptrCast(malloc(len)));
}

fn rawCResize(
    _: *anyopaque,
    buf: []u8,
    log2_old_align: u8,
    new_len: usize,
    ret_addr: usize,
) bool {
    _ = log2_old_align;
    _ = ret_addr;
    return new_len <= buf.len;
}

fn rawCFree(
    _: *anyopaque,
    buf: []u8,
    log2_old_align: u8,
    ret_addr: usize,
) void {
    _ = log2_old_align;
    _ = ret_addr;
    free(buf.ptr);
}

export fn zig_malloc(size: c_ulong) ?*anyopaque {
    return malloc(size);
}
export fn zig_calloc(number: c_ulong, size: c_ulong) ?*anyopaque {
    return calloc(number, size);
}
export fn zig_realloc(ptr: ?*anyopaque, size: c_ulong) ?*anyopaque {
    return realloc(ptr, size);
}
export fn zig_free(ptr: *anyopaque) void {
    return free(ptr);
}

pub extern fn malloc(c_ulong) ?*anyopaque;
pub extern fn calloc(c_ulong, c_ulong) ?*anyopaque;
pub extern fn realloc(?*anyopaque, c_ulong) ?*anyopaque;
pub extern fn free(?*anyopaque) void;
