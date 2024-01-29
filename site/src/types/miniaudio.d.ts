export interface MiniAudio {
	device_type: {
		playback: number;
		capture: number;
		duplex: number;
	};
	referenceCount: number;
	devices: Array<MiniAudioDevice>;
	get_device_by_index: (e: number) => MiniAudioDevice;
	unlock: () => void;
	unlock_event_types: Array<string>;
	track_device: (device: MiniAudioDevice) => number;
	untrack_device: (device: MiniAudioDevice) => void;
	untrack_device_by_index: (deviceIndex: number) => void;
}

export interface MiniAudioDevice {
	intermediaryBuffer: number;
	intermediaryBufferSizeInBytes: number;
	intermediaryBufferView: Float32Array;
	scriptNode: ScriptProcessorNode;
	state: 2;
	webaudio: AudioContext;
}
