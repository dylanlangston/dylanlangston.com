<script lang="ts">
	import { fade, blur, fly, slide, scale } from 'svelte/transition';
	export let status: string | undefined = undefined;

	import Panel from '$components/panel.svelte';
</script>

<div
	in:fade={{ delay: 250, duration: 300 }}
	out:fade
>
	<Panel>
		<svelte:fragment>
			<div class="select-none text-center text-2xl lg:text-6xl font-bold p-4" id="status">
				<slot name="status-slot" />
				{#if status}
					<span class="whitespace-pre-line">{status}</span>
				{/if}
			</div>
		</svelte:fragment>
	</Panel>
</div>
