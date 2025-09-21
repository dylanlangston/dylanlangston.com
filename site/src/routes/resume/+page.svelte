<script lang="ts">
	import Panel from '$components/panel.svelte';
</script>

<Panel rounded={true} paddingY={true} animate={true} marginAuto={false}>
	<svelte:fragment>
		<div class="space-y-3 sm:text-center text-center mb-2 pointer-events-none">
			<h3 class="text-3xl font-semibold sm:text-4xl px-4">My Resume</h3>
		</div>

		<div style="width: 80vw; max-width: 1201px" class="mx-3">
		<iframe
			src="/resume.pdf"
			title="Resume"
			style="height: calc(100vh - 350px)"
			class="rounded-lg min-w-full"
		></iframe>
		</div>


		<div class="flex justify-center mt-3 mx-3">
			<a
				href="/resume.pdf"
				class="text-center w-full px-4 py-2 font-medium rounded-lg duration-150 hover:shadow-md hover:bg-rainbow disabled:bg-transparent transition-colors disabled:cursor-not-allowed"
			>
				Download Resume
			</a>
		</div>
	</svelte:fragment>
</Panel>
