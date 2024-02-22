<script lang="ts">
	import { Environment } from '$lib/Common';
	import { spring } from 'svelte/motion';
	import { readable, writable, get } from 'svelte/store';
	import { onMount } from 'svelte';

	let coords1 = spring(
		{ x: 0, y: 0 },
		{
			stiffness: 0.05,
			damping: 0.2
		}
	);

	let coords2 = spring(
		{ x: 0, y: 0 },
		{
			stiffness: 0.1,
			damping: 0.35
		}
	);

	let size = spring(10, {
		stiffness: 0.05,
		damping: 0.35,
		
	});

	let visible: boolean = false;

	const mobile = Environment.isMobile;

	let loaded: boolean = false;

	onMount(() => (loaded = true));
</script>

<svelte:body
	on:mouseout={(e) => {
		if (
			e.clientY <= 0 ||
			e.clientX <= 0 ||
			e.clientX >= window.innerWidth ||
			e.clientY >= window.innerHeight
		) {
			visible = false;
			size.set(0);
		}
	}}
	on:mousemove|capture|stopPropagation|nonpassive={(e) => {
		coords1.set({ x: e.clientX, y: e.clientY }, { hard: !visible });
		coords2.set({ x: e.clientX, y: e.clientY }, { hard: !visible });
		if (!visible) {
			size.set(0);
		} else if (get(size) == 0) {
			size.set(10);
		}
		visible = getComputedStyle(e.target).cursor == 'none';
	}}
	on:mousedown|capture|stopPropagation|passive={(e) => {
		if (visible) size.set(30);
	}}
	on:mouseup|capture|stopPropagation|passive={(e) => {
		if (visible) size.set(10);
	}}
/>

{#if !$mobile}
	<svg class="absolute top-0 left-0 w-screen h-screen pointer-events-none animate-background">
		<circle
			cx={$coords1.x}
			cy={$coords1.y}
			r={$size}
			class="stroke-rainbow"
			stroke-width="3"
			fill-opacity="0"
		/>
		<circle cx={$coords2.x} cy={$coords2.y} r={$size / 3} fill="black" class="stroke-white/[.5]"
		stroke-width="0.5" />
	</svg>
{/if}
