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

	onAbort: { (what: any): void };

	// forcedAspectRatio: number;
	elementPointerLock: boolean;
	statusMessage: string;
	setStatus(e: string): void;

	onRuntimeInitialized: { (): void };

	print(str: string): void;
	printErr(str: string): void;

	locateFile(url: string, scriptDirectory: string): string;

	instantiateWasm?(
		imports: WebAssembly.Imports,
		successCallback: (module: WebAssembly.Instance) => void
	): WebAssembly.Exports;
}

class CustomEmscriptenModule implements ICustomEmscriptenModule {
	public instantiateWasm = Environment.Dev ? undefined : (
		imports: WebAssembly.Imports,
		successCallback: (module: WebAssembly.Instance) => void
	): WebAssembly.Exports => {
		fetch('/dylanlangston.com.wasm', { credentials: 'same-origin', cache: 'default' }).then((response) => {
			// Override CWD
			imports.env.__syscall_getcwd = (buf: any, size: any) => {
				return -28;
			};

			var result = WebAssembly.instantiateStreaming(response, imports);
			var clonedResponsePromise = response.clone().arrayBuffer();

			return result.then((instantiationResult) => {

				clonedResponsePromise.then((arrayBufferResult) => {
					successCallback(instantiationResult.instance);
				}, (err) => this.printErr(`failed to initialize offset-converter: ${err}`));
			}, (err) => this.printErr(`wasm streaming compile failed: ${err}`));
		});

		return {};
	}

	requestFullscreen?: (lockPointer: boolean, resizeCanvas: boolean) => void;

	elementPointerLock: boolean = false;

	public canvas: HTMLCanvasElement | OffscreenCanvas;
	constructor(canvas: HTMLCanvasElement | OffscreenCanvas) {
		this.canvas = canvas;
	}
	public onAbort(what: any): void {
		//throw(new WebAssembly.RuntimeError(what));
	}

	public onRuntimeInitialized(): void {
	}

	public locateFile = (url: string, scriptDirectory: string): string => {
		if (Environment.Dev) {
			return "/" + url;
		}

		const path = new URL(scriptDirectory).pathname.split("_")[0];
		const file = path + url;
		return file;
	}

	public print = (t: string): void => {
		globalThis.console.log(t);
	}

	public printErr = (text: string): void => {
		globalThis.console.error(text);
	}

	public get statusMessage(): string {
		return get(CustomEmscriptenModule.statusMessage);
	}
	public setStatus = (e: string): void => {
		CustomEmscriptenModule.setStatus(e);
	}

	public static readonly statusMessage = writable('⏳');
	public static setStatus(e: string): void {
		if (e == '') return;
		CustomEmscriptenModule.statusMessage.set(e);

		console.log(e);
	}
}