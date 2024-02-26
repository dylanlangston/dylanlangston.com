<!-- 
Github @dukenmarga, July 2022
Context Menu is small menu that displayed when user right-click the mouse on browser.
Think of it as a way to show Refresh option on Microsoft Windows when right-click on desktop.
Inspired from: Context Menu https://svelte.dev/repl/3a33725c3adb4f57b46b597f9dade0c1?version=3.25.0
-->

<script lang="ts">
	import { onMount } from 'svelte';
	import Ripple from './ripple.svelte';
	import { blur, fade, slide } from 'svelte/transition';

	// pos is cursor position when right click occur
	let pos = { x: -1000, y: -1000 };
	// menu is dimension (height and width) of context menu
	let menu = { x: 0, y: 0 };
	// browser/window dimension (height and width)
	let browser = { w: 0, h: 0 };
	// showMenu is state of context-menu visibility
	let showMenu = true;

	function rightClickContextMenu(e: MouseEvent) {
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
	function test() {
		alert('test');
	}
	let menuItems = [
		{
			name: 'test',
			onClick: test,
			displayText: 'test',
			class: ''
		},
		{
			name: 'hr'
		},
        {
			name: 'test',
			onClick: test,
			displayText: 'test 2',
			class: ''
		}
	];

	onMount(() => {
		showMenu = false;
	});
</script>

<div class="overflow-clip">
	{#if showMenu}
		<nav 
        in:blur|local={{ duration: 150 }}
        out:blur|local={{ duration: 150 , delay: 50 }} use:getContextMenuDimension style="position: absolute; top:{pos.y}px; left:{pos.x}px">
			<div
				class="p-1 glass round rounded-lg glass-no-animate container flex flex-col justify-between mx-auto content-center text-center"
			>
				{#each menuItems as item}
					<div
						class="top-10 right-0"
					>
						{#if item.name == 'hr'}
							<hr class="my-1 border-current" />
						{:else}
							<Ripple color={'currentColor'}>
								<button class="w-full flex items-center rounded-md px-3 py-1 text-sm hover:shadow-md hover:bg-rainbow transition-colors duration-300" on:click={item.onClick}><i class={item.class}></i>{item.displayText}</button
								>
								<!-- <a
                                href="/contact"
                                class="flex items-center rounded-md px-3 py-2 text-sm hover:shadow-md hover:bg-rainbow transition-colors duration-300"
                                >Contact</a
                            > -->
							</Ripple>
						{/if}
					</div>
				{/each}
			</div>
		</nav>
	{/if}
</div>

<svelte:window on:contextmenu|preventDefault={rightClickContextMenu} on:click={onPageClick} />
