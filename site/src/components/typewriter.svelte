<script lang="ts">
	import { Environment } from '$lib/Common';
	import { onMount } from 'svelte';

	onMount(() => setTimeout(() => typing(), delay));

	export let phrase: string;
	export let delay: number = 0;
	export let rate: number = 100;
	export let disabled: boolean = false;
	export let stopBlinking: boolean = true;
	let typedChar = '';
	let index = 0;
	let typewriter: number;

	const typeChar = () => {
		if (index < phrase.length) {
			typedChar += phrase[index];
			index += 1;
		} else {
			stopTyping();
			return;
		}
	};

	const typing = () => (typewriter = setInterval(typeChar, rate));

	const stopTyping = () => {
		clearInterval(typewriter);
	};

	$: accessibilityRequested = Environment.accessibilityRequested;
</script>

{#if !$accessibilityRequested && !disabled}
	{typedChar}{#if index > 0 && (index < phrase.length || !stopBlinking)}<span class="cursor" class:blink={index == phrase.length} aria-hidden="true">|</span>{/if}
{:else}
	{phrase}{#if !stopBlinking}<span class="cursor blink" aria-hidden="true">|</span>{/if}
{/if}

<style>
	.cursor {
		display: inline-flex;
		font-weight: 400;
		@apply not-italic;
	}
	.blink {
		animation: blinking-cursor 0.7s infinite;
		opacity: 1;
	}
	@keyframes blinking-cursor {
		50% {
			opacity: 0;
		}
	}
</style>