export enum IPCMessageType {
	Initialize,
	Initialized,
    AddEventHandler,
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
    CreateScriptProcessor,
    Connect,
    StartProcessAudio,
    ProcessAudio,
    AudioOutput,
}