const builtin = @import("builtin");
const std = @import("std");

pub const Maps = struct {
    // Allows for zero allocations when the length of hashmap is known at comptime
    pub fn FixedLengthHashMap(comptime K: type, comptime V: type, comptime context: type) type {
        return struct {
            const Self = @This();

            pub const len = context.length;

            index: usize = 0,
            hashes: [len]u64 = undefined,
            values: [len]V = undefined,

            /// The number of items in the map.
            pub fn count(self: Self) usize {
                return self.values.len;
            }

            pub fn contains(self: Self, key: K) bool {
                return if (std.mem.indexOfScalar(u64, &self.hashes, context.hash(key)) != null)
                    true
                else
                    false;
            }

            pub fn get(self: Self, key: K) ?V {
                const index = std.mem.indexOfScalar(u64, &self.hashes, context.hash(key));
                if (index == null) return null;
                return self.values[index.?];
            }

            pub fn put(self: *Self, key: K, value: V) void {
                self.hashes[self.index] = context.hash(key);
                self.values[self.index] = value;
                self.index += 1;
            }
        };
    }
};
