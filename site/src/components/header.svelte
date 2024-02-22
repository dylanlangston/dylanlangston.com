<script lang="ts">
	import { fade, blur, fly, slide, scale } from 'svelte/transition';

	import Panel from './panel.svelte';

	let menuOpen: boolean = false;
	let menuButton: HTMLButtonElement | undefined = undefined;

	function closeMenu(e: Event): void {
		if (menuButton?.contains(<any>e.target)) return;
		if (menuOpen) menuOpen = false;
	}
</script>

<svelte:body on:input={closeMenu} on:click={closeMenu} />

<header class="p-1 glass px-4 md:px-8">
	<nav class="container flex justify-between h-16 mx-auto">
		<a rel="noopener noreferrer" href="/" aria-label="Back to homepage" class="flex items-center">
			Dylan Langston.com
		</a>
		<ul class="items-stretch hidden space-x-3 md:flex">
			<li class="flex">
				<a
					rel="noopener noreferrer"
					href="/about"
					class="flex items-center -mb-1 border-b-4 border-transparent hover:border-rainbow">About</a
				>
			</li>
			<li class="flex">
				<a
					rel="noopener noreferrer"
					href="/contact"
					class="flex items-center -mb-1 border-b-4 border-transparent hover:border-rainbow">Contact</a
				>
			</li>
		</ul>
		<div class="flex items-center justify-end md:hidden">
			<div class="relative inline-block">
				<!-- Button -->
				<button
					class="hamburger hamburger--spin inline-flex gap-2 rounded-full px-2 pt-2 mx-2 hover:shadow-md hover:bg-rainbow cursor-pointer"
					type="button"
					aria-label="Menu"
					aria-controls="navigation"
					aria-expanded={menuOpen}
					class:is-active={menuOpen}
					on:click|preventDefault={(e) => {
						menuOpen = !menuOpen;
					}}
					bind:this={menuButton}
				>
					<span class="hamburger-box">
						<span class="hamburger-inner"></span>
					</span>
				</button>
			</div>
		</div>
	</nav>
	<!-- Panel -->
	{#if menuOpen}
		<div
			class="top-10 right-0"
			in:slide|local={{ duration: 250 }}
			out:slide|local={{ duration: 250 }}
		>
			<a
				href="/about"
				class="flex items-center rounded-md px-3 py-2 text-sm hover:shadow-md hover:bg-rainbow transition-colors duration-300"
				>About</a
			>
			<a
				href="/contact"
				class="flex items-center rounded-md px-3 py-2 text-sm hover:shadow-md hover:bg-rainbow transition-colors duration-300"
				>Contact</a
			>
		</div>
	{/if}
</header>

<style>
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
	.hamburger:hover {
		opacity: 0.7;
	}
	.hamburger.is-active:hover {
		opacity: 0.7;
	}
	.hamburger.is-active .hamburger-inner,
	.hamburger.is-active .hamburger-inner::before,
	.hamburger.is-active .hamburger-inner::after {
		background-color: #000;
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
		background-color: #000;
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

	/*
   * Spin
   */
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
