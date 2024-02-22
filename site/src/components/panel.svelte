<script lang="ts">
	export let rounded: boolean = true;
	export let paddingY: boolean = true;
	export let animate: boolean = true;
</script>

<div class="max-w-screen-xl m-auto px-4 md:px-8" class:py-8={paddingY}>
	<div class="mx-auto w-fit glass" class:rounded-lg={rounded} class:py-4={paddingY} class:glass-no-animate={!animate}>
		<slot />
	</div>
</div>
