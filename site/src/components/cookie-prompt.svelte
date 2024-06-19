<script lang="ts">
    export let accept: () => void;
    export let settings: () => void;
</script>

<div class="p-6 text-center">
	<h3 class="text-3xl font-semibold sm:text-4xl">I Value Your Privacy</h3>
	<hr class="h-0.25 mt-2 bg-black dark:bg-white border-transparent rounded-lg" />
	<p class="mt-2">
		This site uses cookies to enhance your browsing experience and analyze site traffic.
	</p>
	<p>By clicking "Accept 🍪", you consent to the use of all cookies.</p>
	<div class="mt-4">
		<button
            on:click={() => accept()}
			type="submit"
			class="inline-flex px-4 mr-1 py-2 font-medium rounded-lg duration-150 hover:shadow-md hover:bg-rainbow disabled:bg-transparent transition-colors disabled:cursor-not-allowed"
		>
			Accept &nbsp;🍪
		</button>
		<button
            on:click={() => settings()}
			type="submit"
			class="inline-flex px-4 ml-1 py-2 font-medium rounded-lg duration-150 hover:shadow-md hover:bg-rainbow disabled:bg-transparent transition-colors disabled:cursor-not-allowed"
		>
			🍪 Settings
		</button>
	</div>
</div>
