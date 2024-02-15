<script lang="ts">
import { Environment } from "$lib/Common";
import { onMount } from 'svelte';
import { fade, blur, fly, slide, scale, crossfade } from 'svelte/transition';

let loaded: boolean = false;

onMount(() => loaded = true);
</script>

{#if loaded}
<h1 class="text-center text-2xl lg:text-6xl font-bold">Hello {Environment.isMobile ? "Mobile" : "Desktop"} HTML World</h1>
{/if}