import { writable, get } from 'svelte/store';
import emscriptenModuleFactory from '$import/emscripten';
import { Environment } from '$lib/Common';

export const EmscriptenModule: (canvas: HTMLCanvasElement | OffscreenCanvas) =>
	ICustomEmscriptenModule = (canvas: HTMLCanvasElement | OffscreenCanvas) => new CustomEmscriptenModule(canvas);
export const EmscriptenModuleFactory = emscriptenModuleFactory as EmscriptenModuleFactory<IEmscripten>;
export function EmscriptenInitialize(canvas: HTMLCanvasElement | OffscreenCanvas): Promise<IEmscripten> {
	return EmscriptenModuleFactory(EmscriptenModule(canvas));
}

export interface IEmscripten extends CustomEmscriptenModule, EmscriptenModule {

}

interface ICustomEmscriptenModule {
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

	instantiateWasm?: (
		imports: WebAssembly.Imports,
		successCallback: (module: WebAssembly.Instance) => void
	) => WebAssembly.Exports;
}

class CustomEmscriptenModule implements ICustomEmscriptenModule {
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