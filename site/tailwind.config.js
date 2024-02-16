import { transform } from 'typescript';

const colors = require('tailwindcss/colors')

/** @type {import('tailwindcss').Config} */
export default {
	content: ['./src/**/*.{html,js,svelte,ts,css}'],
	theme: {
		colors: {
			transparent: 'transparent',
			current: 'currentColor',
			slate: colors.slate,
			gray: colors.gray,
			zinc: colors.zinc,
			neutral: colors.neutral,
			stone: colors.stone,
			red: colors.red,
			orange: colors.orange,
			amber: colors.amber,
			yellow: colors.yellow,
			lime: colors.lime,
			green: colors.green,
			emerald: colors.emerald,
			teal: colors.teal,
			cyan: colors.cyan,
			sky: colors.sky,
			blue: colors.blue,
			indigo: colors.indigo,
			violet: colors.violet,
			purple: colors.purple,
			fuchsia: colors.fuchsia,
			pink: colors.pink,
			rose: colors.rose,
			rainbow: 'var(--Rainbow)'
		},
		extend: {
			keyframes: {
				'background-hue-rotate': {
					'to': {
						filter: 'hue-rotate(360deg)'
					}
				},
				'loader': {
					'0%, 20%': { 'box-shadow': '10vw 0 0 2vw, 3.5vw 0 0 2vw, -3.5vw 0 0 2vw, -10vw 0 0 2vw' },
					'60%, 100%': { 'box-shadow': '5vw 0 0 3vw, 5vw 0 0 3vw, -5vw 0 0 3vw, -5vw 0 0 3vw' },
				},
				'loader-rotate': {
					'0%, 25%': { transform: 'rotate(0)' },
					'50%, 100%': { transform: 'rotate(0.5turn)' },
				},
				'loader-shadow': {
					'0%': {
						'filter': 'hue-rotate(180deg) drop-shadow(0px 0px 3vh red)'
					},
					'14.3%': {
						'filter': 'hue-rotate(180deg) drop-shadow(0px 0px 5vh orange)'
					},
					'28.6%': {
						'filter': 'hue-rotate(180deg) drop-shadow(0px 0px 3vh yellow)'
					},
					'42.9%': {
						'filter': 'hue-rotate(180deg) drop-shadow(0px 0px 5vh green)'
					},
					'57.2%': {
						'filter': 'hue-rotate(180deg) drop-shadow(0px 0px 3vh blue)'
					},
					'71.5%': {
						'filter': 'hue-rotate(180deg) drop-shadow(0px 0px 5vh purple)'
					},
					'85.8%': {
						'filter': 'hue-rotate(180deg) drop-shadow(0px 0px 3vh black)'
					}
				},
				'fade-in': {
					'0%, 50%': { opacity: 0 },
					'100%': { opacity: 1 },
				}
			},
			animation: {
				loader: 'loader 1s infinite linear alternate, loader-rotate 2s infinite ease, loader-shadow 9s infinite alternate, fade-in 2s',
				background: 'background-hue-rotate 17s linear infinite'
			}
		},
		fontFamily: {
			emoji: ["Apple Color Emoji", "Segoe UI Emoji", "Noto Color Emoji", "Android Emoji", "EmojiSymbols", "EmojiOne Mozilla", "Twemoji Mozilla", "Segoe UI Symbol", "Noto Color Emoji Compat", "emoji", "noto-emojipedia-fallback"]
		},
	},
	plugins: [
		function ({ addBase, theme }) {
			addBase({
				':root': {
					'--Rainbow': 'hsl(50, 30%, 50%)',
				},
			});
		},
	],
}