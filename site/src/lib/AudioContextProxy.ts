export enum AudioEventType {
    Suspend,
    Resume,
    CreateScriptProcessor,
    Connect,
}

export class AudioContextProxy {
    static ctor: any;
    public static SetContext(ctor: any) {
        this.ctor = ctor;
    }

    Context: AudioContext;
    constructor() {
        this.Context = new AudioContextProxy.ctor();
    }

    public resume(): Promise<void> {
        return this.Context.resume();
    }
    public suspend(): Promise<void> {
        return this.Context.suspend();
    }

    public createScriptProcessor(bufferSize?: number, numberOfInputChannels?: number, numberOfOutputChannels?: number) {
        const scriptProcessor = this.Context.createScriptProcessor(bufferSize, numberOfInputChannels, numberOfOutputChannels);
        return new ScriptProcessorNodeProxy(scriptProcessor);
    }

    public get destination() {
        return this.Context.destination;
    }

    public close(): Promise<void> {
        return this.Context.close();
    }

    public get sampleRate(): number {
        return this.Context.sampleRate;
    }
}

export class ScriptProcessorNodeProxy {
    Node: ScriptProcessorNode;
    constructor(node: ScriptProcessorNode) {
        this.Node = node;
    }

    public get onaudioprocess(): ((this: ScriptProcessorNode, ev: AudioProcessingEvent) => any) | null {
        return this.Node.onaudioprocess;
    }
    public set onaudioprocess(value: ((this: ScriptProcessorNode, ev: AudioProcessingEvent) => any) | null) {
        this.Node.onaudioprocess = (ev: AudioProcessingEvent) => {
            console.log(ev);
            (<any>value)(ev);
        };
    }
    public connect(destinationNode: AudioNode, output?: number, input?: number): AudioNode {
        return this.Node.connect(destinationNode, output, input);
    }
}