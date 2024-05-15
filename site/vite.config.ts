import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vitest/config';
import { partytownVite } from '@builder.io/partytown/utils'
import { resolve, join } from 'path';

export default defineConfig({
	plugins: [sveltekit(), partytownVite({
		debug: false
	})],
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
