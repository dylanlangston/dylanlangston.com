const std = @import("std");
const builtin = @import("builtin");
const raylib_build = @import("raylib");

const raylibStandardOptions = .{
    .raudio = true,
    .rmodels = false,
    .rshapes = true,
    .rtext = true,
    .rtextures = true,
    .raygui = false,
    .platform_drm = false,
    .shared = false,
};

fn define_macros(raylib_module: *std.Build.Module) void {
    // Don't use the built in config.h
    raylib_module.addCMacro("EXTERNAL_CONFIG_FLAGS", "1");

    //------------------------------------------------------------------------------------
    // Module selection - Some modules could be avoided
    // Mandatory modules: rcore, rlgl, utils
    //------------------------------------------------------------------------------------
    raylib_module.addCMacro("SUPPORT_MODULE_RSHAPES", "1");
    raylib_module.addCMacro("SUPPORT_MODULE_RTEXTURES", "1");
    raylib_module.addCMacro("SUPPORT_MODULE_RTEXT", "1");
    //raylib_module.addCMacro("SUPPORT_MODULE_RMODELS", "1");
    raylib_module.addCMacro("SUPPORT_MODULE_RAUDIO", "1");

    //------------------------------------------------------------------------------------
    // Module: rcore - Configuration Flags
    //------------------------------------------------------------------------------------
    // Camera module is included (rcamera.h) and multiple predefined cameras are available: free,","1");st/3rd person, orbital
    raylib_module.addCMacro("SUPPORT_CAMERA_SYSTEM", "1");
    // Gestures module is included (rgestures.h) to support gestures detection: tap, hold, swipe, drag
    //raylib_module.addCMacro("SUPPORT_GESTURES_SYSTEM", "1");
    // Include pseudo-random numbers generator (rprand.h), based on Xoshiro128** and SplitMix64
    //raylib_module.addCMacro("SUPPORT_RPRAND_GENERATOR", "1");
    // Mouse gestures are directly mapped like touches and processed by gestures system
    raylib_module.addCMacro("SUPPORT_MOUSE_GESTURES", "1");
    // Reconfigure standard input to receive key inputs, works with SSH connection.
    //raylib_module.addCMacro("SUPPORT_SSH_KEYBOARD_RPI", "1");
    // Setting a higher resolution can improve the accuracy of time-out intervals in wait functions.
    // However, it can also reduce overall system performance, because the thread scheduler switches tasks more often.
    //raylib_module.addCMacro("SUPPORT_WINMM_HIGHRES_TIMER", "1");
    // Use busy wait loop for timing sync, if not defined, a high-resolution timer is set up and used
    //raylib_module.addCMacro("SUPPORT_BUSY_WAIT_LOOP","1");
    // Use a partial-busy wait loop, in this case frame sleeps for most of the time, but then runs a busy loop at the end for accuracy
    raylib_module.addCMacro("SUPPORT_PARTIALBUSY_WAIT_LOOP", "1");
    // Allow automatic screen capture of current screen pressing F12, defined in KeyCallback()
    //raylib_module.addCMacro("SUPPORT_SCREEN_CAPTURE", "1");
    // Allow automatic gif recording of current screen pressing CTRL+F12, defined in KeyCallback()
    //raylib_module.addCMacro("SUPPORT_GIF_RECORDING", "1");
    // Support CompressData() and DecompressData() functions
    //raylib_module.addCMacro("SUPPORT_COMPRESSION_API", "1");
    // Support automatic generated events, loading and recording of those events when required
    //raylib_module.addCMacro("SUPPORT_AUTOMATION_EVENTS", "1");
    // Support custom frame control, only for advance users
    // By default EndDrawing() does this job: draws everything + SwapScreenBuffer() + manage frame timing + PollInputEvents()
    // Enabling this flag allows manual control of the frame processes, use at your own risk
    //raylib_module.addCMacro("SUPPORT_CUSTOM_FRAME_CONTROL","1");

    // rcore: Configuration values
    //------------------------------------------------------------------------------------
    //raylib_module.addCMacro("MAX_FILEPATH_CAPACITY", "8192"); // Maximum file paths capacity
    //raylib_module.addCMacro("MAX_FILEPATH_LENGTH", "4096"); // Maximum length for filepaths (Linux PATH_MAX default value)

    raylib_module.addCMacro("MAX_KEYBOARD_KEYS", "512"); // Maximum number of keyboard keys supported
    raylib_module.addCMacro("MAX_MOUSE_BUTTONS", "8"); // Maximum number of mouse buttons supported
    raylib_module.addCMacro("MAX_GAMEPADS", "4"); // Maximum number of gamepads supported
    raylib_module.addCMacro("MAX_GAMEPAD_AXIS", "8"); // Maximum number of axis supported (per gamepad)
    raylib_module.addCMacro("MAX_GAMEPAD_BUTTONS", "32"); // Maximum number of buttons supported (per gamepad)
    raylib_module.addCMacro("MAX_TOUCH_POINTS", "8"); // Maximum number of touch points supported
    raylib_module.addCMacro("MAX_KEY_PRESSED_QUEUE", "16"); // Maximum number of keys in the key input queue
    raylib_module.addCMacro("MAX_CHAR_PRESSED_QUEUE", "16"); // Maximum number of characters in the char input queue

    //raylib_module.addCMacro("MAX_DECOMPRESSION_SIZE", "64"); // Max size allocated for decompression in MB

    //raylib_module.addCMacro("MAX_AUTOMATION_EVENTS", "16384"); // Maximum number of automation events to record

    //------------------------------------------------------------------------------------
    // Module: rlgl - Configuration values
    //------------------------------------------------------------------------------------

    // Enable OpenGL Debug Context (only available on OpenGL","4");.3)
    //raylib_module.addCMacro("RLGL_ENABLE_OPENGL_DEBUG_CONTEXT","1");

    // Show OpenGL extensions and capabilities detailed logs on init
    //raylib_module.addCMacro("RLGL_SHOW_GL_DETAILS_INFO","1");

    //raylib_module.addCMacro("RL_DEFAULT_BATCH_BUFFER_ELEMENTS","4096");    // Default internal render batch elements limits
    raylib_module.addCMacro("RL_DEFAULT_BATCH_BUFFERS", "1"); // Default number of batch buffers (multi-buffering)
    raylib_module.addCMacro("RL_DEFAULT_BATCH_DRAWCALLS", "256"); // Default number of batch draw calls (by state changes: mode, texture)
    raylib_module.addCMacro("RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS", "4"); // Maximum number of textures units that can be activated on batch drawing (SetShaderValueTexture())

    raylib_module.addCMacro("RL_MAX_MATRIX_STACK_SIZE", "32"); // Maximum size of internal Matrix stack

    raylib_module.addCMacro("RL_MAX_SHADER_LOCATIONS", "32"); // Maximum number of shader locations supported

    raylib_module.addCMacro("RL_CULL_DISTANCE_NEAR", "0.01"); // Default projection matrix near cull distance
    raylib_module.addCMacro("RL_CULL_DISTANCE_FAR", "1000.0 "); // Default projection matrix far cull distance

    // Default shader vertex attribute names to set location points
    // NOTE: When a new shader is loaded, the following locations are tried to be set for convenience
    raylib_module.addCMacro("RL_DEFAULT_SHADER_ATTRIB_NAME_POSITION", "\"vertexPosition\""); // Bound by default to shader location:","0");
    raylib_module.addCMacro("RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD", "\"vertexTexCoord\""); // Bound by default to shader location:","1");
    raylib_module.addCMacro("RL_DEFAULT_SHADER_ATTRIB_NAME_NORMAL", "\"vertexNormal\""); // Bound by default to shader location:","2");
    raylib_module.addCMacro("RL_DEFAULT_SHADER_ATTRIB_NAME_COLOR", "\"vertexColor\""); // Bound by default to shader location:","3");
    raylib_module.addCMacro("RL_DEFAULT_SHADER_ATTRIB_NAME_TANGENT", "\"vertexTangent\""); // Bound by default to shader location:","4");
    raylib_module.addCMacro("RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD2", "\"vertexTexCoord2\""); // Bound by default to shader location:","5");

    raylib_module.addCMacro("RL_DEFAULT_SHADER_UNIFORM_NAME_MVP", "\"mvp\""); // model-view-projection matrix
    raylib_module.addCMacro("RL_DEFAULT_SHADER_UNIFORM_NAME_VIEW", "\"matView\""); // view matrix
    raylib_module.addCMacro("RL_DEFAULT_SHADER_UNIFORM_NAME_PROJECTION", "\"matProjection\""); // projection matrix
    raylib_module.addCMacro("RL_DEFAULT_SHADER_UNIFORM_NAME_MODEL", "\"matModel\""); // model matrix
    raylib_module.addCMacro("RL_DEFAULT_SHADER_UNIFORM_NAME_NORMAL", "\"matNormal\""); // normal matrix (transpose(inverse(matModelView))
    raylib_module.addCMacro("RL_DEFAULT_SHADER_UNIFORM_NAME_COLOR", "\"colDiffuse\""); // color diffuse (base tint color, multiplied by texture color)
    raylib_module.addCMacro("RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE0", "\"texture0\""); // texture0 (texture slot active","0");)
    raylib_module.addCMacro("RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE1", "\"texture1\""); // texture1 (texture slot active","1");)
    raylib_module.addCMacro("RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE2", "\"texture2\""); // texture2 (texture slot active","2");)

    //------------------------------------------------------------------------------------
    // Module: rshapes - Configuration Flags
    //------------------------------------------------------------------------------------
    // Use QUADS instead of TRIANGLES for drawing when possible
    // Some lines-based shapes could still use lines
    raylib_module.addCMacro("SUPPORT_QUADS_DRAW_MODE", "1");

    // rshapes: Configuration values
    //------------------------------------------------------------------------------------
    raylib_module.addCMacro("SPLINE_SEGMENT_DIVISIONS", "24"); // Spline segments subdivisions

    //------------------------------------------------------------------------------------
    // Module: rtextures - Configuration Flags
    //------------------------------------------------------------------------------------
    // Selecte desired fileformats to be supported for image data loading
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_PNG", "1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_BMP","1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_TGA","1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_JPG","1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_GIF", "1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_QOI", "1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_PSD","1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_DDS", "1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_HDR","1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_PIC","1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_KTX","1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_ASTC","1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_PKM","1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_PVR","1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_SVG","1");

    // Support image export functionality (.png, .bmp, .tga, .jpg, .qoi)
    //raylib_module.addCMacro("SUPPORT_IMAGE_EXPORT", "1");
    // Support procedural image generation functionality (gradient, spot, perlin-noise, cellular)
    //raylib_module.addCMacro("SUPPORT_IMAGE_GENERATION", "1");
    // Support multiple image editing functions to scale, adjust colors, flip, draw on images, crop...
    // If not defined, still some functions are supported: ImageFormat(), ImageCrop(), ImageToPOT()
    //raylib_module.addCMacro("SUPPORT_IMAGE_MANIPULATION", "1");

    //------------------------------------------------------------------------------------
    // Module: rtext - Configuration Flags
    //------------------------------------------------------------------------------------
    // Default font is loaded on window initialization to be available for the user to render simple text
    // NOTE: If enabled, uses external module functions to load default raylib font
    if (builtin.mode == .Debug) raylib_module.addCMacro("SUPPORT_DEFAULT_FONT", "1");
    // Selected desired font fileformats to be supported for loading
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_FNT", "1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_TTF", "1");

    // Support text management functions
    // If not defined, still some functions are supported: TextLength(), TextFormat()
    raylib_module.addCMacro("SUPPORT_TEXT_MANIPULATION", "1");

    // On font atlas image generation [GenImageFontAtlas()], add a","3");x3 pixels white rectangle
    // at the bottom-right corner of the atlas. It can be useful to for shapes drawing, to allow
    // drawing text and shapes with a single draw call [SetShapesTexture()].
    //raylib_module.addCMacro("SUPPORT_FONT_ATLAS_WHITE_REC", "1");

    // rtext: Configuration values
    //------------------------------------------------------------------------------------
    //raylib_module.addCMacro("MAX_TEXT_BUFFER_LENGTH", "1024"); // Size of internal static buffers used on some functions:
    // TextFormat(), TextSubtext(), TextToUpper(), TextToLower(), TextToPascal(), TextSplit()
    //raylib_module.addCMacro("MAX_TEXTSPLIT_COUNT", "128"); // Maximum number of substrings to split: TextSplit()

    //------------------------------------------------------------------------------------
    // Module: rmodels - Configuration Flags
    //------------------------------------------------------------------------------------
    // Selected desired model fileformats to be supported for loading
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_OBJ", "1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_MTL", "1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_IQM", "1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_GLTF", "1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_VOX", "1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_M3D", "1");
    // Support procedural mesh generation functions, uses external par_shapes.h library
    // NOTE: Some generated meshes DO NOT include generated texture coordinates
    //raylib_module.addCMacro("SUPPORT_MESH_GENERATION", "1");

    // rmodels: Configuration values
    //------------------------------------------------------------------------------------
    //raylib_module.addCMacro("MAX_MATERIAL_MAPS", "12"); // Maximum number of shader maps supported
    //raylib_module.addCMacro("MAX_MESH_VERTEX_BUFFERS", "7"); // Maximum vertex buffers (VBO) per mesh

    //------------------------------------------------------------------------------------
    // Module: raudio - Configuration Flags
    //------------------------------------------------------------------------------------
    // Desired audio fileformats to be supported for loading
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_WAV", "1");
    raylib_module.addCMacro("SUPPORT_FILEFORMAT_OGG", "1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_MP3", "1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_QOA", "1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_FLAC","1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_XM", "1");
    //raylib_module.addCMacro("SUPPORT_FILEFORMAT_MOD", "1");

    // raudio: Configuration values
    //------------------------------------------------------------------------------------
    raylib_module.addCMacro("AUDIO_DEVICE_FORMAT", "ma_format_f32"); // Device output format (miniaudio: float-32bit)
    raylib_module.addCMacro("AUDIO_DEVICE_CHANNELS", "2"); // Device output channels: stereo
    raylib_module.addCMacro("AUDIO_DEVICE_SAMPLE_RATE", "0"); // Device sample rate (device default)

    raylib_module.addCMacro("MAX_AUDIO_BUFFER_POOL_CHANNELS", "16"); // Maximum number of audio pool channels

    //------------------------------------------------------------------------------------
    // Module: utils - Configuration Flags
    //------------------------------------------------------------------------------------
    // Standard file io library (stdio.h) included
    //raylib_module.addCMacro("SUPPORT_STANDARD_FILEIO", "1");
    // Show TRACELOG() output messages
    // NOTE: By default LOG_DEBUG traces not shown
    if (builtin.mode == .Debug) {
        raylib_module.addCMacro("SUPPORT_TRACELOG", "1");
        raylib_module.addCMacro("SUPPORT_TRACELOG_DEBUG", "1");
    }

    // utils: Configuration values
    //------------------------------------------------------------------------------------
    raylib_module.addCMacro("MAX_TRACELOG_MSG_LENGTH", "1"); // Max length of one trace-log message

    // Redefine allocators
    raylib_module.addCMacro("RL_MALLOC(sz)", "malloc(sz)");
    raylib_module.addCMacro("RL_CALLOC(n,sz)", "calloc(n,sz)");
    raylib_module.addCMacro("RL_REALLOC(ptr,sz)", "realloc(ptr,sz)");
    raylib_module.addCMacro("RL_FREE(ptr)", "free(ptr)");
}

pub fn get_configured_raylib(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Step.Compile {
    const raylib = try raylib_build.addRaylib(b, target, optimize, .{
        .raudio = raylibStandardOptions.raudio,
        .rmodels = raylibStandardOptions.rmodels,
        .rshapes = raylibStandardOptions.rshapes,
        .rtext = raylibStandardOptions.rtext,
        .rtextures = raylibStandardOptions.rtextures,
        .raygui = raylibStandardOptions.raygui,
        .platform_drm = raylibStandardOptions.platform_drm,
        .shared = raylibStandardOptions.shared,
    });

    define_macros(&raylib.root_module);

    return raylib;
}
