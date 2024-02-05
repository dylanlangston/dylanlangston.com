const std = @import("std");
const Common = @import("Common.zig").Common;
const raylib = Common.raylib;
const emscripten = Common.emscripten;
const stdio = @cImport({
    @cInclude("stdio.h");
});

pub const Logger = struct {
    const MAX_MESSAGE_LENGTH = 256;

    pub inline fn init() void {
        const Callbacks = struct {
            const LogLevels = enum(c_int) {
                ALL = 0,
                TRACE = 1,
                DEBUG = 2,
                INFO = 3,
                WARNING = 4,
                ERROR = 5,
                FATAL = 6,
                NONE = 7,
            };

            inline fn bufferSize(c_text: [*c]const u8, va_list: ?*anyopaque) usize {
                const size = stdio.vsnprintf(null, 0, c_text, va_list);
                return @as(usize, @intCast(size)) + 1; // safe byte for \0
            }

            inline fn sprintf(c_text: [*c]const u8, va_list: ?*anyopaque) [*]u8 {
                // const size = stdio.vsprintf(null, c_text, va_list);
                // _ = size; // autofix
                //var buf = std.ArrayList(u8).init(Common.GetAllocator()).
                _ = bufferSize(c_text, va_list);
                var buf: [MAX_MESSAGE_LENGTH]u8 = undefined;
                _ = stdio.vsprintf(&buf, c_text, va_list);
                return &buf;
            }

            fn TraceLogDesktop(c_logLevel: c_int, c_text: [*c]const u8, va_list: ?*raylib.struct___va_list_tag_1) callconv(.C) void {
                const logLevel: LogLevels = @enumFromInt(c_logLevel);

                std.debug.print("{?s}: {s}\n", .{ std.enums.tagName(LogLevels, logLevel), sprintf(c_text, va_list) });
            }
            fn TraceLogWeb(c_logLevel: c_int, c_text: [*c]const u8, va_list: ?*anyopaque) callconv(.C) void {
                const logLevel: LogLevels = @enumFromInt(c_logLevel);
                const tagNamePtr = std.enums.tagName(LogLevels, logLevel).?.ptr;

                switch (logLevel) {
                    .DEBUG => {
                        emscripten.emscripten_log(emscripten.EM_LOG_DEBUG, "%s: %s", tagNamePtr, sprintf(c_text, va_list));
                    },
                    .WARNING => {
                        emscripten.emscripten_log(emscripten.EM_LOG_WARN, "%s: %s", tagNamePtr, sprintf(c_text, va_list));
                    },
                    .ERROR => {
                        emscripten.emscripten_log(emscripten.EM_LOG_ERROR, "%s: %s", tagNamePtr, sprintf(c_text, va_list));
                    },
                    else => {
                        emscripten.emscripten_log(emscripten.EM_LOG_INFO, "%s: %s", tagNamePtr, sprintf(c_text, va_list));
                    },
                }
            }
        };
        raylib.SetTraceLogCallback(if (Common.is_emscripten) &Callbacks.TraceLogWeb else &Callbacks.TraceLogDesktop);
    }

    inline fn log(loglevel: raylib.TraceLogLevel, text: [:0]const u8) void {
        raylib.TraceLog(loglevel, text);
    }

    pub inline fn Trace(text: [:0]const u8) void {
        log(raylib.LOG_TRACE, text);
    }
    pub inline fn Debug(text: [:0]const u8) void {
        log(raylib.LOG_DEBUG, text);
    }
    pub inline fn Info(text: [:0]const u8) void {
        log(raylib.LOG_INFO, text);
    }
    pub inline fn Warning(text: [:0]const u8) void {
        log(raylib.LOG_WARNING, text);
    }
    pub inline fn Error(text: [:0]const u8) void {
        log(raylib.LOG_ERROR, text);
    }
    pub inline fn Fatal(text: [:0]const u8) void {
        log(raylib.LOG_FATAL, text);
    }

    pub inline fn Trace_Formatted(comptime format: []const u8, args: anytype) void {
        log_formatted(raylib.LOG_TRACE, format, args);
    }
    pub inline fn Debug_Formatted(comptime format: []const u8, args: anytype) void {
        log_formatted(raylib.LOG_DEBUG, format, args);
    }
    pub inline fn Info_Formatted(comptime format: []const u8, args: anytype) void {
        log_formatted(raylib.LOG_INFO, format, args);
    }
    pub inline fn Warning_Formatted(comptime format: []const u8, args: anytype) void {
        log_formatted(raylib.LOG_WARNING, format, args);
    }
    pub inline fn Error_Formatted(comptime format: []const u8, args: anytype) void {
        log_formatted(raylib.LOG_ERROR, format, args);
    }
    pub inline fn Fatal_Formatted(comptime format: []const u8, args: anytype) void {
        log_formatted(raylib.LOG_FATAL, format, args);
    }

    inline fn log_formatted(level: raylib.TraceLogLevel, comptime format: []const u8, args: anytype) void {
        const aloc = Common.GetAllocator();
        const text = std.fmt.allocPrint(aloc, format, args) catch {
            std.debug.print("DEBUG FALLBACK LOGGER:" ++ format ++ "\n", args);
            return;
        };
        defer aloc.free(text);
        const raylib_text = aloc.dupeZ(u8, text) catch {
            std.debug.print("DEBUG FALLBACK LOGGER:" ++ format ++ "\n", args);
            return;
        };
        defer aloc.free(raylib_text);

        log(level, raylib_text);
    }
};