// This file is injected at the start of the emscripten.js file
// It exposes additional functions on the exported Module
const baseGetWasmImports = getWasmImports;
getWasmImports = () => {
    const wasmModules = baseGetWasmImports();
     // Override CWD, this allows us to disable the FileSystem when using raylib
    wasmModules.env.__syscall_getcwd = (buf, size) => {
        return "/";
    };
    return wasmModules
}