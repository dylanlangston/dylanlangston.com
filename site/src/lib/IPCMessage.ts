import { hash } from "./Common";

export enum IPCMessageType {
    Initialize,
    Initialized,
    AddEventHandler,
    RemoveEventHandler,
    EventHandlerCallback,
    AudioEvent,
}

// This class is used for communication between web worker and main page
export class IPCMessage {
    public static Initialize = (canvas: OffscreenCanvas, audioSampleRate: number) => new IPCMessage(IPCMessageType.Initialize, {
        canvas,
        audioSampleRate
    });
    public static Initialized = () => new IPCMessage(IPCMessageType.Initialized);
    public static AddEventHandler = (eventInfo: {
        id: number;
        target: string;
        type: string;
    }) => new IPCMessage(IPCMessageType.AddEventHandler, eventInfo);
    public static RemoveEventHandler = (eventInfo: {
        id: number;
        target: string;
        type: string;
    }) => new IPCMessage(IPCMessageType.RemoveEventHandler, eventInfo);
    public static EventHandlerCallback = (eventInfo: {
        id: number;
        target: string;
        type: string;
        event: any;
    }) => new IPCMessage(IPCMessageType.EventHandlerCallback, eventInfo);
    public static AudioEvent = (type: AudioEventType, details: any = null) => new IPCMessage(IPCMessageType.AudioEvent, {
        type: type,
        details: details
    });

    private constructor(type: IPCMessageType, message: IPCMessageDataType = undefined) {
        this.type = type;
        this.message = message;
    }
    public readonly type: IPCMessageType;
    public readonly message: IPCMessageDataType;

    public hash(): number {
        switch (this.type) {
            case IPCMessageType.Initialize:
                return hash(this.type.toString() + (<{
                    canvas: OffscreenCanvas,
                    audioSampleRate: number
                }>this.message).audioSampleRate);
            case IPCMessageType.EventHandlerCallback:
            case IPCMessageType.AddEventHandler:
            case IPCMessageType.RemoveEventHandler:
                const message = (<{
                    id: number;
                    target: string;
                    type: string;
                    event?: any;
                }>this.message);
                return hash(this.type.toString() + message.target + message.type + message.id);
            case IPCMessageType.AudioEvent:
                return hash(this.type.toString() + (<{
                    type: AudioEventType,
                    details?: any
                }>this.message).type);
            default:
                return hash(this.type.toString());
        };
    }
}

export type IPCMessageDataType =
    {
        canvas: OffscreenCanvas,
        audioSampleRate: number
    } |
    {
        id: number;
        target: string;
        type: string;
        event?: any;
    } |
    {
        type: AudioEventType,
        details?: any
    } |
    PointerEvent |
    undefined;

export enum AudioEventType {
    Suspend,
    Resume,
    Close,
    CreateScriptProcessor,
    Connect,
    Disconnect,
    StartProcessAudio,
    ProcessAudio,
    AudioOutput,
}