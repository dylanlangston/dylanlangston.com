import { writable, get } from 'svelte/store';
import emscriptenModuleFactory from '../import/emscripten';

export const EmscriptenModuleFactory: EmscriptenModuleFactory<IEmscripten> = emscriptenModuleFactory;
export function EmscriptenInitialize(canvas: HTMLCanvasElement | OffscreenCanvas): Promise<IEmscripten> {
	return EmscriptenModuleFactory(EmscriptenModule(canvas));
}

export interface IEmscripten extends CustomEmscriptenModule, EmscriptenModule {

}

interface ICustomEmscriptenModule {
	requestFullscreen?: (lockPointer: boolean, resizeCanvas: boolean) => void;

	elementPointerLock: boolean;
	statusMessage: string;
	setStatus(e: string): void;

	onRuntimeInitialized: { (): void };

	print(str: string): void;
	printErr(str: string): void;

	instantiateWasm(
		imports: WebAssembly.Imports,
		successCallback: (module: WebAssembly.Instance) => void
	): WebAssembly.Exports;
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
			console.log('wasm instantiation succeeded');
			successCallback(output.instance);
		})
			.catch((e) => {
				console.log('wasm instantiation failed! ' + e);
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
		// "Running..." is from emscripten.js and isn't localized so just return"
		if (e == 'Running...') {
			return;
		}
		CustomEmscriptenModule.statusMessage.set(e);
		console.log(e);
	}
}

export const EmscriptenModule: (canvas: HTMLCanvasElement | OffscreenCanvas) =>
	ICustomEmscriptenModule = (canvas: HTMLCanvasElement | OffscreenCanvas) => new CustomEmscriptenModule(canvas);

export enum IPCMessageType {
	Initialize,
	Initialized,
}

export class IPCMessage {
	public static Initialize(canvas: OffscreenCanvas) {
		const message = new IPCMessage(IPCMessageType.Initialize);
		message.canvas = canvas;
		return message;
	}
	public static Initialized() {
		const message = new IPCMessage(IPCMessageType.Initialized);
		return message;
	}

	private constructor(type: IPCMessageType) {
		this.type = type;
	}
	public type: IPCMessageType;
	public canvas: OffscreenCanvas | undefined;
}