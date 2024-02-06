const builtin = @import("builtin");
const std = @import("std");
const Common = @import("root").Common;

pub const Maps = struct {
    // Allows for zero allocations when the length of hashmap is known at comptime
    pub fn FixedLengthHashMap(comptime K: type, comptime V: type, comptime context: type) type {
        return struct {
            const Self = @This();
            pub const len = context.length;

            hashes: [len:0]u64 = undefined,
            values: [len]V = undefined,

            pub fn contains(self: Self, key: K) bool {
                return std.mem.indexOfScalar(u64, &self.hashes, context.hash(key)) != null;
            }

            pub fn get(self: Self, key: K) ?V {
                const index = std.mem.indexOfScalar(u64, &self.hashes, context.hash(key));
                return if (index == null) null else self.values[index.?];
            }

            pub fn put(self: *Self, key: K, value: V) void {
                const index = std.mem.indexOfSentinel(u64, 0, &self.hashes);
                self.hashes[index] = context.hash(key);
                self.values[index] = value;
            }
        };
    }
};
