<script lang="ts">
	import Panel from '$components/panel.svelte';
	import Ripple from '$components/ripple.svelte';
	import { sleep } from '$lib/Common';
	import { pushState } from '$app/navigation';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { fade, blur, fly, slide, scale, crossfade } from 'svelte/transition';

	onMount(() => {
		firstName = (<any>$page.state).firstName;
		lastName = (<any>$page.state).lastName;
		email = (<any>$page.state).email;
		phone = (<any>$page.state).phone;
		message = (<any>$page.state).message;
	});

	let firstName = '';
	let lastName = '';
	let email = '';
	let phone = '';
	let message = '';

	let submitting = false;

	async function handleChange(event: Event) {
		pushState($page.url, {
			firstName: firstName,
			lastName: lastName,
			email: email,
			phone: phone,
			message: message
		});
	}

	async function handleSubmit(
		event: SubmitEvent & {
			currentTarget: EventTarget & HTMLFormElement;
		}
	) {
		event.preventDefault();

		submitting = true;

		const formData = {
			firstName,
			lastName,
			email,
			phone,
			message
		};

		try {
			const response = await fetch('https://api.dylanlangston.com/contact', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify(formData)
			});

			if (response.ok) {
				alert('Message sent successfully!');
				firstName = '';
				lastName = '';
				email = '';
				phone = '';
				message = '';
			} else {
				alert('Failed to send message. Please try again later.');
				console.error(response.statusText);
			}
		} catch (error) {
			alert('Failed to send message. Please try again later.');
			console.error(error);
		} finally {
			submitting = false;
		}
	}
</script>

<Panel>
	<svelte:fragment>
		<div class="max-w-lg space-y-3 sm:text-center mx-auto w-max">
			<p class="text-3xl font-semibold sm:text-4xl">Get in touch</p>
		</div>
		<div class="mt-6 max-w-lg mx-5">
			<form
				on:submit={handleSubmit}
				on:change={handleChange}
				class="space-y-5"
				class:opacity-40={submitting}
			>
				<div class="flex flex-col items-center gap-y-5 gap-x-6 *:w-full sm:flex-row">
					<div>
						<label for="firstName" class="font-medium"> First name </label>
						<input
							id="firstName"
							type="text"
							required
							bind:value={firstName}
							disabled={submitting}
							name="firstName"
							autocomplete="on"
							class="w-full mt-2 px-3 py-2 bg-transparent outline-hidden border border-black dark:border-white shadow-2xs rounded-lg disabled:cursor-not-allowed"
						/>
					</div>
					<div>
						<label for="lastName" class="font-medium"> Last name </label>
						<input
							id="lastName"
							type="text"
							required
							bind:value={lastName}
							disabled={submitting}
							name="lastName"
							autocomplete="on"
							class="w-full mt-2 px-3 py-2 bg-transparent outline-hidden border border-black dark:border-white shadow-2xs rounded-lg disabled:cursor-not-allowed"
						/>
					</div>
				</div>
				<div>
					<label for="email" class="font-medium"> Email </label>
					<input
						id="email"
						type="email"
						required
						placeholder="mail@example.com"
						bind:value={email}
						disabled={submitting}
						name="email"
						autocomplete="on"
						class="w-full mt-2 px-3 py-2 bg-transparent outline-hidden border border-black dark:border-white shadow-2xs rounded-lg placeholder:text-black/[.5] disabled:cursor-not-allowed"
					/>
				</div>
				<div>
					<label for="phone" class="font-medium"> Phone number (optional) </label>
					<input
						id="phone"
						type="tel"
						placeholder="+1 234-567-8901"
						pattern="\+?([0-9]{1}[- ])?[0-9]{3}[- ][0-9]{3}[- ][0-9]{4}"
						bind:value={phone}
						disabled={submitting}
						name="phone"
						autocomplete="on"
						class="w-full mt-2 px-3 py-2 bg-transparent outline-hidden border border-black dark:border-white shadow-2xs rounded-lg placeholder:text-black/[.5] disabled:cursor-not-allowed"
					/>
				</div>
				<div>
					<label for="message" class="font-medium"> Message </label>
					<textarea
						id="message"
						required
						bind:value={message}
						disabled={submitting}
						name="message"
						class="w-full mt-2 h-36 px-3 py-2 resize-none appearance-none bg-transparent outline-hidden border border-black dark:border-white shadow-2xs rounded-lg disabled:cursor-not-allowed"
					></textarea>
				</div>
				<Ripple color={'currentColor'}>
					<button
						type="submit"
						disabled={submitting}
						class="w-full px-4 py-2 font-medium rounded-lg duration-150 hover:shadow-md hover:bg-rainbow disabled:bg-transparent transition-colors disabled:cursor-not-allowed"
					>
						Submit
					</button>
				</Ripple>
			</form>
			{#if submitting}
				<div class="absolute top-0 left-0 w-full h-full flex align-center">
					<div
						class="loader m-auto"
						in:blur|local={{ duration: 250 }}
						out:blur|local={{ duration: 250 }}
					></div>
				</div>
			{/if}
		</div>
	</svelte:fragment>
</Panel>
