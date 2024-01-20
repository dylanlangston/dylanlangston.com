<script lang="ts">
	import { type IEmscripten, EmscriptenModule } from '$lib/Emscripten';
	import { onMount, onDestroy, tick } from 'svelte';
	import emscriptenModuleFactory from '../import/emscripten';
	import { fade, blur, fly, slide, scale, crossfade } from 'svelte/transition';
	import emscriptenWorker from '$lib/Emscripten.worker?worker';
	import { IPCMessage, IPCMessageType } from '$lib/Emscripten';

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
		worker = new emscriptenWorker();
		const offscreenCanvas = canvasElement.transferControlToOffscreen();
		worker.postMessage(IPCMessage.Initialize(offscreenCanvas), [offscreenCanvas]);
		worker.onmessage = (ev: MessageEvent<IPCMessage>) => {
			switch (ev.data.type) {
				case IPCMessageType.Initialized:
                    canvas = canvasElement;
					break;
				default:
					throw 'Not Implemented';
			}
		};
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
