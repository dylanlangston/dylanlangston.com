<script lang="ts">
	export let rounded: boolean = true;
</script>

<div class="max-w-screen-xl mx-auto px-4 md:px-8 py-8">
	<div class="py-4 mx-auto w-fit glass" class:rounded-lg={rounded}>
		<slot />
	</div>
</div>
