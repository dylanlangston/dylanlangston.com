import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vitest/config';
import { partytownVite } from '@builder.io/partytown/utils'

export default defineConfig({
	plugins: [sveltekit(), partytownVite({})],
	test: {
		include: ['src/**/*.{test,spec}.{js,ts}']
	},
	server: {
		watch: {
            usePolling: true,
        },
		host: true, // needed for the DC port mapping to work
        strictPort: true,
        port: 5173,
	}
});
