<script>
  import { MailIcon, LinkedinIcon, GithubIcon, } from 'svelte-feather-icons'
</script>

<footer class="py-1 border-t bg-gray-800/50">
	<div class="container mx-auto md:space-y-12">
		<div class="grid justify-center lg:justify-between">
			<div class="static flex justify-center space-x-4 lg:col-start-1">
				<a rel="noopener noreferrer" href="/contact" title="Email" class="flex items-center justify-center w-10 h-10 rounded-full">
					<MailIcon size="24" />
				</a>
				<a rel="noopener noreferrer" href="https://www.linkedin.com/in/dylan-langston/" target="_blank" title="LinkedIn" class="flex items-center justify-center w-10 h-10 rounded-full">
					<LinkedinIcon size="24" />
				</a>
				<a rel="noopener noreferrer" href="https://github.com/dylanlangston" target="_blank" title="GitHub" class="flex items-center justify-center w-10 h-10 rounded-full">
					<GithubIcon size="24" />
				</a>
			</div>
			<div class="static flex flex-col self-center text-sm text-center md:block lg:row-end-1 lg:col-end-1 md:space-x-6">
				<span>Dylan Langston</span>	<span>©{new Date().getFullYear()} All rights reserved</span>
			</div>
		</div>
	</div>
</footer>