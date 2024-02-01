<script lang="ts">
	import { type IEmscripten, EmscriptenModule } from '$lib/Emscripten';
	import { onMount, onDestroy, tick } from 'svelte';
	import emscriptenModuleFactory from '../import/emscripten';
	import { fade, blur, fly, slide, scale, crossfade } from 'svelte/transition';
	import emscriptenWorker from '$lib/Emscripten.worker?worker';
	import { AudioEventType, IPCMessage, IPCMessageType } from '$lib/IPCMessage';
	import { sanitizeEvent } from '$lib/Common';

	// Specify if we should use a web worker
	const UseWorker: boolean = typeof Worker !== 'undefined';

	function AddEventHandler(eventHandler: {
		id: number;
		target: string;
		type: string;
		listener: EventListenerOrEventListenerObject;
	}) {
		switch (eventHandler.target) {
			case 'Window':
			case 'Canvas':
				window.addEventListener(eventHandler.type, (e) => {
					worker?.postMessage(
						IPCMessage.EventHandlerCallback({
							id: eventHandler.id,
							target: eventHandler.target,
							type: eventHandler.type,
							event: sanitizeEvent(e)
						})
					);
				});
				break;
			case 'Document':
				document.addEventListener(eventHandler.type, (e) => {
					worker?.postMessage(
						IPCMessage.EventHandlerCallback({
							id: eventHandler.id,
							target: eventHandler.target,
							type: eventHandler.type,
							event: sanitizeEvent(e)
						})
					);
				});
				break;
			default:
				break;
		}
	}

	let audioContext: AudioContext;
	let processorNode: ScriptProcessorNode;
	let audioNode: AudioNode;
	let audioOutput: [[]] = [[]];
	function AudioEvent(audioEvent: { type: AudioEventType; details?: any }) {
		switch (audioEvent.type) {
			case AudioEventType.Connect:
				audioNode = processorNode.connect(<AudioNode>audioContext.destination);
				break;
			case AudioEventType.CreateScriptProcessor:
				processorNode = audioContext.createScriptProcessor(
					audioEvent.details.bufferSize,
					audioEvent.details.numberOfInputChannels,
					audioEvent.details.numberofOutputChannels
				);
				break;
			case AudioEventType.Resume:
				audioContext.resume();
				break;
			case AudioEventType.Suspend:
				audioContext.suspend();
				break;
			case AudioEventType.StartProcessAudio:
				processorNode.onaudioprocess = (ev) => {
					worker?.postMessage(
						IPCMessage.AudioEvent(AudioEventType.ProcessAudio, {
							funcProxy: audioEvent.details,
							data: sanitizeEvent(ev)
						})
					);
					for (var i = 0; i < audioOutput.length; i++) {
						ev.outputBuffer.getChannelData(i).set(audioOutput[i]);
					}
				};
				break;
			case AudioEventType.AudioOutput:
				audioOutput = audioEvent.details.data;
				break;
		}
	}

	let worker: Worker | undefined = undefined;
	let canvas: HTMLCanvasElement | undefined = undefined;
	onMount(async () => {
		const canvasElement = document.createElement('canvas');
		canvasElement.classList.add(
			'absolute',
			'top-0',
			'bottom-0',
			'left-0',
			'right-0',
			'w-screen',
			'h-screen',
			'-z-50'
		);
		if (UseWorker) {
			audioContext = new AudioContext();

			// Start audio on input event
			const eventTypes = ['click', 'touchend', 'mousedown', 'keydown'];
			const listener = () => {
				audioContext.resume().then(() => {
					eventTypes.forEach((et) => document.body.removeEventListener(et, listener));
				})
			};
			eventTypes.forEach((e) => document.body.addEventListener(e, listener, { once: true }));
			listener();

			// Create Worker
			worker = new emscriptenWorker();
			const offscreenCanvas = canvasElement.transferControlToOffscreen();
			worker.postMessage(IPCMessage.Initialize(offscreenCanvas, audioContext.sampleRate), [
				offscreenCanvas
			]);
			worker.onmessage = (ev: MessageEvent<IPCMessage>) => {
				switch (ev.data.type) {
					case IPCMessageType.Initialized:
						canvas = canvasElement;
						break;
					case IPCMessageType.AddEventHandler:
						AddEventHandler(<any>ev.data.message);
						break;
					case IPCMessageType.AudioEvent:
						AudioEvent(<any>ev.data.message);
						break;
					default:
						throw 'Not Implemented';
				}
			};
			worker.onerror = (er) => {
				worker?.terminate();
				worker = undefined;
				canvas = undefined;
				throw er;
			};
		} else {
			(<EmscriptenModuleFactory<IEmscripten>>emscriptenModuleFactory)(
				EmscriptenModule(<any>canvasElement)
			).then((emscripten) => {
				canvas = canvasElement;
			});
		}
	});

	onDestroy(() => {});

	function onError(e: Event): void {
		canvas = undefined;
	}

	function setCanvas(self: HTMLDivElement): void {
		if (canvas !== undefined) self.appendChild(canvas);
	}
</script>

{#if canvas !== undefined}
	<div in:fade={{ duration: 150 }} class="" use:setCanvas />
{/if}
