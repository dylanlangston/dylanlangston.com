import type { MiniAudio as IMiniAudio, MiniAudioDevice } from "../types/miniaudio";
import { AudioEventType } from "./AudioContextProxy";
import { FunctionProxy } from "./FunctionProxy";
import { IPCMessage } from "./IPCMessage";

// Minimum implementation of the DOM needed to make Emscripten run from our web worker
export namespace FakeDOM {
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

    export class MiniAudio implements IMiniAudio {
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
        public devices: MiniAudioDevice[] = [];
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
            this.devices[deviceIndex] = <any>null;
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
        public get_device_by_index: (deviceIndex: number) => MiniAudioDevice = (deviceIndex: number) => this.devices[deviceIndex];
        public unlock_event_types: string[] = ['touchend', 'click'];
        public unlock(): void {
            for (let i = 0; i < this.devices.length; ++i) {
                const device = this.devices[i];
                if (device != null && device.webaudio != null && device?.state === this.device_state.started) {
                    device.webaudio.resume().then(() => {
                        //Module._ma_device__on_notification_unlocked(device.pDevice);
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
            return new Promise((resolve, reject) => {
                postMessage(IPCMessage.AudioEvent({
                    type: AudioEventType.Suspend,
                    details: null
                }));
                resolve();
            });
        }
        public resume(): Promise<void> {
            return new Promise((resolve, reject) => {
                postMessage(IPCMessage.AudioEvent({
                    type: AudioEventType.Resume,
                    details: null
                }));
                resolve();
            });
        }
        public createScriptProcessor(bufferSize?: number, numberOfInputChannels?: number, numberOfOutputChannels?: number) {
            postMessage(IPCMessage.AudioEvent({
                type: AudioEventType.CreateScriptProcessor,
                details: {
                    bufferSize: bufferSize,
                    numberOfInputChannels: numberOfInputChannels,
                    numberOfOutputChannels: numberOfOutputChannels
                }
            }));
            return {
                connect: (args: any) => {
                    postMessage(IPCMessage.AudioEvent({
                        type: AudioEventType.Connect,
                        details: null
                    }));
                },
            };
        }
        // public createMediaStreamSource(arg: any) {
        //     console.log(arg);
        // }
        public destination: any = {};
        public onaudioprocess: any = undefined;

        public get sampleRate(): number {
            return 48000;
        }
    }
};