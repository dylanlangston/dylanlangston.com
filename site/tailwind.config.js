/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
		colors: {
			transparent: 'transparent',
			'blue-light': '#1b1e34',
			'blue-mid': '#201433',
			'blue-dark': '#201127',
			'green-light': '#94c5ac',
			'green-mid': '#6aaf9d',
			'green-dark': '#355d68',
			'yellow-light': '#ffeb99',
			'yellow-mid': '#ffc27a',
			'yellow-dark': '#ec9a6d',
			'red-light': '#d9626b',
			'red-mid': '#c24b6e',
			'red-dark': '#a73169'
		},
		extend: {
			animation: {
				pingSlow: 'ping 1.5s ease-in-out infinite'
			}
		},
		fontFamily: {
			sans: ["sans-serif"],
			emoji: ["Apple Color Emoji", "Segoe UI Emoji", "Noto Color Emoji", "Android Emoji", "EmojiSymbols", "EmojiOne Mozilla", "Twemoji Mozilla", "Segoe UI Symbol", "Noto Color Emoji Compat", "emoji", "noto-emojipedia-fallback"]
		},
	},
  plugins: [],
}

