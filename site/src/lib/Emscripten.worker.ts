import { type IEmscripten, EmscriptenModule } from '$lib/Emscripten';
import { IPCMessage, IPCMessageType, type IPCMessageDataType } from '$lib/IPCMessage';
import emscriptenModuleFactory from '../import/emscripten';
import { Environment } from "$lib/Common";
import type { MiniAudioDevice } from '../types/miniaudio';

// Define all events here
// The rest of this file should be boilerplate code...
let eventHandlers: { [type: number]: (message: IPCMessageDataType) => void; } = {};
// On Initialized
eventHandlers[IPCMessageType.Initialize] = (message: IPCMessageDataType) => {
    self.document = new FakeDOM.Document(<any>message);

    // This needs to match the width of the canvas
    const width = 800;
    const height = 450;

    const canvas: OffscreenCanvasExtended = <any>message;
    canvas.clientWidth = width;
    canvas.clientHeight = height;
    canvas.addEventListener = (type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void => {
        const id = FunctionProxy.Add(listener);
        postMessage(IPCMessage.AddEventHandler({ id, target: 'Canvas', type }));
    };
    canvas.getBoundingClientRect = () => {
        return { x: 0, y: 0, width: width, height: height, top: 0, right: width, bottom: height, left: 0 };
    }

    (<EmscriptenModuleFactory<IEmscripten>>emscriptenModuleFactory)(EmscriptenModule(canvas)).then(emscripten => {
        postMessage(IPCMessage.Initialized())
    })
};
// Event Handler Callback
eventHandlers[IPCMessageType.EventHandlerCallback] = (message) => {
    let eventHandler: {
        id: number;
        type: string;
        event: any;
    } = <any>message;
    if (eventHandler.event.changedTouches) {
        eventHandler.event.changedTouches = Array.from(eventHandler.event.changedTouches);
    }
    eventHandler.event.preventDefault = () => { };
    eventHandler.event.target = self.document.getCanvas();
    if (Environment.Dev) console.debug(eventHandler);
    const func = FunctionProxy.Get(eventHandler.id);
    func(eventHandler.event);
};

interface OffscreenCanvasExtended extends OffscreenCanvas {
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
}

class FunctionProxy {
    private static index: number = 0;
    private static functions: { [type: number]: any } = {};
    public static Add(f: any): number {
        const currentIndex = this.index;
        this.index += 1;

        this.functions[currentIndex] = f;

        return currentIndex;
    }
    public static Get = (n: number) => this.functions[n];
}

// Minimum implementation of the DOM needed to make Emscripten run from our web worker
namespace FakeDOM {
    export class Window {
        public addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void {
            // Skip resize events
            if (type == "resize") return;
            const id = FunctionProxy.Add(listener);
            postMessage(IPCMessage.AddEventHandler({ id, target: 'Window', type }));
        }
        public matchMedia(query: string): MediaQueryList {
            return <any>{
                addEventListener: (type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void => { }
            };
        }
        public get scrollX(): number {
            return 0;
        }
        public get scrollY(): number {
            return 0;
        }
        public miniaudio = self.miniaudio;
        public AudioContext = AudioContext;
    }
    export class Document {
        private canvas: HTMLElement | null;
        constructor(canvas: HTMLElement | null) {
            this.canvas = canvas;
        }
        addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void {
            const id = FunctionProxy.Add(listener);
            postMessage(IPCMessage.AddEventHandler({ id, target: 'Document', type }));
        }
        querySelector(selectors: string): HTMLElement | null {
            return this.canvas;
        }
        getCanvas = () => this.canvas;
    }

    export class MiniAudio implements MiniAudio {
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
        public devices: (MiniAudioDevice | null)[] = [];
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
            this.devices[deviceIndex] = null;
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
        public get_device_by_index: (deviceIndex: number) => (MiniAudioDevice | null) = (deviceIndex: number) => this.devices[deviceIndex];
        public unlock_event_types: string[] = ['touchend', 'click'];
        public unlock(): void {
            for (let i = 0; i < this.devices.length; ++i) {
                const device = this.devices[i];
                if (device != null && device.webaudio != null && device?.state === this.device_state.started) {
                    device.webaudio.resume().then(() => {
                        Module._ma_device__on_notification_unlocked(device.pDevice);
                    }, (error: any) => {
                        console.error("Failed to resume audiocontext", error);
                    });
                }
            }
            this.unlock_event_types.map((event_type) => document.removeEventListener(event_type, this.unlock, true));
        };
    }
    // Update this to use an AudioWorkletNode
    // https://developer.mozilla.org/en-US/docs/Web/API/BaseAudioContext/createScriptProcessor
    // https://developer.mozilla.org/en-US/docs/Web/API/AudioWorkletNode
    // https://gist.github.com/beaufortfrancois/4d90c89c5371594dc4c0ac81c3b8dd73
    // Or just route this to the main thread...
    class AudioContext {
        public suspend(): Promise<void> {
            return new Promise((resolve, reject) => resolve());
        }
        public resume(): Promise<void> {
            return new Promise((resolve, reject) => resolve());
        }
        public createScriptProcessor(a1: any, a2: any, a3: any) {
            return {
                connect: (args: any) => {
                    console.log("Script Processor Connected");
                    console.log(args);
                },
            };
        }
        // public createMediaStreamSource(arg: any) {
        //     console.log(arg);
        // }
        public destination: any = {};
        public onaudioprocess: any = undefined;
    }
};

// Event Handler for all Worker Messages
class WorkerMessageEventHandler extends EventTarget {
    constructor() {
        super()
        for (let [key, value] of Object.entries(eventHandlers)) {
            this.addEventListener(IPCMessageType[parseInt(key)], (event: any) => {
                const customEvent: CustomEvent<IPCMessageDataType> = event;
                value(customEvent.detail);
            });
        }
    }
    public OnMessage = (type: IPCMessageType, message: IPCMessageDataType) => this.dispatchEvent(new CustomEvent<IPCMessageDataType>(IPCMessageType[type], { detail: message }));
}
const MessageHandler = new WorkerMessageEventHandler();

// Worker TypeScript Def and boilerplate
interface IEmscriptenWorker extends DedicatedWorkerGlobalScope {
    window: FakeDOM.Window;
    document: FakeDOM.Document;
    miniaudio: FakeDOM.MiniAudio;
}
declare let self: IEmscriptenWorker;

self.miniaudio = new FakeDOM.MiniAudio();
self.window = new FakeDOM.Window();
self.onmessage = (ev: MessageEvent<IPCMessage>) => {
    if (ev.data !== undefined && ev.data.type !== undefined && ev.data.message !== undefined) {
        MessageHandler.OnMessage(ev.data.type, ev.data.message);
    }
};
export { };