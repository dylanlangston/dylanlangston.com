import { devices, type PlaywrightTestConfig } from '@playwright/test';



const config: PlaywrightTestConfig = {
	webServer: {
		command: 'npm run build && npm run preview',
		port: 4173
	},
	testDir: 'tests',
	testMatch: /(.+\.)?(test|spec)\.[jt]s/,
	workers: '75%',
	use: {
		headless: true
	},
	projects: [
        {
            name: 'chromium',
            use: {
                ...devices['Desktop Chrome'],
				headless: false,
                launchOptions: {
                    args: [
						'--headless',
						'--no-sandbox',
						'--ignore-gpu-blocklist',
						'--use-gl=angle',
						'--use-angle=gl-egl'
					]
                }
            },
        },
		{
			name: 'safari',
			use: {
				...devices['Desktop Safari'],
			}
		},
		{
			name: 'firefox',
			use: {
				...devices['Desktop Firefox']
			}
		}
    ],
};

export default config;
