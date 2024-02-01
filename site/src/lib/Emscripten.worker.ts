import { type IEmscripten, EmscriptenModule } from '$lib/Emscripten';
import { AudioEventType, IPCMessage, IPCMessageType, type IPCMessageDataType } from '$lib/IPCMessage';
import emscriptenModuleFactory from '../import/emscripten';
import { Environment } from "$lib/Common";
import { IPCProxy } from './IPCProxy';
import { WorkerDOM } from './WorkerDOM';

// Define all events here
// The rest of this file should be boilerplate code...
let eventHandlers: { [type: number]: (message: IPCMessageDataType) => void; } = {};
// On Initialized
eventHandlers[IPCMessageType.Initialize] = (message: IPCMessageDataType) => {
    // This needs to match the width of the canvas
    const width = 800;
    const height = 450;

    const canvas: OffscreenCanvasExtended = (<any>message).canvas;
    canvas.clientWidth = width;
    canvas.clientHeight = height;
    canvas.addEventListener = (type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void => {
        const id = IPCProxy.Add(listener);
        postMessage(IPCMessage.AddEventHandler({ id, target: 'Canvas', type }));
    };
    canvas.getBoundingClientRect = () => {
        return { x: 0, y: 0, width: width, height: height, top: 0, right: width, bottom: height, left: 0 };
    }

    WorkerDOM.SetSampleRate((<any>message).audioSampleRate);
    self.document = new WorkerDOM.Document(<any>canvas);

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
    const func = IPCProxy.Get(eventHandler.id);
    func(eventHandler.event);
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
    window: WorkerDOM.Window;
    document: WorkerDOM.Document;
    miniaudio: WorkerDOM.MiniAudio;
}
declare let self: IEmscriptenWorker;

self.miniaudio = new WorkerDOM.MiniAudio();
self.window = new WorkerDOM.Window();
self.onmessage = (ev: MessageEvent<IPCMessage>) => {
    if (ev.data !== undefined && ev.data.type !== undefined && ev.data.message !== undefined) {
        WorkerMessageEventHandler.Handler.OnMessage(ev.data.type, ev.data.message);
    }
};
export { };