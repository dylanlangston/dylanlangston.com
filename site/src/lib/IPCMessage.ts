export enum IPCMessageType {
	Initialize,
	Initialized,
    AddEventHandler,
    EventHandlerCallback,
}

// This class is used for communication between web worker and main page
export class IPCMessage {
	public static Initialize = (canvas: OffscreenCanvas) => new IPCMessage(IPCMessageType.Initialize, canvas);
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

	private constructor(type: IPCMessageType, message: IPCMessageDataType = undefined) {
        this.type = type;
		this.message = message;
	}
	public readonly type: IPCMessageType;
	public readonly message: IPCMessageDataType;
}

export type IPCMessageDataType = 
OffscreenCanvas | 
{
    id: number;
    target: string;
    type: string;
    event?: any;
} | 
PointerEvent | 
undefined;