const colors = require('tailwindcss/colors');
const colorsToSkip = ['lightBlue', 'warmGray', 'trueGray', 'coolGray', 'blueGray'];
const filteredColors = Object.keys(colors)
  .filter(color => !colorsToSkip.includes(color))
  .reduce((obj, key) => {
    obj[key] = colors[key];
    return obj;
  }, {});

/** @type {import('tailwindcss').Config} */
export default {
	darkMode: ['variant', [
		'@media (prefers-color-scheme: dark) { &:not(.light *) }',
		'&:is(.dark *)',
	]],
	content: ['./src/**/*.{html,js,svelte,ts,css}'],
	theme: {
		colors: {
			...filteredColors,
			rainbow: 'var(--Rainbow)'
		},
		extend: {
			keyframes: {
				'background-hue-rotate': {
					to: {
						'filter': 'hue-rotate(360deg)'
					},
					// '0%': {
					// 	'background-color': 'red'
					// },
					// '16.67%': {
					// 	'background-color': 'orange'
					// },
					// '33.34%': {
					// 	'background-color': 'yellow'
					// },
					// '50%': {
					// 	'background-color': 'green'
					// },
					// '66.67%': {
					// 	'background-color': 'blue'
					// },
					// '83.34%': {
					// 	'background-color': 'purple'
					// },
					// '100%': {
					// 	'background-color': 'red'
					// },
				},
				'loader': {
					'100%': { 'background-position': 'right -65% top 0' },
				},
				'loader-shadow': {
					'0%': {
						'filter': 'hue-rotate(180deg) drop-shadow(0px 0px 3vh red)'
					},
					'16.67%': {
						'filter': 'hue-rotate(180deg) drop-shadow(0px 0px 5vh orange)'
					},
					'33.34%': {
						'filter': 'hue-rotate(180deg) drop-shadow(0px 0px 3vh yellow)'
					},
					'50%': {
						'filter': 'hue-rotate(180deg) drop-shadow(0px 0px 5vh green)'
					},
					'66.67%': {
						'filter': 'hue-rotate(180deg) drop-shadow(0px 0px 3vh blue)'
					},
					'83.34%': {
						'filter': 'hue-rotate(180deg) drop-shadow(0px 0px 5vh purple)'
					},
					'100%': {
						'filter': 'hue-rotate(180deg) drop-shadow(0px 0px 3vh red)'
					},
				},
				'fade-in': {
					'0%, 50%': { opacity: 0 },
					'100%': { opacity: 1 },
				},
				'fade-out': {
					'0%, 50%': { opacity: 1 },
					'100%': { opacity: 0 },
				},
				'blur-in': {
					'to': {
						'filter': 'blur(0)',
						'backdrop-filter': 'blur(16px)'
					},
				}
			},
			animation: {
				loader: 'loader 1s infinite steps(30), loader-shadow 17s linear infinite alternate',
				background: 'background-hue-rotate 17s linear infinite alternate',
				glass: 'blur-in 200ms 300ms linear forwards',
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