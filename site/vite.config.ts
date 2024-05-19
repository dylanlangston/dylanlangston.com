import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vitest/config';
import { partytownVite } from '@builder.io/partytown/utils'
import { resolve, join } from 'path';
import optimizeWASMPlugin from './OptimizeWASMPlugin.ts';
import { getArgs } from './svelte.config.js';
const args = getArgs();


export default defineConfig({
	plugins: [
		optimizeWASMPlugin({enabled: !args.Debug}),
		sveltekit(), 
		partytownVite({
			debug: args.Debug
		})
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