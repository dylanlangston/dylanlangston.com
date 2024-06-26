<script lang="ts">
	import { EmscriptenInitialize, type IEmscripten } from '$lib/Emscripten';
	import { onMount, onDestroy, tick } from 'svelte';
	import { fade, blur, fly, slide, scale, crossfade } from 'svelte/transition';
	import emscriptenWorker from '$lib/Emscripten.worker?worker';
	import { AudioEventType, IPCMessage, IPCMessageType } from '$lib/IPCMessage';
	import {
		Environment,
		HashMapQueue,
		RateLimiter,
		hash,
		sanitizeEvent,
		useMediaQuery
	} from '$lib/Common';
	import StatusContainer from '$components/status-container.svelte';
	import { Favicon } from '$lib/Favicon';
	import type { Unsubscriber } from 'svelte/store';

	const initWorker = async (canvasElement: HTMLCanvasElement) =>
		new Promise<Worker>((resolve, reject) => {
			const audioContext = new AudioContext();

			const messagePostInterval = 20;
			const workerMessageRateLimiter = new RateLimiter(10, messagePostInterval);
			const workerResizeMessageRateLimiter = new RateLimiter(2, messagePostInterval);
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
						if (type != 'resize' && workerMessageRateLimiter.shouldAllow()) {
							worker?.postMessage(m);
						} else if (type == 'resize' && workerResizeMessageRateLimiter.shouldAllow()) {
							worker?.postMessage(m);
						} else {
							if (messageQueue.add(m)) {
								setTimeout(() => {
									const message = messageQueue.remove();
									if (message != undefined) postMessage(type, message);
								}, messagePostInterval);
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
						resolve(worker);
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
			worker.onerror = (er) => reject(er);
		});

	let favicon: Favicon | undefined = undefined;
	let mobileSubscription: Unsubscriber | undefined = undefined;
	const loadFn: () => Promise<HTMLCanvasElement> = async () => {
		const canvasElement = document.createElement('canvas');
		canvasElement.classList.add(
			'fixed',
			'top-0',
			'bottom-0',
			'left-0',
			'right-0',
			'w-lvw',
			'h-lvh',
			'animate-background',
			'transition',
			'-z-10'
		);

		canvasElement.width = window.innerWidth;
		canvasElement.height = window.innerHeight;

		const UseWorker: boolean = typeof Worker !== 'undefined';
		if (UseWorker) {
			const worker = await initWorker(canvasElement);
			unload = () => {
				worker.terminate();
			};
		} else {
			const emscripten = await EmscriptenInitialize(canvasElement);
			unload = () => {
				try {
					emscripten.abort('Canceled');
				} catch {}
			};
		}

		favicon = new Favicon(canvasElement);

		mobileSubscription = Environment.isMobile.subscribe((mobile) => {
			favicon?.destroy();
			if (!mobile) {
				favicon = new Favicon(canvasElement);
			}
		});

		return canvasElement;
	};

	var unload: () => void | undefined;
	onDestroy(() => {
		if (unload) unload();

		favicon?.destroy();

		if (mobileSubscription) mobileSubscription();
	});


	function setCanvas(self: HTMLDivElement, options: { canvas: HTMLCanvasElement }) {
		self.appendChild(options.canvas);
		return {
			destroy() {
				self.removeChild(options.canvas);
			}
		};
	}
</script>

{#await loadFn() then canvas}
	<div in:fade={{ duration: 500, delay: 800 }} use:setCanvas={{ canvas }} />
{:catch error}
	<!-- Todo Dialog with Error Message -->
{/await}
