const std = @import("std");
const builtin = @import("builtin");

const name = "dylanlangston.com";

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Set the sysroot folder for emscripten
    b.sysroot = b.pathJoin(&[_][]const u8{
        b.build_root.path.?,
        "emsdk",
        "upstream",
        "emscripten",
    });

    if (target.query.cpu_arch == .wasm32) {
        try build_web(
            b,
            target,
            optimize,
        );
    } else {
        try build_desktop(
            b,
            target,
            optimize,
        );
    }

    const exe_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "zig-src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}

pub fn build_web(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !void {
    const lib = b.addStaticLibrary(.{
        .name = name,
        .root_source_file = .{ .path = "zig-src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const raylib = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
    });
    const raylib_artifact = raylib.artifact("raylib");
    lib.addIncludePath(.{ .path = "raylib/src" });
    lib.linkLibrary(raylib_artifact);

    b.installArtifact(lib);
    b.installArtifact(raylib_artifact);

    const emccOutputDir = "zig-out" ++ std.fs.path.sep_str ++ "emscripten" ++ std.fs.path.sep_str;
    const emccImportDir = "site" ++ std.fs.path.sep_str ++ "src" ++ std.fs.path.sep_str ++ "import" ++ std.fs.path.sep_str;
    const emccExe = switch (builtin.os.tag) {
        .windows => "emcc.bat",
        else => "emcc",
    };
    var emcc_run_arg = try b.allocator.alloc(u8, b.sysroot.?.len + emccExe.len + 1);
    defer b.allocator.free(emcc_run_arg);
    emcc_run_arg = try std.fmt.bufPrint(
        emcc_run_arg,
        "{s}" ++ std.fs.path.sep_str ++ "{s}",
        .{ b.sysroot.?, emccExe },
    );

    const cwd = std.fs.cwd();

    // Create the output directory
    try cwd.makePath(emccOutputDir);

    // Create the import directory
    try cwd.makePath(emccImportDir);

    const emcc_command = b.addSystemCommand(&[_][]const u8{emcc_run_arg});

    const debugging_wasm: bool = optimize == .Debug;

    emcc_command.addArgs(&[_][]const u8{
        "-o",
        emccOutputDir ++ name ++ ".js",
        "zig-out/lib/lib" ++ name ++ ".a",
        "zig-out/lib/libraylib.a",
        "-sGL_ENABLE_GET_PROC_ADDRESS",
        "-sUSE_GLFW=3",

        // Debug behavior
        if (debugging_wasm) "--emit-symbol-map" else "",
        "-sASYNCIFY",
        if (debugging_wasm) "-g4 -00" else "-02",
        if (debugging_wasm) "" else "--closure 1",
        "-sABORTING_MALLOC=" ++ (if (debugging_wasm) "1" else "0"),
        "-sASSERTIONS=" ++ (if (debugging_wasm) "1" else "0"),
        "-sVerbose=" ++ (if (debugging_wasm) "1" else "0"),

        // Export as a ES6 Module for use in svelte
        "-sMODULARIZE",
        "-sEXPORT_ES6",
        "-sEXPORT_NAME=emscriptenModuleFactory",
        "-sHTML5_SUPPORT_DEFERRING_USER_SENSITIVE_REQUESTS=0",
        "-sWASM=1",
        "-DPLATFORM_WEB",
        "-sENVIRONMENT='web'",
        "-sMINIMAL_RUNTIME_STREAMING_WASM_INSTANTIATION=1",
        "-sEXPORTED_FUNCTIONS=['_malloc','_free','_main']",
        "-sEXPORTED_RUNTIME_METHODS=allocateUTF8,UTF8ToString",
        // "--js-library=src/Zig-JS_Bridge.js",

        // Configure memory
        "-sUSE_OFFSET_CONVERTER",
        "-sALLOW_MEMORY_GROWTH=1",
        "-sWASM_MEM_MAX=512MB",
        "-sTOTAL_MEMORY=32MB",
        "-sMALLOC=emmalloc",
        "-sINITIAL_MEMORY=4mb",
        "-sSTACK_SIZE=1mb",
    });
    emcc_command.step.dependOn(&lib.step);

    // Copy output to the svelte import folder
    const writeFiles = b.addWriteFiles();
    _ = writeFiles.addCopyFileToSource(std.Build.LazyPath{
        .path = emccOutputDir ++ name ++ ".js",
    }, b.pathJoin(&[_][]const u8{
        "site",
        "src",
        "import",
        "emscripten.js",
    }));
    _ = writeFiles.addCopyFileToSource(std.Build.LazyPath{
        .path = emccOutputDir ++ name ++ ".wasm",
    }, b.pathJoin(&[_][]const u8{
        "site",
        "static",
        name ++ ".wasm",
    }));
    if (debugging_wasm) {
        _ = writeFiles.addCopyFileToSource(std.Build.LazyPath{
            .path = emccOutputDir ++ name ++ ".js.symbols",
        }, b.pathJoin(&[_][]const u8{
            "site",
            "static",
            name ++ ".js.symbols",
        }));
    }
    writeFiles.step.dependOn(&emcc_command.step);
    b.getInstallStep().dependOn(&writeFiles.step);

    b.getInstallStep().dependOn(&emcc_command.step);

    const run_cmd = b.addSystemCommand(&[_][]const u8{
        "npm",
        "run",
        "dev",
        "--prefix",
        "./site",
    });
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    // This creates a build step. It will be visible in the `zig build --help` menu and can be selected like this: `zig build run`
    const run_step = b.step("run", "Run the app using NPM");
    run_step.dependOn(&run_cmd.step);

    //watch -d -t -g ls -lR ./zig-src | sha1sum

    const publish_cmd = b.addSystemCommand(&[_][]const u8{
        "npm",
        "run",
        "build",
        "--prefix",
        "./site",
    });
    publish_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        publish_cmd.addArgs(args);
    }
    const publish_step = b.step("publish", "Publish the app via NPM");
    publish_step.dependOn(&publish_cmd.step);
}

pub fn build_desktop(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !void {
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .path = "zig-src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // const raylib = try raylib_sdk.addRaylib(b, target, optimize, .{});
    // exe.addIncludePath(.{ .path = "raylib/src" });
    // exe.linkLibrary(raylib);

    // b.installArtifact(exe);

    const raylib = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
    });
    const raylib_artifact = raylib.artifact("raylib");
    exe.addIncludePath(.{ .path = "raylib/src" });
    exe.linkLibrary(raylib_artifact);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    // This creates a build step. It will be visible in the `zig build --help` menu and can be selected like this: `zig build run`
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
