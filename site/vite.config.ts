import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vitest/config';
import { resolve, join } from 'path';
import optimizeWASMPlugin from './OptimizeWASMPlugin.ts';
import fetchJSONResume from './FetchJSONResume.ts'
import { getArgs } from './svelte.config.js';
import tailwindcss from '@tailwindcss/vite'
const args = getArgs();


export default defineConfig({
	plugins: [
		optimizeWASMPlugin({enabled: !args.Debug}),
		fetchJSONResume({
			url: 'https://gist.githubusercontent.com/dylanlangston/80380ec68b970189450dd2fae4502ff1/raw/resume.json',
			filename: 'resume.json',
		}),
		tailwindcss(),
		sveltekit()
	],
	assetsInclude: './static/**/*',
	test: {
		include: ['src/**/*.{test,spec}.{js,ts}']
	},
	server: {
		watch: {
			usePolling: true,
		},
		cors: true,
		host: true, // needed for the DC port mapping to work
		strictPort: true,
		port: 5173
	},
	resolve: {
		alias: {
			'dylanlangston.com.wasm': resolve('./static/dylanlangston.com.wasm')
		}
	},
	ssr: {
		noExternal: ['browser-dtector']
	}
});