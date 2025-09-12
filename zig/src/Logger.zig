const std = @import("std");
const Common = @import("root").Common;
const raylib = Common.raylib;
const emscripten = Common.emscripten;
const stdio = @cImport({
    @cInclude("stdio.h");
});

pub const Logger = struct {
    const MAX_MESSAGE_LENGTH = 1024;

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

            var buf: [MAX_MESSAGE_LENGTH]u8 = undefined;
            inline fn sprintf(c_text: [*c]const u8, va_list: if (Common.is_emscripten) ?*anyopaque else ?*stdio.struct___va_list_tag_1) if (Common.is_emscripten) [*]u8 else []u8 {
                const size: usize = @intCast(stdio.vsprintf(&buf, c_text, va_list));
                if (Common.is_emscripten) {
                    return &buf;
                }
                return buf[0..size];
            }

            fn TraceLog(c_logLevel: c_int, c_text: [*c]const u8, va_list: if (Common.is_emscripten) ?*anyopaque else ?*raylib.struct___va_list_tag_1) callconv(.c) void {
                const logLevel: LogLevels = @enumFromInt(c_logLevel);
                const tagName = std.enums.tagName(LogLevels, logLevel).?;

                const formated_text = sprintf(c_text, @ptrCast(va_list));

                if (Common.is_emscripten) {
                    switch (logLevel) {
                        .DEBUG => {
                            emscripten.emscripten_log(emscripten.EM_LOG_DEBUG, "%s: %s", tagName.ptr, formated_text);
                        },
                        .WARNING => {
                            emscripten.emscripten_log(emscripten.EM_LOG_WARN, "%s: %s", tagName.ptr, formated_text);
                        },
                        .ERROR => {
                            emscripten.emscripten_log(emscripten.EM_LOG_ERROR, "%s: %s", tagName.ptr, formated_text);
                        },
                        else => {
                            emscripten.emscripten_log(emscripten.EM_LOG_INFO, "%s: %s", tagName.ptr, formated_text);
                        },
                    }
                } else {
                    std.debug.print("{?s}: {s}\n", .{
                        std.enums.tagName(LogLevels, logLevel),
                        formated_text,
                    });
                }
            }
        };
        raylib.SetTraceLogCallback(&Callbacks.TraceLog);
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
        var buf: [MAX_MESSAGE_LENGTH]u8 = undefined;
        const text = std.fmt.bufPrintZ(&buf, format, args) catch {
            std.debug.print("DEBUG FALLBACK LOGGER:" ++ format ++ "\n", args);
            return;
        };

        log(level, text);
    }
};
