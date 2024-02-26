<script lang="ts">
	import Header from '../components/header.svelte';
	import Footer from '../components/footer.svelte';

	import Emscripten from '../components/emscripten.svelte';

	import { partytownSnippet } from '@builder.io/partytown/integration';

	import { page } from '$app/stores';
	import StatusContainer from '../components/status-container.svelte';
	import MouseCursor from '../components/mouse-cursor.svelte';

	import { onMount } from 'svelte';
	import { fade, blur, fly, slide, scale, crossfade } from 'svelte/transition';
	import { quintOut, bounceInOut, backOut, elasticOut } from 'svelte/easing';
	import { readable, writable, get } from 'svelte/store';
	import { Environment, useMediaQuery } from '$lib/Common';
	import ContextMenu from '../components/context-menu.svelte';

	const key = 'main';
	const [send, receive] = crossfade({
		duration: 750,
		easing: backOut
	});
	const animateIn = (node: any, params: { key: string }) =>
		preventOverFlowOnAnimation(send, node, params);
	const animateOut = (node: any, params: { key: string }) =>
		preventOverFlowOnAnimation(receive, node, params);
	function preventOverFlowOnAnimation(
		originalAnimation: (
			node: any,
			params: { key: string }
		) => () => {
			delay?: number;
			duration?: number;
			easing?: any;
			css?: (t: number, u: number) => string;
		},
		node: any,
		params: { key: string }
	) {
		const config = originalAnimation(node, params);
		return () => {
			const animation = config();
			const n = node;
			const p = params;
			return {
				delay: animation?.delay,
				duration: animation?.duration,
				easing: animation?.easing,
				css: (t: number, u: number) => {
					// Set body overflow to hidden when animating
					if (u == 0) {
						const initialOverflowMain = main!.style.overflow;
						const initialOverflowBody = document.body.style.overflow;
						main!.style.overflow = 'hidden';
						document.body.style.overflow = 'hidden';
						setTimeout(() => {
							main!.style.overflow = initialOverflowMain;
							document.body.style.overflow = initialOverflowBody;
						}, animation?.duration ?? 0);
					}
					return (animation?.css ?? (() => ''))(t, u);
				}
			};
		};
	}

	let loaded: boolean = false;
	let main: HTMLDivElement | undefined = undefined;

	let mobile: typeof Environment.isMobile | undefined = undefined;
	let accessibilityRequested: typeof Environment.accessibilityRequested | undefined = undefined;
	let contrastRequested: typeof Environment.contrastRequested | undefined = undefined;

	onMount(() => {
		mobile = Environment.isMobile;
		accessibilityRequested = Environment.accessibilityRequested;
		contrastRequested = Environment.contrastRequested;
		loaded = true;
	});
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

<div
	class="w-full h-full {($mobile || $accessibilityRequested || $contrastRequested) ? '' : !loaded ? 'cursor-progress' : 'cursor-none'}"
>
	{#if loaded}
		<div
			class="flex flex-col h-full w-full overflow-x-hidden overflow-y-auto"
			in:animateIn={{ key }}
			bind:this={main}
		>
			{#if !$accessibilityRequested && !$contrastRequested}
				<Emscripten />
			{/if}
			<div class="w-screen" in:blur|local={{ duration: 500, delay: 250 }}>
				<Header />
			</div>
			{#key $page.url.pathname + loaded + $page.error}
				<main
					class="flex-1 md:w-screen"
					in:blur|local={{ duration: 250, delay: 50, opacity: 0.25 }}
				>
					<div class="overflow-x-auto h-full">
						<div class="flex h-full">
							<slot />
						</div>
					</div>
				</main>
			{/key}
			<div class="w-screen" in:blur|local={{ duration: 500, delay: 250 }}>
				<Footer />
			</div>
		</div>
		{#if !$mobile && !$accessibilityRequested && !$contrastRequested}
			<ContextMenu/>
			<MouseCursor />
		{/if}
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
						<h1>This site requires JavaScript.<br />Please enable to continue.</h1>
					</svelte:fragment>
				</StatusContainer>
			</main>
		</noscript>
		<div class="jsonly absolute top-1/2 left-1/2" out:animateOut={{ key }}>
			<div class="loader"></div>
		</div>
	{/if}
</div>
