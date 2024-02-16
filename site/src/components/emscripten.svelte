<script lang="ts">
	import { EmscriptenInitialize } from '$lib/Emscripten';
	import { onMount, onDestroy, tick } from 'svelte';
	import { fade, blur, fly, slide, scale, crossfade } from 'svelte/transition';
	import emscriptenWorker from '$lib/Emscripten.worker?worker';
	import { AudioEventType, IPCMessage, IPCMessageType } from '$lib/IPCMessage';
	import { Environment, HashMapQueue, RateLimiter, hash, sanitizeEvent } from '$lib/Common';

	function initWorker(canvasElement: HTMLCanvasElement) {
		const audioContext = new AudioContext();

		const messagePostInterval = 20;
		const refreshRateMod = 10;
		const workerMessageRateLimiter = new RateLimiter(10, messagePostInterval);
		const workerResizeMessageRateLimiter = new RateLimiter(1, messagePostInterval * refreshRateMod);
		const messageQueue = new HashMapQueue<IPCMessage>((e) => e.hash());

		const listeners: ((e: Event) => void)[] = [];
		function HandleEvent(
			add: boolean,
			eventHandler: {
				id: number;
				target: string;
				type: string;
			}
		) {
			let target: EventTarget;

			switch (eventHandler.target) {
				case 'Window':
				case 'Canvas':
				default:
					target = window;
					break;
				case 'Document':
					target = document;
					break;
			}

			if (add) {
				const postMessage = (type: string, m: IPCMessage) => {
					if (type == "resize" && workerResizeMessageRateLimiter.shouldAllow()) {
						worker?.postMessage(m);
					}
					else if (type != "resize" && workerMessageRateLimiter.shouldAllow()) {
						worker?.postMessage(m);
					} else {
						if (messageQueue.add(m)) {
							setTimeout(() => {
								const message = messageQueue.remove();
								if (message != undefined) postMessage(type, message);
							}, type == "resize" ? messagePostInterval * refreshRateMod : messagePostInterval);
						}
					}
				};
				const listener = (e: Event) =>
					postMessage(
						eventHandler.type,
						IPCMessage.EventHandlerCallback({
							id: eventHandler.id,
							target: eventHandler.target,
							type: eventHandler.type,
							event: sanitizeEvent(e)
						})
					);
				listeners[eventHandler.id] = listener;
				target.addEventListener(eventHandler.type, listener);
			} else {
				const listener = listeners[eventHandler.id];
				target.removeEventListener(eventHandler.type, listener);
			}
		}

		let processorNode: ScriptProcessorNode;
		let audioOutput: [[]] = [[]];
		function HandleAudio(audioEvent: { type: AudioEventType; details?: any }) {
			switch (audioEvent.type) {
				case AudioEventType.Connect:
					const audioNode = processorNode.connect(<AudioNode>audioContext.destination);
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

		// Start audio on input event
		const eventTypes = ['click', 'touchend', 'mousedown', 'keydown'];
		const listener = () => {
			audioContext.resume().then(() => {
				eventTypes.forEach((et) => document.body.removeEventListener(et, listener));
			});
		};
		eventTypes.forEach((e) => document.body.addEventListener(e, listener, { once: true }));
		listener();

		// Create Worker
		const worker = new emscriptenWorker();
		const offscreenCanvas = canvasElement.transferControlToOffscreen();
		worker.postMessage(IPCMessage.Initialize(offscreenCanvas, audioContext.sampleRate), [
			offscreenCanvas
		]);
		worker.onmessage = (ev: MessageEvent<IPCMessage>) => {
			switch (ev.data.type) {
				case IPCMessageType.Initialized:
					canvas = canvasElement;
					window.dispatchEvent(new Event('resize'));
					break;
				case IPCMessageType.AddEventHandler:
					HandleEvent(true, <any>ev.data.message);
					break;
				case IPCMessageType.RemoveEventHandler:
					HandleEvent(false, <any>ev.data.message);
					break;
				case IPCMessageType.AudioEvent:
					HandleAudio(<any>ev.data.message);
					break;
				default:
					throw 'Not Implemented';
			}
		};
		worker.onerror = (er) => {
			worker?.terminate();
			canvas = undefined;
			if (Environment.Dev) debugger;
			throw er;
		};
	}

	function initFallback(canvasElement: HTMLCanvasElement) {
		EmscriptenInitialize(canvasElement).then((emscripten) => {
			canvas = canvasElement;
			window.dispatchEvent(new Event('resize'));
		});
	}

	let canvas: HTMLCanvasElement | undefined = undefined;
	onMount(async () => {
		const canvasElement = document.createElement('canvas');
		canvasElement.classList.add(
			'fixed',
			'top-0',
			'bottom-0',
			'left-0',
			'right-0',
			'w-screen',
			'h-screen'
		);
		canvasElement.width = window.screen.width;
		canvasElement.height = window.screen.height;

		const UseWorker: boolean = typeof Worker !== 'undefined';
		if (UseWorker) {
			initWorker(canvasElement);
		} else {
			initFallback(canvasElement);
		}
	});

	onDestroy(() => {
		canvas = undefined;
	});

	function setCanvas(self: HTMLDivElement): void {
		if (canvas !== undefined) self.appendChild(canvas);
	}
</script>

{#if canvas !== undefined}
	<object title="Background Canvas" class="-z-50" in:fade={{ duration: 500 }} use:setCanvas />
{/if}
