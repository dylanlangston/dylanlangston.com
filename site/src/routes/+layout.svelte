<script>
	import Header from '../components/header.svelte';
	import Footer from '../components/footer.svelte';

    import Emscripten from "../components/emscripten.svelte";

	import { partytownSnippet } from '@builder.io/partytown/integration';
</script>

<svelte:head>
    <link rel="prefetch" href="dylanlangston.com.wasm" />

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

<main>
	<slot />
</main>

<Footer />
