<script lang="ts">
	import { Environment } from '$lib/Common';
	import { onMount } from 'svelte';
	import { fade, blur, fly, slide, scale, crossfade } from 'svelte/transition';
	import Panel from '../components/panel.svelte';

	let loaded: boolean = false;

	onMount(() => (loaded = true));

	const mobile = Environment.isMobile;
</script>

<Panel>
	<svelte:fragment>
		<div class="space-y-3 mx-2">
			{#if loaded}
				<h1 class="text-center text-2xl lg:text-6xl font-bold">
					Hello {$mobile ? 'Mobile' : 'Desktop'} HTML World
				</h1>
			{/if}
		</div>
	</svelte:fragment>
</Panel>
