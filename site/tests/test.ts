import { expect, test, type Page, type TestInfo, type ConsoleMessage } from '@playwright/test';

test('index page has expected layout', async ({ page }, testinfo) => {
	await page.goto('/');
	await page.waitForLoadState("domcontentloaded");

	await expect(page.getByRole('heading', { name: "I'm Dylan Langston" })).toBeVisible({
		timeout: 5000
	});

	await expect(page).toHaveScreenshot({
		fullPage: true,
		stylePath: ['tests/background-mask.css']
	});
});

test('raylib loaded successfully', async ({ page }, testInfo: TestInfo) => {
	const waitForConsoleMessage = async (page: Page, searchString: string, timeout: number): Promise<ConsoleMessage> =>
		new Promise<ConsoleMessage>((resolve, reject) => {
			const timeoutId = setTimeout(() => {
				reject(new Error(`Timed out waiting for console message containing "${searchString}"`));
			}, timeout);

			page.on('console', async (msg: ConsoleMessage) => {
				const messageText: string = msg.text();
				if (messageText.includes(searchString)) {
					clearTimeout(timeoutId);
					resolve(msg);
				}
			});
		});

	const consoleMsgPromise = waitForConsoleMessage(page, 'TRACE: Raylib Started', 5000);
	await page.goto('/');
	await page.waitForLoadState("domcontentloaded");
	const consoleMessage = await consoleMsgPromise;
});
