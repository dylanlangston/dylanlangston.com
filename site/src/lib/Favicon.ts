import type { Unsubscriber } from "svelte/store";
import { Environment } from "./Common";

export class Favicon {
	private faviconAnimation: number;
	private darkModeSubscription: Unsubscriber;

	private faviconSize = 64;
	private faviconRadius = 40;

	private hue = Math.floor(Math.random() * 360);
	private darkMode = false;

	private copyCanvas(dest: CanvasRenderingContext2D, source: HTMLCanvasElement | OffscreenCanvas) {
		dest.globalCompositeOperation = "copy";
		dest.clearRect(0, 0, this.faviconSize, this.faviconSize);
		dest.fillStyle = "hsl(" + this.hue + ", 50%, " + (this.darkMode ? 30 : 60) + "%)";
		const canvasQuarterWidth = source.width / 4;
		const canvasQuarterHeight = source.height / 4;
		dest.drawImage(
			source,
			canvasQuarterWidth,
			canvasQuarterHeight,
			canvasQuarterWidth * 2,
			canvasQuarterHeight * 2,
			0,
			0,
			this.faviconSize,
			this.faviconSize
		);
		dest.globalCompositeOperation = this.darkMode ? "color-dodge" : "color-burn";
		dest.fillRect(0,0, this.faviconSize, this.faviconSize);
		return dest;
	}

	private roundCorners(dest: CanvasRenderingContext2D,) {
		dest.beginPath();
		dest.moveTo(this.faviconRadius, 0);
		dest.lineTo(this.faviconSize - this.faviconRadius, 0);
		dest.quadraticCurveTo(this.faviconSize, 0, this.faviconSize, this.faviconRadius);
		dest.lineTo(this.faviconSize, this.faviconSize - this.faviconRadius);
		dest.quadraticCurveTo(
			this.faviconSize,
			this.faviconSize,
			this.faviconSize - this.faviconRadius,
			this.faviconSize
		);
		dest.lineTo(this.faviconRadius, this.faviconSize);
		dest.quadraticCurveTo(0, this.faviconSize, 0, this.faviconSize - this.faviconRadius);
		dest.lineTo(0, this.faviconRadius);
		dest.quadraticCurveTo(0, 0, this.faviconRadius, 0);
		dest.closePath();
		dest.clip();
	}

	constructor(canvasElement: HTMLCanvasElement | OffscreenCanvas) {

		const link: HTMLLinkElement | null = document.querySelector("link[rel~='icon']");
		const faviconCanvas: HTMLCanvasElement = document.createElement('canvas');
		faviconCanvas.style.background = "transparent";
		faviconCanvas.width = this.faviconSize;
		faviconCanvas.height = this.faviconSize;
		const faviconContext = faviconCanvas!.getContext('2d');

		this.roundCorners(faviconContext!);


		let lastFrame = performance.now();
		let currentFrameCount = 0;

		this.darkModeSubscription = Environment.darkMode.subscribe((dark) => {
			this.darkMode = dark;
		});

		const faviconUpdate = (timestamp: DOMHighResTimeStamp) => {
			// Only draw every 5 frames
			currentFrameCount += 1;
			if (currentFrameCount < 5) {
				this.faviconAnimation = requestAnimationFrame(faviconUpdate);
				return;
			}
			currentFrameCount = 0;

			if (document.hidden) {
				this.faviconAnimation = requestAnimationFrame(faviconUpdate);
				return;
			}

			if (this.hue > 359) {
				this.hue = 0;
			} else {
				this.hue += (lastFrame - timestamp) / 100;
				lastFrame = timestamp;
			}

			// Copy the main canvas to a smaller one for the favicon
			this.copyCanvas(faviconContext!, canvasElement);

			// Set Favicon to canvas
			link!.href = faviconCanvas.toDataURL('image/png');

			this.faviconAnimation = requestAnimationFrame(faviconUpdate);
		};
		this.faviconAnimation = requestAnimationFrame(faviconUpdate);

		document.addEventListener("visibilitychange", this.onVisiblityChange);
	}

	private onVisiblityChange = () => {
		// Restore original icon when window is no longer visible (since the animation stops when the window is inactive)
		if (document.hidden) {
			const link: HTMLLinkElement | null = document.querySelector("link[rel~='icon']");
			link!.href = '/favicon.png';
		}
	};

	public destroy(): void {
		cancelAnimationFrame(this.faviconAnimation);

		this.darkModeSubscription();

		const link: HTMLLinkElement | null = document.querySelector("link[rel~='icon']");
		link!.href = '/favicon.png';

		document.removeEventListener("visibilitychange", this.onVisiblityChange);
	}
}