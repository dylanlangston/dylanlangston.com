<script lang="ts">
	import Panel from '$components/panel.svelte';
	import Ripple from '$components/ripple.svelte';
	import Chat from '$components/chatbot.svelte';
	import { sleep } from '$lib/Common';
	import { pushState } from '$app/navigation';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { fade, blur, fly, slide, scale, crossfade } from 'svelte/transition';

	class Msg {
		public text: string;
		public user: MsgUserType;

		constructor(t: string, u: MsgUserType) {
			this.text = t;
			this.user = u;
		}
	}

	enum MsgUserType {
		user = 'user',
		bot = 'bot',
		system = 'sys'
	}

	let messages: Msg[] = [];
	let isSending = false;
	let isAnimating = false;

	function onAnimating(active: boolean) {
		isAnimating = active;
		chatArea?.scrollTo(0, chatArea.scrollHeight);
		
	}

	let inputText = '';

	let chatArea: HTMLDivElement | undefined;

    async function sendMessage() {
        if (inputText.trim() === '' || isSending) return;

        const text = inputText.trim();
        inputText = '';

        // Add user's message to the chat
        messages = [...messages, { text: text, user: MsgUserType.user }];
        setTimeout(() => chatArea?.scrollTo(0, chatArea.scrollHeight));
        isSending = true;

        try {
            const response = await fetch('https://api.dylanlangston.com/chat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ "Message": text })
            });

            if (response.ok) {
                const data = await response.json();
                messages = [
                    ...messages,
                    { text: data.Message.trim(), user: MsgUserType.bot }
                ];
            } else {
                throw new Error('Failed to send message');
            }
        } catch (er) {
            messages = [
                ...messages,
                { text: 'An error occurred! Please try again.', user: MsgUserType.system }
            ];
            console.error(er);
        }

        setTimeout(() => chatArea?.scrollTo(0, chatArea.scrollHeight));
        isSending = false;
    }

    onMount(() => {
        messages = [{ text: "Hey there, I'm Dylan Langston's digital twin. I can answer some questions about Dylan's background and experience as a .NET/C# Developer. What can I help you with today?", user: MsgUserType.bot }];
    });

    function handleKeyPress(event: KeyboardEvent) {
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault(); // Prevents adding a new line

            if (isAnimating || isSending || inputText == '') return;
            sendMessage();
        }
    }
</script>

<Panel>
	<svelte:fragment>
		<div class="space-y-3 sm:text-center mx-auto w-max max-w-[80vw] text-center">
			<p class="text-3xl font-semibold sm:text-4xl px-4">Chat with my Digital Twin</p>
		</div>
		<div
			bind:this={chatArea}
			class="mt-3 h-[50vh] max-w-screen-xl w-[80vw] mx-3 chatbox overflow-x-auto overflow-y-auto rounded-lg p-2 border border-black dark:border-white"
		>
			<Chat {messages} {isSending} animating={onAnimating} />
		</div>
		<div class="flex align-center mt-3 mx-3">
			<textarea
				rows="3"
				class="resize-none w-full mt-2 px-3 py-2 bg-transparent outline-none border border-black dark:border-white shadow-sm rounded-lg disabled:cursor-not-allowed placeholder:text-black/[.5]"
				bind:value={inputText}
				placeholder="Type your message..."
				on:keydown={handleKeyPress}
			></textarea>
			<div class="block mt-2 ml-2">
				<Ripple color={'currentColor'}>
					<button
						type="submit"
						on:click={sendMessage}
						disabled={isAnimating || isSending || inputText == ''}
						class="w-full px-5 py-2 font-medium rounded-lg duration-150 hover:shadow-md hover:bg-rainbow disabled:bg-transparent transition-colors disabled:cursor-not-allowed"
					>
						Send
					</button>
				</Ripple>
			</div>
		</div>
	</svelte:fragment>
</Panel>
