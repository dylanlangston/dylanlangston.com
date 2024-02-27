import { EmscriptenInitialize } from '$lib/Emscripten';
import { AudioEventType, IPCMessage, IPCMessageType, type IPCMessageDataType } from '$lib/IPCMessage';
import { Environment } from "$lib/Common";
import { IPCProxy } from './IPCProxy';
import { WorkerDOM } from './WorkerDOM';

// Define all events here
// The rest of this file should be boilerplate code...
let eventHandlers: { [type: number]: (message: IPCMessageDataType) => void; } = {};
// On Initialized
eventHandlers[IPCMessageType.Initialize] = (message: IPCMessageDataType) => {
    // This needs to match the width of the canvas
    const eventDetails: {
        canvas: OffscreenCanvas,
        audioSampleRate: number
    } = <any>message;

    const canvas = new WorkerDOM.OffscreenCanvasExtended(eventDetails.canvas);
    WorkerDOM.SetSampleRate(eventDetails.audioSampleRate);
    self.document = new WorkerDOM.Document(canvas);
    EmscriptenInitialize(canvas).then(emscripten => {
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
    if (eventHandler.type == "resize") {
        eventHandler.event.target = self.window;
    } else {
        eventHandler.event.target = self.document.getCanvas();
    }
    
    //if (Environment.Dev) console.debug(eventHandler);
    const func = IPCProxy.Get(eventHandler.id);
    if (func) {
        func(eventHandler.event);
    }
};
// Audio Callbacks
eventHandlers[IPCMessageType.AudioEvent] = (message) => {
    let eventHandler: {
        details: {
            funcProxy: number,
            eventProxy: number,
            data: any
        },
        type: AudioEventType
    } = <any>message;
    switch (eventHandler.type) {
        case AudioEventType.ProcessAudio:
            const func = IPCProxy.Get(eventHandler.details.funcProxy);
            const audioEvent = eventHandler.details.data;
            const audioOutput: any = [[]];
            audioEvent.outputBuffer.getChannelData = (iChannel: number) => {
                audioOutput[iChannel] = [];
                return audioOutput[iChannel];
            };
            func(eventHandler.details.data);
            postMessage(IPCMessage.AudioEvent(
                AudioEventType.AudioOutput,
                {
                    eventProxy: eventHandler.details.eventProxy,
                    data: audioOutput
                }
            ));
            break;
    }
};



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
    window: WorkerDOM.Window;
    document: WorkerDOM.Document;
    miniaudio: WorkerDOM.MiniAudio;
    innerWidth: number,
    innerHeight: number,
    outerWidth: number,
    outerHeight: number,
    pageXOffset: number,
    pageYOffset: number,
    devicePixelRatio: number;
}
declare let self: IEmscriptenWorker;

self.miniaudio = new WorkerDOM.MiniAudio();
self.window = new WorkerDOM.Window();
self.onmessage = (ev: MessageEvent<IPCMessage>) => {
    if (ev.data !== undefined && ev.data.type !== undefined && ev.data.message !== undefined) {
        WorkerMessageEventHandler.Handler.OnMessage(ev.data.type, ev.data.message);
    }
};
// This is just a dummy/placeholder, as the correctly scaled resolution is already sent to the worker
self.devicePixelRatio = 1;

Object.defineProperty(self, "innerWidth", {
    get: () => self.window.innerWidth,
});
Object.defineProperty(self, "innerHeight", {
    get: () => self.window.innerHeight,
});
Object.defineProperty(self, "outerWidth", {
    get: () => self.window.innerWidth,
});
Object.defineProperty(self, "outerHeight", {
    get: () => self.window.innerHeight,
});
Object.defineProperty(self, "pageXOffset", {
    get: () => self.window.scrollX,
});
Object.defineProperty(self, "pageYOffset", {
    get: () => self.window.scrollY,
});
export { };