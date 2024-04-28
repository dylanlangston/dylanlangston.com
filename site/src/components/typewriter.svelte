<script lang="ts">
	import { Environment } from '$lib/Common';
	import { onMount } from 'svelte';

	onMount(() => setTimeout(() => typing(), delay));

	export let phrase: string;
	export let delay: number = 0;
	export let rate: number = 150;
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
	{typedChar} 
	{#if index > 0 && (index < phrase.length || !stopBlinking)}
		<span class="blink">|</span>
	{/if}
{:else}
	{phrase}
	{#if !stopBlinking}
		<span class="blink">|</span>
	{/if}
{/if}

<style>
	.blink {
		animation: blinking-cursor 300ms infinite alternate;
	}
	@keyframes blinking-cursor {
		0%, 50% {
			opacity: 0;
		}
		51%, 100% {
			opacity: 1;
		}
	}
</style>