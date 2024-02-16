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
	import { quintOut, bounceInOut, backOut, elasticOut } from 'svelte/easing';
	import { Environment } from '$lib/Common';

	const key = 'main';
	const [send, receive] = crossfade({
		duration: 750,
		easing: backOut,
	});
	const animateIn = (node: any, params: { key: string }) => preventOverFlowOnAnimation(send, node, params)
	const animateOut = (node: any, params: { key: string }) => preventOverFlowOnAnimation(receive, node, params)
	function preventOverFlowOnAnimation(originalAnimation: (node: any, params: { key: string }) => () => {
		delay?: number,
		duration?: number,
		easing?: any,
		css?: (t: number, u: number) => string,
	}, node: any, params: { key: string }) {
		const config = originalAnimation(node, params);
		return () => {
			const animation = config();
			return {
				delay: animation?.delay,
				duration: animation?.duration,
				easing: animation?.easing,
				css: (t: number, u: number) => {
					// Set body overflow to hidden when animating
					if (u == 0) {
						const initialOverflow = document.body.style.overflow;
						document.body.style.overflow = "hidden";
						setTimeout(() => {
							document.body.style.overflow = initialOverflow;
						}, animation?.duration ?? 0);
					}
					
					return (animation?.css ?? (() => ""))(t, u);
				}
			};
		};
	}


	let loaded: boolean = false;

	onMount(() => (loaded = true));
</script>

<svelte:head>
	{#if Environment.Dev}
		<link rel="preload" href="dylanlangston.com.wasm.map" as="fetch" />
	{/if}
	<link rel="preload" href="dylanlangston.com.wasm" as="fetch" />

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
	<div class="flex flex-col h-full" in:animateIn={{ key }}>
		<Header />
		<Emscripten />
		{#key $page.url.pathname + loaded + $page.error}
			<main class="flex-1" in:blur|local={{ duration: 250, delay: 50, opacity: 0.25 }}>
				<slot />
			</main>
		{/key}
		<Footer />
	</div>
{:else}
	<noscript class="flex flex-col h-full">
		<style>
			.jsonly {
				display: none;
			}
		</style>
		<main class="flex-1">
			<StatusContainer>
				<svelte:fragment slot="status-slot">
					<h1>Please enable Javascript.</h1>
				</svelte:fragment>
			</StatusContainer>
		</main>
	</noscript>
	<div class="jsonly absolute top-1/2 left-1/2" out:animateOut={{ key }}>
		<Loader />
	</div>
{/if}