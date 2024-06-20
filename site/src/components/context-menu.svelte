<!-- 
Github @dukenmarga, July 2022
Context Menu is small menu that displayed when user right-click the mouse on browser.
Think of it as a way to show Refresh option on Microsoft Windows when right-click on desktop.
Inspired from: Context Menu https://svelte.dev/repl/3a33725c3adb4f57b46b597f9dade0c1?version=3.25.0
-->

<script lang="ts">
	import { onMount } from 'svelte';
	import Ripple from '$components/ripple.svelte';
	import { blur, fade, slide } from 'svelte/transition';

	// pos is cursor position when right click occur
	let pos = { x: -1000, y: -1000 };
	// menu is dimension (height and width) of context menu
	let menu = { x: 0, y: 0 };
	// browser/window dimension (height and width)
	let browser = { w: 0, h: 0 };
	// showMenu is state of context-menu visibility
	let showMenu = true;

	let lastActiveElement: Element | null;

	function rightClickContextMenu(e: MouseEvent) {
		if (e.shiftKey) return false;
		e.preventDefault();

		if (showMenu) {
			showMenu = false;
			setTimeout(() => rightClickContextMenu(e));
			return;
		}
		showMenu = true;
		browser = {
			w: window.innerWidth,
			h: window.innerHeight
		};
		pos = {
			x: e.clientX,
			y: e.clientY
		};
		// If bottom part of context menu will be displayed
		// after right-click, then change the position of the
		// context menu. This position is controlled by `top` and `left`
		// at inline style.
		// Instead of context menu is displayed from top left of cursor position
		// when right-click occur, it will be displayed from bottom left.
		if (browser.h - pos.y < menu.x) pos.y = pos.y - menu.x;
		if (browser.w - pos.x < menu.y) pos.x = pos.x - menu.y;
		setTimeout(() => {
			if (browser.h - pos.y < menu.x) pos.y = pos.y - menu.x;
			if (browser.w - pos.x < menu.y) pos.x = pos.x - menu.y;
		});
	}
	function onPageClick(e: MouseEvent) {
		// To make context menu disappear when
		// mouse is clicked outside context menu
		showMenu = false;

		lastActiveElement = document.activeElement;
	}
	function getContextMenuDimension(node: HTMLElement) {
		// This function will get context menu dimension
		// when navigation is shown => showMenu = true
		let height = node.offsetHeight;
		let width = node.offsetWidth;
		menu = {
			x: height,
			y: width
		};
	}
	function selectAll() {
		const elem = document.querySelector('dialog') ?? lastActiveElement ?? document;
		if (['INPUT', 'TEXTAREA'].filter((e) => e == elem.nodeName).length > 0) {
			(<HTMLInputElement>elem).select();
			return;
		}
		globalThis.getSelection()?.selectAllChildren(elem);
	}
	async function canCopy() {
		const elem = lastActiveElement ?? document;
		if (['INPUT', 'TEXTAREA'].filter((e) => e == elem.nodeName).length > 0) {
			const selectedText = (<HTMLInputElement>elem).value.substring(
				(<HTMLInputElement>elem).selectionStart ?? 0,
				(<HTMLInputElement>elem).selectionEnd ?? 0
			);
			if (selectedText?.length ?? 0 > 0) return true;
			return false;
		}
		const selectedText = globalThis.getSelection()?.toString();
		if (selectedText?.length ?? 0 > 0) return true;
		return false;
	}
	function copy() {
		const elem = lastActiveElement ?? document;
		if (['INPUT', 'TEXTAREA'].filter((e) => e == elem.nodeName).length > 0) {
			const selectedText = (<HTMLInputElement>elem).value.substring(
				(<HTMLInputElement>elem).selectionStart ?? 0,
				(<HTMLInputElement>elem).selectionEnd ?? 0
			);
			if (selectedText) navigator.clipboard.writeText(selectedText);
			return;
		}

		const selectedText = globalThis.getSelection()?.toString();
		if (selectedText) navigator.clipboard.writeText(selectedText);
	}
	async function canPaste() {
		const elem = lastActiveElement ?? document;
		if (['INPUT', 'TEXTAREA'].filter((e) => e == elem.nodeName).length > 0) {
			const clipboardText = await navigator.clipboard.readText();
			if (clipboardText?.length ?? 0 > 0) return true;
			return false;
		}
	}
	function replaceSelection(
		initialValue: string,
		selectionStart: number,
		selectionEnd: number,
		clipboardText: string
	): string {
		const beforeSelection = initialValue.substring(0, selectionStart);
		const afterSelection = initialValue.substring(selectionEnd);

		const newValue = beforeSelection + clipboardText + afterSelection;
		return newValue;
	}

	function paste() {
		const elem = lastActiveElement ?? document;
		navigator.clipboard.readText().then((clipboardText) => {
			const initialValue = (<HTMLInputElement>elem).value;
			(<HTMLInputElement>elem).value = replaceSelection(initialValue, (<HTMLInputElement>elem).selectionStart ?? 0, (<HTMLInputElement>elem).selectionEnd ?? initialValue.length, clipboardText);
		});
	}
	let menuItems = [
		{
			name: 'selectAll',
			onClick: selectAll,
			displayText: 'Select All',
			class: '',
			enabled: async () => true
		},
		{
			name: 'hr',
			enabled: async () => (await canCopy()) || (await canPaste())
		},
		{
			name: 'copy',
			onClick: copy,
			displayText: 'Copy',
			class: '',
			enabled: canCopy
		},
		{
			name: 'paste',
			onClick: paste,
			displayText: 'Paste',
			class: '',
			enabled: canPaste
		}
	];

	onMount(() => {
		showMenu = false;
	});
</script>

<div class="context-menu overflow-clip">
	{#if showMenu}
		<nav
			in:blur|local={{ duration: 150 }}
			out:blur|local={{ duration: 150, delay: 50 }}
			use:getContextMenuDimension
			style="position: absolute; top:{pos.y}px; left:{pos.x}px"
		>
			<div
				class="p-1 glass round rounded-lg glass-no-animate container flex flex-col justify-between mx-auto content-center text-center"
			>
				{#each menuItems as item}
					{#if item.enabled}
						{#await item.enabled()}
							<p>...waiting</p>
						{:then enabled}
							{#if enabled}
								<div class="top-10 right-0">
									{#if item.name == 'hr'}
										<hr class="my-1 border-current" />
									{:else}
										<Ripple color={'currentColor'}>
											<button
												class="w-full flex items-center rounded-md px-3 py-1 text-sm hover:shadow-md hover:bg-rainbow transition-colors duration-300"
												on:click={item.onClick}><i class={item.class}></i>{item.displayText}</button
											>
										</Ripple>
									{/if}
								</div>
							{/if}
						{/await}
					{/if}
				{/each}
			</div>
		</nav>
	{/if}
</div>

<svelte:window on:contextmenu={rightClickContextMenu} on:click={onPageClick} />

<style>
	.context-menu ::selection {
		background: transparent;
	}
</style>
