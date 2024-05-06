<!-- Source: https://svelte.dev/examples/modal -->
<script>
	export let showModal; // boolean

	let dialog; // HTMLDialogElement

	$: if (dialog && showModal) dialog.showModal();
</script>

<!-- svelte-ignore a11y-click-events-have-key-events a11y-no-noninteractive-element-interactions -->
<dialog
	bind:this={dialog}
	on:close={() => (showModal = false)}
	on:click|self={() => dialog.close()}
    class="bg-transparent backdrop:bg-black/30 dark:backdrop:bg-white/30 backdrop:backdrop-blur-md backdrop:backdrop-opacity-80"
>
	<!-- svelte-ignore a11y-no-static-element-interactions -->
	<div on:click|stopPropagation class="glass round glass-no-animate">
		<slot name="header" />
		<br/>
		<slot />
        <br/>
		<button autofocus on:click={() => dialog.close()}>close modal</button>
	</div>
</dialog>