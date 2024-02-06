<script>
	import Header from '../components/header.svelte';
	import Footer from '../components/footer.svelte';

	import Emscripten from '../components/emscripten.svelte';

	import { partytownSnippet } from '@builder.io/partytown/integration';

	import { page } from '$app/stores';
	import StatusContainer from '../components/status-container.svelte';
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

<Header />

<Emscripten />

{#if $page.error}
	<main>
		<slot />
	</main>
{:else}
	<noscript>
		<style>
			.jsonly {
				display: none;
			}
		</style>
		<StatusContainer>
			<svelte:fragment slot="status-slot">
				<h1>Please enable Javascript.</h1>
			</svelte:fragment>
		</StatusContainer>
	</noscript>
	<main class="jsonly">
		<slot />
	</main>
{/if}

<Footer />
