<script>
	import { MailIcon, LinkedinIcon, GithubIcon } from 'svelte-feather-icons';
	import Ripple from '$components/ripple.svelte';
</script>

<footer class="p-1 glass px-4 md:px-8">
	<div class="container mx-auto md:space-y-12">
		<div class="grid justify-center lg:justify-between">
			<div class="static flex justify-center space-x-4 lg:col-start-1">
				<Ripple escapeParent={true}>
					<a
						rel="noopener noreferrer"
						href="/contact"
						title="Contact"
						class="flex items-center justify-center w-10 h-10 rounded-full hover:shadow-md hover:bg-rainbow transition-colors duration-300"
					>
						<MailIcon size="24" />
					</a>
				</Ripple>
				<Ripple escapeParent={true}>
					<a
						rel="noopener noreferrer"
						href="https://www.linkedin.com/in/dylan-langston/"
						target="_blank"
						title="LinkedIn"
						class="flex items-center justify-center w-10 h-10 rounded-full hover:shadow-md hover:bg-rainbow transition-colors duration-300"
					>
						<LinkedinIcon size="24" />
					</a>
				</Ripple>
				<Ripple escapeParent={true}>
					<a
						rel="noopener noreferrer"
						href="https://github.com/dylanlangston"
						target="_blank"
						title="GitHub"
						class="flex items-center justify-center w-10 h-10 rounded-full hover:shadow-md hover:bg-rainbow transition-colors duration-300"
					>
						<GithubIcon size="24" />
					</a>
				</Ripple>
			</div>
			<div
				class="static flex flex-col self-center text-sm text-center md:block lg:row-end-1 lg:col-end-1 md:space-x-6"
			>
				<span>Dylan Langston</span> <span>©{new Date().getFullYear()} All rights reserved</span>
			</div>
		</div>
	</div>
</footer>
