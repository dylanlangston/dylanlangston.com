<script lang="ts">
	export let messages: { text: string; user: string }[] = [];
	export let isSending = false;
</script>

<div class="flex flex-col">
	{#each messages as message}
		<div
			class="{message.user === 'user'
				? 'message user-message'
				: 'message bot-message'} rounded-xl p-4"
		>
			<span class="whitespace-pre-line whitespace-nowrap">{message.text}</span>
		</div>
	{/each}
	{#if isSending}
		<div class="message bot-message rounded-xl p-4">
			<span class="typing-animation">...</span>
		</div>
	{/if}
</div>

<style>
	.message {
		overflow-y: scroll;
		width: 90%;
		padding: 10px;
        margin-bottom: 10px;
		border-radius: 10px;
		backdrop-filter: blur(10px);
		border: 1px solid rgba(255, 255, 255, 0.18);
	}

	.user-message {
		align-self: flex-end;
		background-color: rgba(245, 128, 128, 0.15);
	}

	.bot-message {
		align-self: flex-start;
		background-color: rgba(128, 128, 245, 0.15);
	}

	.typing-animation {
		display: inline-block;
		overflow: hidden;
		animation: typing 1s steps(10, end) infinite;
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
