// This file is injected at the end of the emscripten.js file
// It exposes a few additional functions on the exported Module
Module['instantiateAsync'] = async function(info, receiveInstance) {

    // Override CWD, this allows us to disable the FileSystem whe using raylib
	info.env.__syscall_getcwd = (buf, size) => {
		return "/";
	};

    await instantiateAsync(wasmBinary, wasmBinaryFile, info, (result) => receiveInstance(result['instance']));
}
moduleArg['instantiateAsync'] = Module['instantiateAsync'];
Module['loadSymbols'] = () => getSourceMapPromise().then(receiveSourceMapJSON);
moduleArg['loadSymbols'] = Module['loadSymbols']