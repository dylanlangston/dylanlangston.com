<script lang="ts">
	import Header from '$components/header.svelte';
	import Footer from '$components/footer.svelte';

	import Emscripten from '$components/emscripten.svelte';

	import { page } from '$app/stores';
	import StatusContainer from '$components/status-container.svelte';
	import MouseCursor from '$components/mouse-cursor.svelte';

	import { onMount } from 'svelte';
	import { fade, blur, fly, slide, scale, crossfade } from 'svelte/transition';
	import { quintOut, bounceInOut, backOut, elasticOut } from 'svelte/easing';
	import { readable, writable, get } from 'svelte/store';
	import { Environment, useMediaQuery } from '$lib/Common';
	import ContextMenu from '$components/context-menu.svelte';
	import Modal from '$components/modal.svelte';
	import CookiePrompt from '$components/cookie-prompt.svelte';
	import CookieSettings from '$components/cookie-settings.svelte';
	import { CookieSettingsManager } from '$lib/CookieSettingsManager';

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

	let showCookieModal = false;
	let showInitialCookieModal = true;

	let mobile: typeof Environment.isMobile | undefined = undefined;
	let accessibilityRequested: typeof Environment.accessibilityRequested | undefined = undefined;
	let contrastRequested: typeof Environment.contrastRequested | undefined = undefined;

	onMount(() => {
		mobile = Environment.isMobile;
		accessibilityRequested = Environment.accessibilityRequested;
		contrastRequested = Environment.contrastRequested;
		loaded = true;

		(<any>window).dataLayer = (<any>window).dataLayer || [];
		gtag = (...args: any[]) => {
			(<any>window).dataLayer.push(args);
		};

		// Denied by default
		gtag('consent', 'default', {
			ad_storage: 'granted',
			ad_user_data: 'granted',
			ad_personalization: 'granted',
			analytics_storage: 'granted',
			wait_for_update: 500
		});
		gtag('js', new Date());
		gtag('config', 'G-VXRC4ZZ8Q9');

		const { userAccepted, analytics } = CookieSettingsManager.getPreferences();

		showInitialCookieModal = !userAccepted;

		if (!userAccepted) setTimeout(() => (showCookieModal = true), 2500);

		if (analytics) allConsentGranted();
		else allConsentDenied();
	});

	let gtag: (...args: any[]) => void;

	function allConsentGranted() {
		console.log('access granted');
		gtag('consent', 'update', {
			ad_user_data: 'granted',
			ad_personalization: 'granted',
			ad_storage: 'granted',
			analytics_storage: 'granted'
		});
	}

	function allConsentDenied() {
		console.log('access denied');
		gtag('consent', 'update', {
			ad_user_data: 'denied',
			ad_personalization: 'denied',
			ad_storage: 'denied',
			analytics_storage: 'denied'
		});
	}
</script>

<svelte:head>
	{#if Environment.Dev}
		<link rel="preload" href="dylanlangston.com.wasm.map" as="fetch" />
	{/if}
	<link rel="preload" href="dylanlangston.com.wasm" as="fetch" />

	<!-- GTAG -->
	<script
		async
		src="https://www.googletagmanager.com/gtag/js?id=G-VXRC4ZZ8Q9"
	></script>
	{#if !loaded}
		<style>
			.jsonly {
				display: none;
			}
		</style>
	{/if}
</svelte:head>

<div
	class="w-full h-full {$mobile || $accessibilityRequested || $contrastRequested
		? ''
		: !loaded
			? 'cursor-progress'
			: 'cursor-none'}"
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
						<div class="flex h-full justify-center">
							<slot />
						</div>
					</div>
				</main>
			{/key}
			<div class="w-screen" in:blur|local={{ duration: 500, delay: 250 }}>
				<Footer
					openCookieSettings={() => {
						showCookieModal = true;
					}}
				/>
			</div>
		</div>
		{#if showCookieModal}
			<Modal showModal={true}>
				<svelte:fragment>
					{#if showInitialCookieModal}
						<CookiePrompt
							accept={() => {
								showInitialCookieModal = false;
								showCookieModal = false;
								CookieSettingsManager.savePreferences({
									analytics: true,
									userAccepted: true
								});

								allConsentGranted();
							}}
							settings={() => {
								showInitialCookieModal = false;
							}}
						/>
					{:else}
						<div in:blur|local={{ duration: 250 }}>
							<CookieSettings
								onSave={({ analytics }) => {
									CookieSettingsManager.savePreferences({
										analytics: analytics,
										userAccepted: true
									});

									if (analytics) allConsentGranted();
									else allConsentDenied();
									showCookieModal = false;
								}}
							/>
						</div>
					{/if}
				</svelte:fragment>
			</Modal>
		{:else if !$mobile && !$accessibilityRequested && !$contrastRequested}
			<!-- <ContextMenu/> -->
			<MouseCursor />
		{/if}
	{:else}
		<main>
			<noscript class="flex flex-col h-full">
				<div
					class="absolute flex top-0 bottom-0 left-0 right-0 items-center justify-center pointer-events-none"
				>
					<StatusContainer>
						<svelte:fragment slot="status-slot">
							<h1>This site requires JavaScript.<br />Please enable to continue.</h1>
						</svelte:fragment>
					</StatusContainer>
				</div>
			</noscript>
			<div
				class="jsonly absolute top-0 left-0 w-screen h-screen flex align-center animate-[fade-in_5s]"
			>
				<div class="loader m-auto" class:invisible={loaded} out:animateOut={{ key }}></div>
			</div>
		</main>
	{/if}
</div>
