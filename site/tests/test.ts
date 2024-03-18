import { expect, test } from '@playwright/test';

test('index page has expected h3', async ({ page }) => {
	await page.goto('/');
	await expect(page.getByRole('heading', { name: 'Full Stack Developer & Outdoor Enthusiast' })).toBeVisible();
});
