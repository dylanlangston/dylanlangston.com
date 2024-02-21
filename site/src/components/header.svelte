<script>
	import { MenuIcon, } from 'svelte-feather-icons'
</script>

<header class="p-1 bg-gray-800/50 border-b">
    <div class="container flex justify-between h-16 mx-auto">
		<a rel="noopener noreferrer" href="/" aria-label="Back to homepage" class="flex items-center">
            DylanLangston.com
		</a>
		<ul class="items-stretch hidden space-x-3 md:flex">
			<li class="flex">
				<a rel="noopener noreferrer" href="/about" class="flex items-center -mb-1 border-b-2 dark:border-transparent">About</a>
			</li>
			<li class="flex">
				<a rel="noopener noreferrer" href="/contact" class="flex items-center -mb-1 border-b-2 dark:border-transparent">Contact</a>
			</li>
		</ul>
		<button class="flex items-center justify-end md:hidden">
			<MenuIcon size="24" />
		</button>
	</div>
</header>