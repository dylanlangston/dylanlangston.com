<script lang="ts">
	import { type IEmscripten, EmscriptenModule } from '$lib/Emscripten';
	import { onMount, onDestroy, tick } from 'svelte';
	import emscriptenModuleFactory from '../import/emscripten';
	import { fade, blur, fly, slide, scale, crossfade } from 'svelte/transition';
	import emscriptenWorker from '$lib/Emscripten.worker?worker';
	import { IPCMessage, IPCMessageType } from '$lib/IPCMessage';

	// Specify if we should use a web worker
	const UseWorker: boolean = true;

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
			worker = new emscriptenWorker();
			const offscreenCanvas = canvasElement.transferControlToOffscreen();
			worker.postMessage(IPCMessage.Initialize(offscreenCanvas), [offscreenCanvas]);
			worker.onmessage = (ev: MessageEvent<IPCMessage>) => {
				switch (ev.data.type) {
					case IPCMessageType.Initialized:
						canvas = canvasElement;
						break;
					case IPCMessageType.AddEventHandler:
						const eventHandler: {
							id: number;
							target: string;
							type: string;
							listener: EventListenerOrEventListenerObject;
						} = <any>ev.data.message;

						// Need to make a recursive function that only saves transferable data types. Number, string etc...

						function sanitizeEvent(e: any) {
							const obj: any = {};
							for (let k in e) {
								if (e[k] instanceof Node) continue;
								if (e[k] instanceof Window) continue;
								if (e[k] instanceof Function) continue;

								switch (typeof e[k]) {
									case 'undefined':
									case 'boolean':
									case 'number':
									case 'bigint':
									case 'string':
										obj[k] = e[k];
										break;
									case 'object':
										obj[k] = sanitizeEvent(e[k]);
										break;
								}
							}
							return obj;
						}

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
							// case 'Canvas':
							// 	canvasElement.addEventListener(eventHandler.type, (e) => {
							// 		worker?.postMessage(
							// 			IPCMessage.EventHandlerCallback({
							// 				id: eventHandler.id,
							// 				target: eventHandler.target,
							// 				type: eventHandler.type,
							// 				event: sanitizeEvent(e)
							// 			})
							// 		);
							// 	});
							// 	break;
							default:
								break;
						}
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
			}
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
