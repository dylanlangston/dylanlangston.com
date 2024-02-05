import { writable, get } from 'svelte/store';
import emscriptenModuleFactory from '../import/emscripten';
import { Environment } from './Common';

export const EmscriptenModule: (canvas: HTMLCanvasElement | OffscreenCanvas) =>
	ICustomEmscriptenModule = (canvas: HTMLCanvasElement | OffscreenCanvas) => new CustomEmscriptenModule(canvas);
export const EmscriptenModuleFactory: EmscriptenModuleFactory<IEmscripten> = emscriptenModuleFactory;
export function EmscriptenInitialize(canvas: HTMLCanvasElement | OffscreenCanvas): Promise<IEmscripten> {
	return EmscriptenModuleFactory(EmscriptenModule(canvas));
}

export interface IEmscripten extends CustomEmscriptenModule, EmscriptenModule {

}

interface ICustomEmscriptenModule {
	requestFullscreen?: (lockPointer: boolean, resizeCanvas: boolean) => void;
	onFullScreen?: (fullscreen: boolean) => void;

	// forcedAspectRatio: number;
	elementPointerLock: boolean;
	statusMessage: string;
	setStatus(e: string): void;

	onRuntimeInitialized: { (): void };

	print(str: string): void;
	printErr(str: string): void;

	locateFile(url: string, scriptDirectory: string): string;

	instantiateWasm?: (
		imports: WebAssembly.Imports,
		successCallback: (module: WebAssembly.Instance) => void
	) => WebAssembly.Exports;
}

class CustomEmscriptenModule implements ICustomEmscriptenModule {
	requestFullscreen?: (lockPointer: boolean, resizeCanvas: boolean) => void;

	elementPointerLock: boolean = false;

	public canvas: HTMLCanvasElement | OffscreenCanvas;
	constructor(canvas: HTMLCanvasElement | OffscreenCanvas) {
		this.canvas = canvas;
	}

	private static wasmBinaryFile: string = new URL('/static/dylanlangston.com.wasm', import.meta.url).href;

	public onRuntimeInitialized(): void {
	}

	public instantiateWasm(
		imports: WebAssembly.Imports,
		successCallback: (module: WebAssembly.Instance) => void
	): WebAssembly.Exports {
		WebAssembly.instantiateStreaming(fetch(CustomEmscriptenModule.wasmBinaryFile, {
			cache: 'default'
		}), imports).then((output) => {
			if (Environment.Dev) console.log('wasm instantiation succeeded');
			successCallback(output.instance);
		})
			.catch((e) => {
				if (Environment.Dev) console.error('wasm instantiation failed! ' + e);
				this.setStatus('wasm instantiation failed! ' + e);
			});

		return {};
	}

	public print(t: string): void {
		globalThis.console.log(t);
	}

	public printErr(text: string): void {
		text = Array.prototype.slice.call(arguments).join(' ');
		globalThis.console.error(text);
	}


	public get statusMessage(): string {
		return get(CustomEmscriptenModule.statusMessage);
	}
	public setStatus(e: string): void {
		CustomEmscriptenModule.setStatus(e);
	}

	public static readonly statusMessage = writable('⏳');
	public static setStatus(e: string): void {
		if (e == 'Running...' || e == '') {
			return;
		}
		CustomEmscriptenModule.statusMessage.set(e);
		console.log(e);
	}
}