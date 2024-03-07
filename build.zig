const std = @import("std");
const builtin = @import("builtin");
const raylib_config = @import("./raylib_config.zig");
const build_assets = @import("./build-assets.zig");
const build_viewlocator = @import("./build-viewlocator.zig");

const name = "dylanlangston.com";

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    //std.Target.wasm.all_features
    const optimize = b.standardOptimizeOption(.{});

    const web_build = target.query.cpu_arch == .wasm32 or target.query.cpu_arch == .wasm64;

    if (web_build) {
        // Set the sysroot folder for emscripten
        b.sysroot = b.pathJoin(&[_][]const u8{
            b.build_root.path.?,
            "emsdk",
            "upstream",
            "emscripten",
        });
    }

    const raylib_artifact = raylib_config.get_configured_raylib(b, target, optimize);

    if (web_build) {
        try build_web(
            b,
            target,
            optimize,
            raylib_artifact,
        );
    } else {
        try build_desktop(
            b,
            target,
            optimize,
            raylib_artifact,
        );
    }

    const exe_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "zig/src/main.zig" },
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

fn configure(b: *std.Build, t: std.Build.ResolvedTarget, o: std.builtin.OptimizeMode, c: *std.Build.Step.Compile, raylib_artifact: *std.Build.Step.Compile) !void {
    const web_build = t.query.cpu_arch == .wasm32 or t.query.cpu_arch == .wasm64;

    const assets = &[_]build_assets.assetType{
        .{ .path = "music", .module_name = "Music", .allowed_exts = &[_][]const u8{".ogg"} },
        .{ .path = "sound", .module_name = "Sounds", .allowed_exts = &[_][]const u8{".ogg"} },
        .{ .path = "font", .module_name = "Fonts", .allowed_exts = &[_][]const u8{".ttf"} },
        .{ .path = "texture", .module_name = "Textures", .allowed_exts = &[_][]const u8{".png"} },
        .{ .path = if (web_build) "shader_fragment/100" else "shader_fragment/330", .module_name = "Fragment_Shaders", .allowed_exts = &[_][]const u8{".fs"} },
        .{ .path = if (web_build) "shader_vertex/100" else "shader_vertex/330", .module_name = "Vertex_Shaders", .allowed_exts = &[_][]const u8{".vs"} },
    };
    try build_assets.addAssets(
        b,
        t,
        o,
        c,
        assets,
    );

    // Views
    try build_viewlocator.importViews(
        "View",
        "ViewModel",
        "ViewLocator",
        b,
        t,
        o,
        c,
    );

    c.addIncludePath(.{ .path = "raylib/src" });
    c.addIncludePath(.{ .path = "raygui/src" });
    c.addIncludePath(.{ .path = "./emsdk/upstream/emscripten/cache/sysroot/include/" });

    c.linkLibrary(raylib_artifact);

    b.installArtifact(c);
    b.installArtifact(raylib_artifact);
}

