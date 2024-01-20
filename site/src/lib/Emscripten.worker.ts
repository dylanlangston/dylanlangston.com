import { type IEmscripten, EmscriptenModule, IPCMessage, IPCMessageType } from '$lib/Emscripten';
import emscriptenModuleFactory from '../import/emscripten';

onmessage = (ev: MessageEvent<IPCMessage>) => {
    if (ev.data !== undefined && ev.data.type !== undefined)
    {
        switch (ev.data.type)
        {
            case IPCMessageType.Initialize:
                if (ev.data.canvas !== undefined) {
                    (<any>globalThis.window) = {
                        addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions) {
                            
                        },
                        matchMedia(query: string): MediaQueryList {
                            return <MediaQueryList>{
                                addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions) {
                    
                                }
                            };
                        },
                    };
                    (<any>globalThis).document = {
                        addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions) {
                    
                        },
                        querySelector(selectors: string): HTMLElement | null {
                            return <any>ev.data.canvas;
                        }
                    };

                    (<EmscriptenModuleFactory<IEmscripten>>emscriptenModuleFactory)(EmscriptenModule(ev.data.canvas)).then(emscripten => {
                        postMessage(IPCMessage.Initialized())
                    })
                }
                break;
            default:
                throw "Not Implemented";
        }
    }
};

export { };