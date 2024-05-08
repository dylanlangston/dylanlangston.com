import { expect, test } from '@playwright/test';

test('index page has expected layout', async ({ page }, testinfo) => {
	await page.goto('/');
	page.waitForLoadState("domcontentloaded");

	await expect(page.getByRole('heading', { name: "I'm Dylan Langston" })).toBeVisible({
		timeout: 5000
	});

	await expect(page).toHaveScreenshot({
		fullPage: true,
		stylePath: ['tests/background-mask.css']
	});
});