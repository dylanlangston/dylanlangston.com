/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
		extend: {
		},
		fontFamily: {
			emoji: ["Apple Color Emoji", "Segoe UI Emoji", "Noto Color Emoji", "Android Emoji", "EmojiSymbols", "EmojiOne Mozilla", "Twemoji Mozilla", "Segoe UI Symbol", "Noto Color Emoji Compat", "emoji", "noto-emojipedia-fallback"]
		},
	},
  plugins: [],
}

