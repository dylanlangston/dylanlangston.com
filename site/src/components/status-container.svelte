<script lang="ts">
	import { fade, blur, fly, slide, scale } from 'svelte/transition';
	export let status: string | undefined = undefined;
</script>

<div
	in:fade={{ delay: 250, duration: 300 }}
	out:fade
	class="absolute flex top-0 bottom-0 left-0 right-0 items-center justify-center pointer-events-none -z-50"
>
	<div id="status-container" class="rounded-lg bg-green-light/[.5] shadow-xl p-8 m-8">
		<div class="select-none text-center text-2xl lg:text-6xl font-bold" id="status">
			<slot name="status-slot" />
			{#if status}
				<span class="whitespace-pre-line">{status}</span>
			{/if}
		</div>
	</div>
</div>
