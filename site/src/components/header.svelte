<script lang="ts">
	import { fade, blur, fly, slide, scale } from 'svelte/transition';
	import { readable, writable, get } from 'svelte/store';

	import Ripple from '$components/ripple.svelte';
	import { Environment, useMediaQuery } from '$lib/Common';

	import { onMount } from 'svelte';

	let menuOpen: boolean = false;
	let menuButton: HTMLButtonElement | undefined = undefined;

	function closeMenu(e: Event): void {
		if (menuButton?.contains(<any>e.target)) return;
		if (menuOpen) menuOpen = false;
	}

	const darkMode = Environment.darkMode;

	function toggleTheme(): void {
		Environment.setTheme(!get(darkMode));
	}

	const contrastRequested = Environment.contrastRequested;

	onMount(() => {
		Environment.setTheme(get(darkMode));
	});
</script>

<svelte:body on:input={closeMenu} on:click={closeMenu} />
<svelte:window on:resize={(e) => (menuOpen = false)} />

<header class="p-1 glass px-4 md:px-8">
	<nav class="container flex justify-between h-16 mx-auto content-center text-center">
		<div class="flex items-center">
			<Ripple classList="text-xl flex h-full font-medium leading-loose" escapeParent={true}>
				<a rel="noopener noreferrer" href="/" aria-label="Back to homepage"> Dylan Langston.com </a>
			</Ripple>
		</div>

		<div class="flex content-center justify-end mr-0 ml-auto">
			{#if !$contrastRequested}
			<label
				class="theme-toggle h-fit my-auto rounded-full p-2 mx-2 hover:shadow-md hover:bg-rainbow"
				title="Toggle theme"
			>
				<Ripple classList={'theme-toggle'} fullscreen={true}>
					<input
						type="checkbox"
						checked={$darkMode}
						on:change={(e) => toggleTheme()}
					/>
					<span class="theme-toggle-sr">Toggle theme</span>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						aria-hidden="true"
						class="theme-toggle__within"
						height="24px"
						width="24px"
						viewBox="0 0 32 32"
						fill="currentColor"
					>
						<clipPath id="theme-toggle__within__clip">
							<path d="M0 0h32v32h-32ZM6 16A1 1 0 0026 16 1 1 0 006 16" />
						</clipPath>
						<g clip-path="url(#theme-toggle__within__clip)">
							<path
								d="M30.7 21.3 27.1 16l3.7-5.3c.4-.5.1-1.3-.6-1.4l-6.3-1.1-1.1-6.3c-.1-.6-.8-.9-1.4-.6L16 5l-5.4-3.7c-.5-.4-1.3-.1-1.4.6l-1 6.3-6.4 1.1c-.6.1-.9.9-.6 1.3L4.9 16l-3.7 5.3c-.4.5-.1 1.3.6 1.4l6.3 1.1 1.1 6.3c.1.6.8.9 1.4.6l5.3-3.7 5.3 3.7c.5.4 1.3.1 1.4-.6l1.1-6.3 6.3-1.1c.8-.1 1.1-.8.7-1.4zM16 25.1c-5.1 0-9.1-4.1-9.1-9.1 0-5.1 4.1-9.1 9.1-9.1s9.1 4.1 9.1 9.1c0 5.1-4 9.1-9.1 9.1z"
							/>
						</g>
						<path
							class="theme-toggle__within__circle"
							d="M16 7.7c-4.6 0-8.2 3.7-8.2 8.2s3.6 8.4 8.2 8.4 8.2-3.7 8.2-8.2-3.6-8.4-8.2-8.4zm0 14.4c-3.4 0-6.1-2.9-6.1-6.2s2.7-6.1 6.1-6.1c3.4 0 6.1 2.9 6.1 6.2s-2.7 6.1-6.1 6.1z"
						/>
						<path
							class="theme-toggle__within__inner"
							d="M16 9.5c-3.6 0-6.4 2.9-6.4 6.4s2.8 6.5 6.4 6.5 6.4-2.9 6.4-6.4-2.8-6.5-6.4-6.5z"
						/>
					</svg>
				</Ripple>
			</label>
			{/if}
		</div>
		<ul class="items-stretch hidden space-x-3 md:flex">
			<!-- <li class="flex">
				<Ripple classList={'flex h-full'} escapeParent={true}>
					<a
						rel="noopener noreferrer"
						href="/about"
						class="flex items-center -mb-1 border-b-4 border-transparent hover:border-rainbow"
						>About</a
					>
				</Ripple>
			</li> -->
			<li class="flex">
				<Ripple classList={'flex h-full'} escapeParent={true}>
					<a
						rel="noopener noreferrer"
						href="/contact"
						class="flex items-center -mb-1 border-b-4 border-transparent hover:border-rainbow"
						>Contact</a
					>
				</Ripple>
			</li>
		</ul>
		<div class="flex items-center justify-end md:hidden">
			{#key $darkMode}
				<button
					class="hamburger dark:darkburger hamburger--spin inline-flex gap-2 rounded-full px-2 pt-2 mx-2 hover:shadow-md hover:bg-rainbow cursor-pointer"
					class:darkburger={$darkMode}
					type="button"
					title="Menu"
					aria-label="Menu"
					aria-controls="navigation"
					aria-expanded={menuOpen}
					class:is-active={menuOpen}
					in:fade|local={{ duration: 250 }}
					on:click|preventDefault={(e) => {
						menuOpen = !menuOpen;
					}}
					bind:this={menuButton}
				>
					<Ripple classList={'relative inline-block'} escapeParent={true}>
						<span class="hamburger-box">
							<span class="hamburger-inner"></span>
						</span>
					</Ripple>
				</button>
			{/key}
		</div>
	</nav>
	<!-- Panel -->
	{#if menuOpen}
		<div
			class="top-10 right-0"
			in:slide|local={{ duration: 250 }}
			out:slide|local={{ duration: 250 }}
		>
			<!-- <Ripple color={'currentColor'}>
				<a
					href="/about"
					class="flex items-center rounded-md px-3 py-2 text-sm hover:shadow-md hover:bg-rainbow transition-colors duration-300"
					>About</a
				>
			</Ripple> -->
			<Ripple color={'currentColor'}>
				<a
					href="/contact"
					class="flex items-center rounded-md px-3 py-2 text-sm hover:shadow-md hover:bg-rainbow transition-colors duration-300"
					>Contact</a
				>
			</Ripple>
		</div>
	{/if}
</header>

<style>
	/*!
 * Toggle
 * @description Theme Toggle
 * @link https://toggles.dev/
 */
	.theme-toggle {
		--theme-toggle__within--duration: 500ms;
	}
	.theme-toggle__within * {
		transform-origin: center;
		transition: transform calc(var(--theme-toggle__within--duration)) cubic-bezier(0, 0, 0, 1.25);
	}
	.theme-toggle
		input[type='checkbox']:checked
		~ .theme-toggle__within
		.theme-toggle__within__circle,
	.theme-toggle--toggled:not(label).theme-toggle
		.theme-toggle__within
		.theme-toggle__within__circle {
		transform: scale(1.5);
	}
	.theme-toggle input[type='checkbox']:checked ~ .theme-toggle__within .theme-toggle__within__inner,
	.theme-toggle--toggled:not(label).theme-toggle
		.theme-toggle__within
		.theme-toggle__within__inner {
		transform: translate3d(3px, -3px, 0) scale(1.2);
	}
	.theme-toggle input[type='checkbox']:checked ~ .theme-toggle__within g path,
	.theme-toggle--toggled:not(label).theme-toggle .theme-toggle__within g path {
		transform: scale(0.65);
	}
	.theme-toggle {
		border: none;
		cursor: pointer;
	}
	.theme-toggle input[type='checkbox'] {
		display: none;
	}
	.theme-toggle .theme-toggle-sr {
		position: absolute;
		width: 1px;
		height: 1px;
		padding: 0;
		margin: -1px;
		overflow: hidden;
		clip: rect(0, 0, 0, 0);
		white-space: nowrap;
		border-width: 0;
	}
	@media (prefers-reduced-motion: reduce) {
		.theme-toggle:not(.theme-toggle--force-motion) * {
			transition: none !important;
		}
	}

	/*!
 * Hamburgers
 * @description Tasty CSS-animated hamburgers
 * @author Jonathan Suh @jonsuh
 * @site https://jonsuh.com/hamburgers
 * @link https://github.com/jonsuh/hamburgers
 */
	.hamburger {
		display: inline-block;
		cursor: pointer;
		transition-property: opacity, filter, background-color;
		transition-duration: 0.3s;
		transition-timing-function: linear;
		font: inherit;
		color: inherit;
		text-transform: none;
		border: 0;
		margin: 0;
		overflow: visible;
	}
	.hamburger .hamburger-inner,
	.hamburger .hamburger-inner::before,
	.hamburger .hamburger-inner::after {
		background-color: black;
	}

	.darkburger .hamburger-inner,
	.darkburger .hamburger-inner::before,
	.darkburger .hamburger-inner::after {
		background-color: white;
	}

	.hamburger-box {
		width: 24px;
		height: 24px;
		display: inline-block;
		position: relative;
	}

	.hamburger-inner {
		display: block;
		top: 50%;
		margin-top: -2px;
	}
	.hamburger-inner,
	.hamburger-inner::before,
	.hamburger-inner::after {
		width: 24px;
		height: 2px;
		border-radius: 4px;
		position: absolute;
		transition-property: transform;
		transition-duration: 0.15s;
		transition-timing-function: ease;
	}
	.hamburger-inner::before,
	.hamburger-inner::after {
		content: '';
		display: block;
	}
	.hamburger-inner::before {
		top: -7px;
	}
	.hamburger-inner::after {
		bottom: -7px;
	}
	.hamburger--spin .hamburger-inner {
		transition-duration: 0.22s;
		transition-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);
	}
	.hamburger--spin .hamburger-inner::before {
		transition:
			top 0.1s 0.25s ease-in,
			opacity 0.1s ease-in;
	}
	.hamburger--spin .hamburger-inner::after {
		transition:
			bottom 0.1s 0.25s ease-in,
			transform 0.22s cubic-bezier(0.55, 0.055, 0.675, 0.19);
	}

	.hamburger--spin.is-active .hamburger-inner {
		transform: rotate(225deg);
		transition-delay: 0.12s;
		transition-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);
	}
	.hamburger--spin.is-active .hamburger-inner::before {
		top: 0;
		opacity: 0;
		transition:
			top 0.1s ease-out,
			opacity 0.1s 0.12s ease-out;
	}
	.hamburger--spin.is-active .hamburger-inner::after {
		bottom: 0;
		transform: rotate(-90deg);
		transition:
			bottom 0.1s ease-out,
			transform 0.22s 0.12s cubic-bezier(0.215, 0.61, 0.355, 1);
	}
</style>
