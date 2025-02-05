<script lang="ts">
	export let rounded: boolean = true;
	export let paddingY: boolean = true;
	export let animate: boolean = true;
	export let marginAuto: boolean = true;
</script>

<div class="max-w-(--breakpoint-xl) px-4 md:px-8" class:py-8={paddingY} class:m-auto={marginAuto}>
	<div class="mx-auto w-fit glass" class:round={rounded} class:rounded-lg={rounded} class:py-4={paddingY} class:glass-no-animate={!animate}>
		<slot />
	</div>
</div>
