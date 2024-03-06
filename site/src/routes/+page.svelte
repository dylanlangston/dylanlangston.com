<script lang="ts">
	import Panel from '../components/panel.svelte';
	import { ToolIcon } from 'svelte-feather-icons';
</script>

<Panel>
	<svelte:fragment>
		<div class="text-center mx-2 lg:m-4">
			<div class="flex flex-row">
				<h1 class="text-2xl lg:text-6xl font-bold">Under Construction</h1>
				<ToolIcon class="pl-2 size-8 m-auto lg:size-16 lg:pl-4" />
			</div>

			<hr />
			<br/>
			<p>Please check back soon.</p>
		</div>
	</svelte:fragment>
</Panel>
