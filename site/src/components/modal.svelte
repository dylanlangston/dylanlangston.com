<!-- Source: https://svelte.dev/examples/modal -->
<script lang="ts">
	import { fade } from 'svelte/transition';
	import MouseCursor from './mouse-cursor.svelte';
	import ContextMenu from './context-menu.svelte';

	export let showModal: boolean;
	export let canCloseByClickingOutside: boolean = false;

	let dialog: HTMLDialogElement;

	$: if (dialog && showModal) dialog.showModal();
</script>

<!-- svelte-ignore a11y-click-events-have-key-events a11y-no-noninteractive-element-interactions -->
<dialog
	in:fade|local={{ duration: 250 }}
	out:fade|local={{ duration: 250 }}
	bind:this={dialog}
	on:close={() => (showModal = false)}
	on:click|self={() => (canCloseByClickingOutside ? dialog.close() : null)}
	class="backdrop:cursor-none bg-transparent dark:backdrop:bg-black/30 backdrop:bg-white/30 backdrop:backdrop-blur-md backdrop:backdrop-opacity-80"
>
	<!-- svelte-ignore a11y-no-static-element-interactions -->
	<div on:click|stopPropagation class="glass round glass-no-animate">
		<slot />
	</div>
	<div class="fixed top-0 left-0">
		<ContextMenu/>
		<MouseCursor />
	</div>
</dialog>
