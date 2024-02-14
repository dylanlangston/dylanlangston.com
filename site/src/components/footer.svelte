<script>
  import { MailIcon, LinkedinIcon, GithubIcon, } from 'svelte-feather-icons'
</script>

<footer class="py-1 border-t bg-gray-800/50">
	<div class="container mx-auto md:space-y-12">
		<div class="grid justify-center lg:justify-between">
			<div class="flex flex-col self-center text-sm text-center md:block lg:col-start-1 md:space-x-6">
				<span>Dylan Langston ©{new Date().getFullYear()} All rights reserved</span>
			</div>
			<div class="flex justify-center pt-4 space-x-4 lg:pt-0 lg:col-end-13">
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
		</div>
	</div>
</footer>