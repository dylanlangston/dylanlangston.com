<script lang="ts">
	import Typewriter from '$components/typewriter.svelte';
	import { fade, blur, fly, slide, scale, crossfade } from 'svelte/transition';
	import { quintOut, bounceInOut, backOut, elasticOut } from 'svelte/easing';

	export let messages: { text: string; user: string }[] = [];
	export let isSending = false;
	export let animating: ((active: boolean) => void) | undefined = undefined;

	function animateMessage(node: Element, { messageUser = '', sending = false } = {}) {
		if (messageUser == 'bot') {
			const animation = blur(node, { duration: 150, delay: 250 });
			node.classList.add('hidden');
			return () => {
				return {
					delay: animation?.delay,
					duration: animation?.duration,
					easing: animation?.easing,
					css: (t: number, u: number) => {
						if (u == 1) {
							node.classList.remove('hidden');
						}
						return (animation?.css ?? (() => ''))(t, u);
					}
				};
			};
		}
		else if (messageUser == 'sys') {
			return () => {
				return {
					delay: 0,
					duration: 0,
					easing: elasticOut,
					css: (t: number, u: number) => {
						return '';
					}
				}
			}
		}
		return slide(node, { duration: 250, axis: 'x' });
	}

	function onAnimating(active: boolean) {
		if (animating) animating(active);
	}
</script>

<div class="flex flex-col">
	{#each messages as message, index}
		<div
			in:animateMessage={{ messageUser: message.user }}
			class="message rounded-xl p-4"
			class:sys-message={message.user === 'sys'}
			class:user-message={message.user === 'user'}
			class:bot-message={message.user === 'bot'}
		>
			{#if message.user === 'sys'}
				<span class="whitespace-pre-line whitespace-nowrap">{message.text}</span>
			{:else if message.user === 'user'}
				<span class="whitespace-pre-line whitespace-nowrap">{message.text}</span>
			{:else}
				<span class="whitespace-pre-line whitespace-nowrap"
					><Typewriter
						phrase={message.text}
						rate={12}
						animating={onAnimating}
						stopBlinking={messages.length - 1 !== index}
					/></span
				>
			{/if}
		</div>
	{/each}
	{#if isSending}
		<div
			in:slide={{ duration: 250, delay: 100, axis: 'x' }}
			out:blur={{ duration: 150 }}
			class="message bot-message rounded-xl p-4"
		>
			<div class="block w-[100px]">
				<span class="chatbot-loader"></span>
			</div>
		</div>
	{/if}
</div>

<style>
	.message {
		overflow-x: auto;
		overflow-y: hidden;
		max-width: 90%;
		padding: 10px;
		margin-bottom: 10px;
		border-radius: 10px;
		backdrop-filter: blur(10px);
		border: 1px solid rgba(255, 255, 255, 0.18);
	}

	.sys-message {
		align-self: center;
		background-color: rgba(245, 128, 128, 0.15);
	}

	.user-message {
		align-self: flex-end;
		background-color: rgba(128, 245, 128, 0.15);
	}

	.bot-message {
		align-self: flex-start;
		background-color: rgba(128, 128, 245, 0.15);
	}

	.chatbot-loader {
		width: 12px;
		height: 12px;
		border-radius: 50%;
		display: block;
		margin: 15px auto;
		position: relative;
		box-sizing: border-box;
		animation: animloader 1s linear infinite alternate;
	}

	@keyframes animloader {
		0% {
			box-shadow:
				-38px -12px,
				-14px 0,
				14px 0,
				38px 0;
		}
		33% {
			box-shadow:
				-38px 0px,
				-14px -12px,
				14px 0,
				38px 0;
		}
		66% {
			box-shadow:
				-38px 0px,
				-14px 0,
				14px -12px,
				38px 0;
		}
		100% {
			box-shadow:
				-38px 0,
				-14px 0,
				14px 0,
				38px -12px;
		}
	}

	@keyframes typing {
		from {
			width: 0;
		}
		to {
			width: 100%;
		}
	}
</style>
