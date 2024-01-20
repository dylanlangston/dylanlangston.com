import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';
import sveltePreprocess from 'svelte-preprocess';
import autoprefixer from 'autoprefixer';
import adapter from '@sveltejs/adapter-static';
import { mdsvex } from 'mdsvex';
import rehypeSlug from 'rehype-slug';
import rehypeAutolinkHeadings from 'rehype-autolink-headings';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	preprocess: [ 
		sveltePreprocess({
			postcss: {
				plugins: [autoprefixer]
			}
		}),
		mdsvex({
			extensions: ['.md'],
			rehypePlugins: [rehypeSlug, rehypeAutolinkHeadings]
		}),
		vitePreprocess()
	],

	extensions: ['.svelte', '.md'],

	kit: {
		adapter: adapter({
			pages: 'build',
			assets: 'build',
			fallback: '404.html',
			precompress: shouldPrecompress(),
			strict: true
		})
	},
};

export default config;

function getArgs() {
	const args = {};
	process.argv.slice(2, process.argv.length).forEach((arg) => {
		// long arg
		if (arg.slice(0, 2) === '--') {
			const longArg = arg.split('=');
			const longArgFlag = longArg[0].slice(2, longArg[0].length);
			const longArgValue = longArg.length > 1 ? longArg[1] : true;
			args[longArgFlag] = longArgValue;
		}
		// flags
		else if (arg[0] === '-') {
			const flags = arg.slice(1, arg.length).split('');
			flags.forEach((flag) => {
				args[flag] = true;
			});
		}
	});
	return args;
}

function shouldPrecompress() {
	return Object.keys(getArgs()).some((v) => v.toLowerCase() == 'precompress');
}