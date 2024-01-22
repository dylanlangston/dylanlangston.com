import { type IEmscripten, EmscriptenModule } from '$lib/Emscripten';
import { IPCMessage, IPCMessageType, type IPCMessageDataType } from '$lib/IPCMessage';
import emscriptenModuleFactory from '../import/emscripten';

// Define all events here
// The rest of this file should be boilerplate code...
let eventHandlers: { [type: number]: (message: IPCMessageDataType) => void; } = {};
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
eventHandlers[IPCMessageType.EventHandlerCallback] = (message) => {
    let eventHandler: {
        id: number;
        type: string;
        event: any;
    } = <any>message;
    eventHandler.event.preventDefault = () => {};
    eventHandler.event.target = self.document.getCanvas();
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
            const id = FunctionProxy.Add(listener);
            postMessage(IPCMessage.AddEventHandler({ id, target: 'Window', type }));
        }
        public matchMedia(query: string): MediaQueryList {
            return <any>new FakeMediaQueryList(query);
        }
        public get scrollX(): number {
            return 0;
        }
        public get scrollY(): number {
            return 0;
        }
        //public miniaudio = new FakeMiniAudio();
        //public AudioContext = FakeAudioContext;
    }
    class FakeMiniAudio {
        public device_type: string = "";
        public device_state: string = "";
        public referenceCount: number = 0;
        public devices: Array<any> = [];
        public get_device_by_index: (e: number) => any = () => { };
        public unlock: () => void = () => { };
        public unlock_event_types: Array<string> = [];
        public track_device: (device: any) => number = () => 1;
        public untrack_device: (device: any) => void = () => { };
        public untrack_device_by_index: (deviceIndex: number) => void = () => { };
    }
    class FakeAudioContext {
        public readonly baseLatency: number = 0;
        public readonly outputLatency: number = 0;
        public close(): Promise<void> {
            return <any>undefined;
        }
        public createMediaElementSource(mediaElement: HTMLMediaElement): MediaElementAudioSourceNode {
            return <any>undefined;
        }
        public createMediaStreamDestination(): MediaStreamAudioDestinationNode {
            return <any>undefined;
        }
        public createMediaStreamSource(mediaStream: MediaStream): MediaStreamAudioSourceNode {
            return <any>undefined;
        }
        public getOutputTimestamp(): AudioTimestamp {
            return <any>undefined;
        }
        public resume(): Promise<void> {
            return <any>undefined;
        }
        public suspend(): Promise<void> {
            return <any>undefined;
        }
        public addEventListener<K extends keyof BaseAudioContextEventMap>(type: K, listener: (this: AudioContext, ev: BaseAudioContextEventMap[K]) => any, options?: boolean | AddEventListenerOptions): void {
        }
        public removeEventListener<K extends keyof BaseAudioContextEventMap>(type: K, listener: (this: AudioContext, ev: BaseAudioContextEventMap[K]) => any, options?: boolean | EventListenerOptions): void {
        }
    }
    class FakeMediaQueryList {
        query: string;
        constructor(query: string) {
            this.query = query;
        }

        public addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void {

        }
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
}
declare let self: IEmscriptenWorker;
self.window = new FakeDOM.Window();
self.onmessage = (ev: MessageEvent<IPCMessage>) => {
    if (ev.data !== undefined && ev.data.type !== undefined && ev.data.message !== undefined) {
        MessageHandler.OnMessage(ev.data.type, ev.data.message);
    }
};
export { };