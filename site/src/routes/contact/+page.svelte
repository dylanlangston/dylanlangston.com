<script lang="ts">
	import Panel from '../../components/panel.svelte';
	import Ripple from '../../components/ripple.svelte';

	let firstName = '';
	let lastName = '';
	let email = '';
	let phone = '';
	let message = '';

	async function handleSubmit(event) {
		alert('submit');

		event.preventDefault();

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
			} else {
				alert('Failed to send message. Please try again later.');
				console.error(response.statusText);
			}
		} catch (error) {
			alert('Failed to send message. Please try again later.');
			console.error(error);
		}
	}
</script>

<Panel>
	<svelte:fragment>
		<div class="max-w-lg space-y-3 sm:text-center mx-auto w-max">
			<p class="text-3xl font-semibold sm:text-4xl">Get in touch</p>
		</div>
		<div class="mt-6 max-w-lg mx-5">
			<form on:submit={handleSubmit} class="space-y-5">
				<div class="flex flex-col items-center gap-y-5 gap-x-6 [&>*]:w-full sm:flex-row">
					<div>
						<label class="font-medium"> First name </label>
						<input
							type="text"
							required
							bind:value={firstName}
							class="w-full mt-2 px-3 py-2 bg-transparent outline-none border border-black dark:border-white shadow-sm rounded-lg"
						/>
					</div>
					<div>
						<label class="font-medium"> Last name </label>
						<input
							type="text"
							required
							bind:value={lastName}
							class="w-full mt-2 px-3 py-2 bg-transparent outline-none border border-black dark:border-white shadow-sm rounded-lg"
						/>
					</div>
				</div>
				<div>
					<label class="font-medium"> Email </label>
					<input
						type="email"
						required
						bind:value={email}
						class="w-full mt-2 px-3 py-2 bg-transparent outline-none border border-black dark:border-white shadow-sm rounded-lg"
					/>
				</div>
				<div>
					<label class="font-medium"> Phone number (optional) </label>
					<input
						type="tel"
						placeholder="+1 234-567-8901"
						pattern="\+?([0-9]{1}[- ])?[0-9]{3}[- ][0-9]{3}[- ][0-9]{4}"
						bind:value={phone}
						class="w-full mt-2 px-3 py-2 bg-transparent outline-none border border-black dark:border-white shadow-sm rounded-lg placeholder:text-black/[.5]"
					/>
				</div>
				<div>
					<label class="font-medium"> Message </label>
					<textarea
						required
						bind:value={message}
						class="w-full mt-2 h-36 px-3 py-2 resize-none appearance-none bg-transparent outline-none border border-black dark:border-white shadow-sm rounded-lg"
					></textarea>
				</div>
				<Ripple color={'currentColor'}>
					<button
						type="submit"
						class="w-full px-4 py-2 font-medium rounded-lg duration-150 hover:shadow-md hover:bg-rainbow transition-colors"
					>
						Submit
					</button>
				</Ripple>
			</form>
		</div>
	</svelte:fragment>
</Panel>
