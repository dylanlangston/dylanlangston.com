<script>
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import StatusContainer from '../components/status-container.svelte';

	onMount(() => {
		document.title = 'Error' + ($page.error?.message ? ' - ' + $page.error.message : '');
	});
</script>

<div
	class="flex items-center justify-center pointer-events-none"
>
	<StatusContainer>
		<svelte:fragment slot="status-slot">
			<h1>¯\_(ツ)_/¯<br />An error has occurred, sorry!</h1>
			{#if $page.error}
				<hr class="h-0.5 lg:h-1 bg-black dark:bg-white border-transparent rounded-lg" />
				<div class="text-xl lg:text-3xl font-normal text-left px-4 pt-2">
					{#if $page?.status}
						<p><i class="italic">Status:</i> {$page?.status}</p>
					{/if}
					{#if $page?.error?.message}
						<p><i class="italic">Error Message:</i> {$page?.error?.message}</p>
					{/if}
				</div>
			{/if}
		</svelte:fragment>
	</StatusContainer>
</div>
