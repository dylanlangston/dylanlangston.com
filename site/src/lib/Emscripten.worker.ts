import { type IEmscripten, EmscriptenModule } from '$lib/Emscripten';
import { IPCMessage, IPCMessageType, type IPCMessageDataType } from '$lib/IPCMessage';
import emscriptenModuleFactory from '../import/emscripten';
import { Environment } from "$lib/Common";
import { FunctionProxy } from './FunctionProxy';
import { FakeDOM } from './FakeDOM';

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

eventHandlers[IPCMessageType.AudioEvent] = (message) => {
    console.log(message);
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

// Register Event Handler for all Worker Messages
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
    public static Handler = new WorkerMessageEventHandler();
}

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
        WorkerMessageEventHandler.Handler.OnMessage(ev.data.type, ev.data.message);
    }
};
export { };