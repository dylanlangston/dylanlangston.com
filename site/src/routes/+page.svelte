<script lang="ts">
	import Panel from '../components/panel.svelte';
	import { BookOpenIcon, ToolIcon, UserIcon, UsersIcon, ZapIcon } from 'svelte-feather-icons';
	import Typewriter from '../components/typewriter.svelte';
	import { onMount } from 'svelte';
	import { Environment } from '../lib/Common';
	import { fade, blur, fly, slide, scale, crossfade } from 'svelte/transition';

	let shouldAnimateTitle: boolean = true;

	onMount(() => {
		shouldAnimateTitle = Environment.firstLoadMainPage;
		if (Environment.firstLoadMainPage) {
			setTimeout(() => {
				loaded = true;
				Environment.firstLoadMainPage = false;
			}, 550);
		} else {
			loaded = true;
		}
	});

	async function getGitHubProfilePicture(username: string): Promise<string> {
		if (Environment.githubProfilePicture) return Environment.githubProfilePicture;

		const response = await fetch(`https://api.github.com/users/${username}`, {
			cache: 'default'
		});
		if (!response.ok) {
			throw new Error(`Failed to fetch GitHub profile: ${response.statusText}`);
		}
		const userData = await response.json();
		const profilePictureURL = userData.avatar_url;
		const profilePicture = await fetch(profilePictureURL);
		Environment.githubProfilePicture = globalThis.URL.createObjectURL(await profilePicture.blob());

		return Environment.githubProfilePicture!;
	}

	let profilePicture = getGitHubProfilePicture('dylanlangston');

	$: loaded = false;
</script>

<div class="flex flex-col">
	<div class="flex flex-row ml-auto h-36 md:h-44 lg:h-56 pt-4">
		{#if loaded}
			<Panel marginAuto={true} paddingY={false}>
				<svelte:fragment>
					<div class="mx-1 sm:mx-4 flex flex-row animate-background">
						<h1
							class="my-1 md:my-2 lg:my-4 text-2xl md:text-4xl lg:text-5xl text-gray-900 dark:text-white"
						>
							<span
								class="drop-shadow-lg font-extrabold bg-clip-text bg-gradient-to-r to-emerald-800 from-sky-600 dark:to-emerald-600 dark:from-sky-400 text-transparent dark:text-transparent"
								><Typewriter disabled={!shouldAnimateTitle} phrase={'Hello World,'} /></span
							>
							<br />
							<span class="italic text-xl md:text-3xl lg:text-5xl"
								><Typewriter
									disabled={!shouldAnimateTitle}
									delay={2000}
									phrase={"I'm Dylan Langston"}
									stopBlinking={false}
								/></span
							>
						</h1>
					</div>
				</svelte:fragment>
			</Panel>
		{/if}
		<div class="pr-2 sm:pr-4 md:pr-8">
			<div
				class="rounded-full glass round-full w-36 h-36 md:h-44 md:w-44 lg:h-56 lg:w-56 mr-auto my-0"
			>
				{#await profilePicture}
					<div out:fade|local={{ duration: 50 }} title={"Loading..."}>
						<UserIcon class="rounded-full aspect-square p-2 lg:p-4 w-full h-full" />
					</div>
				{:then src}
					<img
						{src}
						alt=""
						class="rounded-full aspect-square p-2 lg:p-4 w-full h-full"
						in:fade|local={{ duration: 250, delay: 50 }}
					/>
				{:catch error}
					<div in:fade|local={{ duration: 0, delay: 50 }} title={error}>
						<UserIcon class="rounded-full aspect-square p-2 lg:p-4 w-full h-full" />
					</div>
				{/await}
			</div>
		</div>
	</div>

	<Panel marginAuto={false}>
		<svelte:fragment>
			<div class="mx-4">
				<h3 class="text-xl text-center font-medium leading-loose">
					Full Stack Developer & Outdoor Enthusiast
				</h3>
				<hr class="h-0.5 bg-black dark:bg-white border-transparent rounded-lg" />
				<br />
				<p class="text-center text-lg text-gray-900 dark:text-gray-200">
					Hey there! Welcome to my corner of the web! I'm Dylan Langston, your friendly neighborhood
					Full Stack Developer with a passion for crafting awesome software and exploring the great
					outdoors. When I'm not busy coding up a storm, you can probably find me hiking through
					nature trails or on a casual gaming adventure.
				</p>
				<br />
				<h4 class="text-lg font-medium leading-loose">What I'm All About:</h4>
				<ul class="space-y-4">
					<li class="flex gap-4">
						<div class="flex h-10 w-10 items-center justify-center rounded-full bg-primary-100">
							<ToolIcon />
						</div>
						<div class="flex-1">
							<h4 class="text-base font-medium leading-loose">Building Cool Stuff</h4>
							<p class="text-gray-900 dark:text-gray-200">
								From slick user interfaces to powerful backend systems, I love turning ideas into
								reality through code.
							</p>
						</div>
					</li>
					<li class="flex gap-4">
						<div class="flex h-10 w-10 items-center justify-center rounded-full bg-primary-100">
							<ZapIcon />
						</div>
						<div class="flex-1">
							<h4 class="text-base font-medium leading-loose">Problem Solving, FTW!</h4>
							<p class="text-gray-900 dark:text-gray-200">
								I thrive on cracking tough tech puzzles and finding creative solutions that make
								life easier.
							</p>
						</div>
					</li>
					<li class="flex gap-4">
						<div class="flex h-10 w-10 items-center justify-center rounded-full bg-primary-100">
							<UsersIcon />
						</div>
						<div class="flex-1">
							<h4 class="text-base font-medium leading-loose">Teamwork Makes the Dream Work</h4>
							<p class="text-gray-900 dark:text-gray-200">
								Collaboration is key! I dig working with others to bring projects to life.
							</p>
						</div>
					</li>
					<li class="flex gap-4">
						<div class="flex h-10 w-10 items-center justify-center rounded-full bg-primary-100">
							<BookOpenIcon />
						</div>
						<div class="flex-1">
							<h4 class="text-base font-medium leading-loose">Never Stop Learning</h4>
							<p class="text-gray-900 dark:text-gray-200">
								In the fast-paced world of tech, there's always something new to discover. I'm all
								about staying ahead of the curve.
							</p>
						</div>
					</li>
				</ul>
			</div>
		</svelte:fragment>
	</Panel>
</div>