fn build_web(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, raylib_artifact: *std.Build.Step.Compile) !void {
    const lib = b.addStaticLibrary(.{
        .name = name,
        .root_source_file = .{ .path = "zig/src/main.zig" },
        // Zig building to emscripten doesn't work, because the Zig standard library
        // is missing some things in the C system. "std/c.zig" is missing fd_t,
        // which causes compilation to fail. So build to wasi instead, until it gets
        // fixed.
        // https://github.com/ziglang/zig/issues/16776
        .target = std.Build.resolveTargetQuery(
            b,
            .{
                .cpu_arch = target.query.cpu_arch,
                .cpu_model = target.query.cpu_model,
                .cpu_features_add = target.query.cpu_features_add,
                .cpu_features_sub = target.query.cpu_features_sub,
                .os_tag = .wasi,
                .os_version_min = target.query.os_version_min,
                .os_version_max = target.query.os_version_max,
                .glibc_version = target.query.glibc_version,
                .abi = target.query.abi,
                .dynamic_linker = target.query.dynamic_linker,
                .ofmt = target.query.ofmt,
            },
        ),
        .optimize = optimize,
    });

    try configure(b, target, optimize, lib, raylib_artifact);

    // https://github.com/Not-Nik/raylib-zig/blob/f8735a8cc79db221d3c651c93778cfdb5066818d/build.zig#L267C5-L273C54
    // There are some symbols that need to be defined in C.
    const webhack_c =
        \\// Zig adds '__stack_chk_guard', '__stack_chk_fail', and 'errno',
        \\// which emscripten doesn't actually support.
        \\// Seems that zig ignores disabling stack checking,
        \\// and I honestly don't know why emscripten doesn't have errno.
        \\// TODO: when the updateTargetForWeb workaround gets removed, see if those are nessesary anymore
        \\#include <stdint.h>
        \\uintptr_t __stack_chk_guard;
        \\//I'm not certain if this means buffer overflows won't be detected,
        \\// However, zig is pretty safe from those, so don't worry about it too much.
        \\void __stack_chk_fail(void){}
        \\int errno;
    ;
    const webhack_c_file_step = b.addWriteFiles();
    const webhack_c_file = webhack_c_file_step.add("webhack.c", webhack_c);
    lib.addCSourceFile(.{ .file = webhack_c_file, .flags = &[_][]u8{} });
    // Since it's creating a static library, the symbols raylib uses to webgl
    // and glfw don't need to be linked by emscripten yet.
    lib.step.dependOn(&webhack_c_file_step.step);

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
        "-sUSE_GLFW=3",
        // "-sFULL_ES3=1",
        "-sEXIT_RUNTIME=1",
        "-sFILESYSTEM=0",
        //"-sBUILD_AS_WORKER=1",
        "-sABORT_ON_WASM_EXCEPTIONS=0",
        //"-sASYNCIFY",
        // "-sGL_SUPPORT_EXPLICIT_SWAP_CONTROL=1",
        // "-sGL_ENABLE_GET_PROC_ADDRESS",
        "-sGL_POOL_TEMP_BUFFERS=0",
        "-sGL_SUPPORT_SIMPLE_ENABLE_EXTENSIONS=0",
        "-sGL_SUPPORT_AUTOMATIC_ENABLE_EXTENSIONS=0",
        "-sGL_UNSAFE_OPTS=1",
        // "-sGL_EXTENSIONS_IN_PREFIXED_FORMAT=1",
        "-sMIN_WEBGL_VERSION=2",
        if (debugging_wasm) "" else "-flto", // Link-time optimization

        // Debug behavior
        if (debugging_wasm) "--emit-symbol-map" else "",
        if (debugging_wasm) "-g4 -00" else "-02",
        if (debugging_wasm) "" else "--closure 1",
        "-sABORTING_MALLOC=" ++ (if (debugging_wasm) "1" else "0"),
        "-sASSERTIONS=" ++ (if (debugging_wasm) "1" else "0"),
        "-sVerbose=" ++ (if (debugging_wasm) "1" else "0"),
        "-sWEBAUDIO_DEBUG=" ++ (if (debugging_wasm) "1" else "0"),
        "-sGL_TRACK_ERRORS=" ++ (if (debugging_wasm) "1" else "0"),
        if (debugging_wasm) "-gsource-map" else "",
        if (debugging_wasm) "-sLOAD_SOURCE_MAP=1" else "",
        //if (debugging_wasm) "-sGL_TRACK_ERRORS=1" else "-sGL_TRACK_ERRORS=0",
        // if (debugging_wasm) "-sRUNTIME_DEBUG=1" else "",
        if (debugging_wasm) "" else "-fno-exceptions",
        if (debugging_wasm) "" else "-sDISABLE_EXCEPTION_THROWING",

        // Ports
        //if (debugging_wasm) "--use-port=contrib.glfw3:disableWarning=false:disableMultiWindow=true" else "--use-port=contrib.glfw3:disableWarning=true:disableMultiWindow=true", // https://github.com/pongasoft/emscripten-glfw

        // Export as a ES6 Module for use in svelte
        "-sMODULARIZE",
        "-sEXPORT_ES6",
        // "-SUSE_ES6_IMPORT_META=1",
        "-sTRUSTED_TYPES=1",
        "-sEXPORT_NAME=emscriptenModuleFactory",
        "-sHTML5_SUPPORT_DEFERRING_USER_SENSITIVE_REQUESTS=0",
        "-sWASM=1",
        "-DPLATFORM_WEB",
        "-sENVIRONMENT=worker",
        "-sDEFAULT_LIBRARY_FUNCS_TO_INCLUDE=[]",
        "-sEXPORTED_FUNCTIONS=['_malloc','_free','_main']",
        if (debugging_wasm)
            "-sEXPORTED_RUNTIME_METHODS=stringToNewUTF8,UTF8ToString,abort,WasmOffsetConverter"
        else
            "-sEXPORTED_RUNTIME_METHODS=stringToNewUTF8,UTF8ToString,abort",
        "-sINCOMING_MODULE_JS_API=['setStatus','printErr','print','onAbort','instantiateWasm','locateFile','onRuntimeInitialized','canvas','elementPointerLock','requestFullscreen']",
        "-sDYNAMIC_EXECUTION=0",
        "-sWASM_BIGINT=1",
        "-sHTML5_SUPPORT_DEFERRING_USER_SENSITIVE_REQUESTS=0",
        // "--js-library=src/Zig-JS_Bridge.js",
        "--pre-js=site/emscripten_pre.js",
        "--post-js=site/emscripten_post.js",

        // Configure memory
        if (debugging_wasm or optimize == .ReleaseSafe) "-sUSE_OFFSET_CONVERTER" else "",
        //"-sALLOW_MEMORY_GROWTH=1",
        "-sWASM_MEM_MAX=512MB",
        "-sTOTAL_MEMORY=32MB",
        if (debugging_wasm) "-sMALLOC=emmalloc-memvalidate" else "-sMALLOC=emmalloc",
        "-sINITIAL_MEMORY=4mb",
        "-sSTACK_SIZE=1mb",
        if (target.query.cpu_arch == .wasm64) "-sMEMORY64=1" else "",

        // Threading
        //"-pthread",
        //"-sPTHREAD_POOL_SIZE=4",
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
            .path = emccOutputDir ++ name ++ ".wasm.map",
        }, b.pathJoin(&[_][]const u8{
            "site",
            "static",
            name ++ ".wasm.map",
        }));
        _ = writeFiles.addCopyFileToSource(std.Build.LazyPath{
            .path = emccOutputDir ++ name ++ ".js.symbols",
        }, b.pathJoin(&[_][]const u8{
            "site",
            "src",
            "import",
            "emscripten.js.symbols",
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

fn build_desktop(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, raylib_artifact: *std.Build.Step.Compile) !void {
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .path = "zig/src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    try configure(b, target, optimize, exe, raylib_artifact);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    // This creates a build step. It will be visible in the `zig build --help` menu and can be selected like this: `zig build run`
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
