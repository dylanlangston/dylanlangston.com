<script lang="ts">
	import Header from '../components/header.svelte';
	import Footer from '../components/footer.svelte';
	import Loader from '../components/loader.svelte';

	import Emscripten from '../components/emscripten.svelte';

	import { partytownSnippet } from '@builder.io/partytown/integration';

	import { page } from '$app/stores';
	import StatusContainer from '../components/status-container.svelte';

	import { onMount } from 'svelte';
	import { fade, blur, fly, slide, scale, crossfade } from 'svelte/transition';

	let loaded: boolean = false;

	onMount(() => (loaded = true));
</script>

<svelte:head>
	<!-- GTAG Partytown 🕶️ -->
	<script>
		// Forward the necessary functions to the web worker layer
		partytown = {
			forward: ['dataLayer.push']
		};
	</script>
	{@html '<script>' + partytownSnippet() + '</script>'}
	<script
		type="text/partytown"
		async
		src="https://www.googletagmanager.com/gtag/js?id=G-VXRC4ZZ8Q9"
	></script>
	<script type="text/partytown">
		window.dataLayer = window.dataLayer || [];
		function gtag() {
			dataLayer.push(arguments);
		}
		gtag('js', new Date());

		gtag('config', 'G-VXRC4ZZ8Q9');
	</script>
</svelte:head>

{#if loaded}
	<div class="flex flex-col h-screen" in:scale={{ duration: $page.error ? 0 : 750 }}>
		<Header />
		<Emscripten />
		{#key $page.url.pathname + loaded + $page.error}
			<main
				class="flex-1 {loaded ? '' : 'opacity-0'}"
				in:blur={{ duration: 250, delay: 50 }}
			>
				<slot />
			</main>
		{/key}
		<Footer />
	</div>
{:else}
	<noscript class="flex flex-col h-screen">
		<style>
			.jsonly {
				display: none;
			}
		</style>
		<Header />
		<main class="flex-1">
			<StatusContainer>
				<svelte:fragment slot="status-slot">
					<h1>Please enable Javascript.</h1>
				</svelte:fragment>
			</StatusContainer>
		</main>
		<Footer />
	</noscript>
	<div class="jsonly absolute top-1/2 left-1/2">
		<Loader />
	</div>
{/if}
