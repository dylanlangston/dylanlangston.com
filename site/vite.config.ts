import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vitest/config';
import { resolve, join } from 'path';
import optimizeWASMPlugin from './OptimizeWASMPlugin.ts';
import updateResume from './UpdateResume.ts'
import { getArgs } from './svelte.config.js';
import tailwindcss from '@tailwindcss/vite'
const args = getArgs();


export default defineConfig({
	plugins: [
		optimizeWASMPlugin({enabled: !args.Debug}),
		updateResume({sourceDirectories: ['../resume/dist', '../resume/src/resume']}),
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