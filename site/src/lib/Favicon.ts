export class Favicon {
    private faviconAnimation: number = 0;

	constructor(canvasElement: HTMLCanvasElement | OffscreenCanvas) {
        const faviconSize = 64;
		const faviconRadius = 40;
		const link: HTMLLinkElement | null = document.querySelector("link[rel~='icon']");
		const faviconCanvas: HTMLCanvasElement = document.createElement('canvas');
		faviconCanvas.width = faviconSize;
		faviconCanvas.height = faviconSize;
		const faviconContext = faviconCanvas!.getContext('2d');

		// Rounded Corner
		faviconContext!.beginPath();
		faviconContext!.moveTo(faviconRadius, 0);
		faviconContext!.lineTo(faviconSize - faviconRadius, 0);
		faviconContext!.quadraticCurveTo(faviconSize, 0, faviconSize, faviconRadius);
		faviconContext!.lineTo(faviconSize, faviconSize - faviconRadius);
		faviconContext!.quadraticCurveTo(
			faviconSize,
			faviconSize,
			faviconSize - faviconRadius,
			faviconSize
		);
		faviconContext!.lineTo(faviconRadius, faviconSize);
		faviconContext!.quadraticCurveTo(0, faviconSize, 0, faviconSize - faviconRadius);
		faviconContext!.lineTo(0, faviconRadius);
		faviconContext!.quadraticCurveTo(0, 0, faviconRadius, 0);
		faviconContext!.closePath();
		faviconContext!.clip();

		// Update favicon every other frame
		let hue = Math.floor(Math.random() * 360);
		let lastFrame = performance.now();
		let updateThisFrame = true;
		const faviconUpdate = (timestamp: DOMHighResTimeStamp) => {
            // Skip every other frame
			updateThisFrame = !updateThisFrame;
			if (!updateThisFrame) {
				this.faviconAnimation = requestAnimationFrame(faviconUpdate);
				return;
			}

            if (hue > 359) {
				hue = 0;
			} else {
				hue += (lastFrame - timestamp) / 100;
				lastFrame = timestamp;
			}

            // Change hue
			faviconContext!.globalCompositeOperation = 'hue';
			faviconContext!.fillStyle = 'hsl(' + hue + ',100%, 50%)';
			faviconContext!.fillRect(0, 0, faviconSize, faviconSize);

			// Copy the main canvas to a smaller one for the favicon
			faviconContext!.globalCompositeOperation = 'source-over';
			const canvasQuarterWidth = canvasElement.width / 4;
			const canvasQuarterHeight = canvasElement.height / 4;
			faviconContext!.drawImage(
				canvasElement,
				canvasQuarterWidth,
				canvasQuarterHeight,
				canvasQuarterWidth * 2,
				canvasQuarterHeight * 2,
				0,
				0,
				faviconSize,
				faviconSize
			);

            // Set Favicon to canvas
			link!.href = faviconCanvas.toDataURL('image/png');

			this.faviconAnimation = requestAnimationFrame(faviconUpdate);
		};
		this.faviconAnimation = requestAnimationFrame(faviconUpdate);
	}

    public destroy(): void {
        cancelAnimationFrame(this.faviconAnimation);

        const link: HTMLLinkElement | null = document.querySelector("link[rel~='icon']");
		link!.href = '/favicon.png';
    }
}