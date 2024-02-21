import type { MiniAudio as IMiniAudio, MiniAudioDevice } from "../types/miniaudio";
import { IPCProxy } from "./IPCProxy";
import { AudioEventType, IPCMessage } from "./IPCMessage";

// Minimum implementation of the DOM needed to make Emscripten run from our web worker
export namespace WorkerDOM {
    let rate: number = 48000;
    export function SetSampleRate(r: number) {
        rate = r;
    }
    let width: number = 1;
    let height: number = 1;
    export function SetSize(w: number, h: number)  {
        width = w;
        height = h;
    }

    export class Window {
        public addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void {
            const id = IPCProxy.Add(listener);
            postMessage(IPCMessage.AddEventHandler({ id, target: 'Window', type }));
        }
        public removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void {
            const id = IPCProxy.Remove(listener);
            postMessage(IPCMessage.RemoveEventHandler({ id, target: 'Window', type }));
        }
        public matchMedia(query: string): MediaQueryList {
            return <any>{
                addEventListener: (type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void => { },
                removeEventListener: (type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void => { },
            };
        }
        public get innerWidth(): number {
            return width;
        }
        public get innerHeight(): number {
            return height;
        }
        public get scrollX(): number {
            return 0;
        }
        public get scrollY(): number {
            return 0;
        }
        public get navigator(): object {
            debugger;
            return {};
        }
        public miniaudio = self.miniaudio;
        public AudioContext = AudioContext;
    }
    export class Document {
        private canvas: IOffscreenCanvasExtended | null;
        constructor(canvas: IOffscreenCanvasExtended | null) {
            this.canvas = canvas;
        }
        public addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void {
            const id = IPCProxy.Add(listener);
            postMessage(IPCMessage.AddEventHandler({ id, target: 'Document', type }));
        }
        public removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void {
            // Skip resize events
            if (type == "resize") return;
            const id = IPCProxy.Remove(listener);
            postMessage(IPCMessage.RemoveEventHandler({ id, target: 'Window', type }));
        }
        public querySelector(selectors: string): HTMLElement | null {
            return <any>this.canvas;
        }
        public getCanvas = () => this.canvas;
        public body = new Body();
    }
    export class Body {
        public get clientWidth(): number {
            return width;
        }
        public get clientHeight(): number {
            return height;
        }
    }

    interface IOffscreenCanvasExtended extends OffscreenCanvas {
        clientWidth: number;
        clientHeight: number;
        getBoundingClientRect: () => {
            x: number;
            y: number;
            width: number;
            height: number;
            top: number;
            bottom: number;
            left: number;
        };
        dispatchEvent(event: Event): boolean;
        addEventListener: (type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions) => void;
        removeEventListener: (type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions) => void;
        height: number;
        oncontextlost: ((this: OffscreenCanvas, ev: Event) => any) | null;
        oncontextrestored: ((this: OffscreenCanvas, ev: Event) => any) | null;
        width: number;
        convertToBlob(options?: ImageEncodeOptions): Promise<Blob>;
        getContext(contextId: "2d", options?: any): OffscreenCanvasRenderingContext2D | null;
        getContext(contextId: "bitmaprenderer", options?: any): ImageBitmapRenderingContext | null;
        getContext(contextId: "webgl", options?: any): WebGLRenderingContext | null;
        getContext(contextId: "webgl2", options?: any): WebGL2RenderingContext | null;
        getContext(contextId: OffscreenRenderingContextId, options?: any): OffscreenRenderingContext | null;
        transferToImageBitmap(): ImageBitmap;
    }
    export class OffscreenCanvasExtended implements IOffscreenCanvasExtended {
        private canvas: OffscreenCanvas;
        constructor(canvas: OffscreenCanvas) {
            this.canvas = canvas;
            
            // Resize handler
            const id = IPCProxy.Add((ev: any) => {
                SetSize(ev.currentTarget.width, ev.currentTarget.height);
                this.canvas.width = ev.currentTarget.width;
                this.canvas.height = ev.currentTarget.height;
                this.canvas.dispatchEvent(new Event("resize"));
                //this.width = ev.currentTarget.width;
                //this.height = ev.currentTarget.height;
            });
            postMessage(IPCMessage.AddEventHandler({ id, target: 'Window', type: "resize" }));
        }
        public get clientWidth(): number {
            return this.canvas.width;
        }
        public get clientHeight(): number {
            return this.canvas.height;
        }
        public getBoundingClientRect: () => {
            x: number;
            y: number;
            width: number;
            height: number;
            top: number;
            bottom: number;
            left: number;
        } = () => {
            return { x: 0, y: 0, width: this.canvas.width, height: this.canvas.height, top: 0, right: this.canvas.width, bottom: this.canvas.height, left: 0 };
        }
        public dispatchEvent(event: Event): boolean {
            return this.canvas.dispatchEvent(event);
        }
        public addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void {
            const id = IPCProxy.Add(listener);
            postMessage(IPCMessage.AddEventHandler({ id, target: 'Canvas', type }));
        }
        public removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void {
            const id = IPCProxy.Remove(listener);
            postMessage(IPCMessage.RemoveEventHandler({ id, target: 'Canvas', type }));
        }
        public set oncontextlost(value: ((this: OffscreenCanvas, ev: Event) => any) | null) {
            this.canvas.oncontextlost = value;
        }
        public get oncontextlost(): ((this: OffscreenCanvas, ev: Event) => any) | null {
            return this.canvas.oncontextlost;
        }
        public set oncontextrestored(value: ((this: OffscreenCanvas, ev: Event) => any) | null) {
            this.canvas.oncontextrestored = value;
        }
        public get oncontextrestored(): ((this: OffscreenCanvas, ev: Event) => any) | null {
            return this.canvas.oncontextrestored;
        }
        public set height(value: number) {
            this.canvas.height = value;
        }
        public get height(): number {
            return this.canvas.height;
        }
        public set width(value: number) {
            this.canvas.width = value;
        }
        public get width(): number {
            return this.canvas.width;
        }
        public convertToBlob(options?: ImageEncodeOptions): Promise<Blob> {
            return this.canvas.convertToBlob(options);
        }
        public getContext(contextId: any, options?: any): any {
            return this.canvas.getContext(contextId, options);
        }
        public transferToImageBitmap(): ImageBitmap {
            return this.canvas.transferToImageBitmap();
        }
    }

    export class MiniAudio implements IMiniAudio {
        public referenceCount: number = 0;
        public device_type: {
            playback: number;
            capture: number;
            duplex: number;
        } = {
                playback: 1,
                capture: 2,
                duplex: 3
            };
        public device_state: {
            stopped: number;
            started: number;
        } = {
                stopped: 1,
                started: 2
            };
        public devices: MiniAudioDevice[] = [];
        public track_device: (device: MiniAudioDevice) => number = (device: MiniAudioDevice) => {
            for (let iDevice = 0; iDevice < this.devices.length; ++iDevice) {
                if (this.devices[iDevice] == null) {
                    this.devices[iDevice] = device;
                    return iDevice;
                }
            }
            this.devices.push(device);
            return this.devices.length - 1;
        };
        public untrack_device_by_index: (deviceIndex: number) => void = (deviceIndex: number) => {
            this.devices[deviceIndex] = <any>null;
            while (this.devices.length > 0) {
                if (this.devices[this.devices.length - 1] == null) {
                    this.devices.pop();
                } else {
                    break;
                }
            }
        };
        public untrack_device: (device: MiniAudioDevice) => void = (device: any) => {
            for (let iDevice = 0; iDevice < this.devices.length; ++iDevice) {
                if (this.devices[iDevice] == device) {
                    return this.untrack_device_by_index(iDevice);
                }
            }
        };
        public get_device_by_index: (deviceIndex: number) => MiniAudioDevice = (deviceIndex: number) => this.devices[deviceIndex];
        public unlock_event_types: string[] = [];
        public unlock(): void {
            
        };
    }
    // Update this to use an AudioWorkletNode
    // https://developer.mozilla.org/en-US/docs/Web/API/BaseAudioContext/createScriptProcessor
    // https://developer.mozilla.org/en-US/docs/Web/API/AudioWorkletNode
    // https://gist.github.com/beaufortfrancois/4d90c89c5371594dc4c0ac81c3b8dd73
    // Or just route this to the main thread...
    class AudioContext {
        public suspend(): Promise<void> {
            return new Promise((resolve, reject) => {
                postMessage(IPCMessage.AudioEvent(AudioEventType.Suspend));
                resolve();
            });
        }
        public resume(): Promise<void> {
            return new Promise((resolve, reject) => {
                postMessage(IPCMessage.AudioEvent(AudioEventType.Resume));
                resolve();
            });
        }
        public close(): Promise<void> {
            return new Promise((resolve, reject) => {
                postMessage(IPCMessage.AudioEvent(AudioEventType.Close));
                resolve();
            });
        }

        public createScriptProcessor(bufferSize?: number, numberOfInputChannels?: number, numberOfOutputChannels?: number) {
            postMessage(IPCMessage.AudioEvent(
                AudioEventType.CreateScriptProcessor,
                {
                    bufferSize: bufferSize,
                    numberOfInputChannels: numberOfInputChannels,
                    numberOfOutputChannels: numberOfOutputChannels
                }
            ));
            return new ScriptProcessorNode();
        }
        public get sampleRate(): number {
            return rate;
        }
    }

    class ScriptProcessorNode {
        public set onaudioprocess(value: ((this: ScriptProcessorNode, ev: AudioProcessingEvent) => any) | null) {
            const funcProxy = IPCProxy.Add(value);
            postMessage(IPCMessage.AudioEvent(
                AudioEventType.StartProcessAudio,
                funcProxy
            ));
        }
        public connect(destinationNode: AudioNode, output?: number, input?: number): AudioNode {
            postMessage(IPCMessage.AudioEvent(AudioEventType.Connect));
            return <any>undefined;
        }
        public disconnect(destinationNode: AudioNode, output?: number, input?: number): AudioNode {
            postMessage(IPCMessage.AudioEvent(AudioEventType.Disconnect));
            return <any>undefined;
        }
    }
};