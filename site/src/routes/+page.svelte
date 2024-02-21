<script lang="ts">
	import { Environment } from '$lib/Common';
	import { onMount } from 'svelte';
	import { fade, blur, fly, slide, scale, crossfade } from 'svelte/transition';

	let loaded: boolean = false;

	onMount(() => (loaded = true));
</script>

<div class="max-w-screen-xl mx-auto px-4 md:px-8 py-8">
	<div class="py-4 mx-auto w-fit rounded-lg glass">
		<div class="max-w-lg space-y-3 sm:text-center mx-2 w-max">
			{#if loaded}
				<h1 class="text-center text-2xl lg:text-6xl font-bold">
					Hello {Environment.isMobile ? 'Mobile' : 'Desktop'} HTML World
				</h1>
			{/if}
		</div>
	</div>
</div>
