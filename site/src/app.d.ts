// See https://kit.svelte.dev/docs/types#app
// for information about these interfaces
declare global {
	namespace App {
		// interface Error {}
		// interface Locals {}
		// interface PageData {}
		// interface PageState {}
		// interface Platform {}
	}
	interface Window extends Window {
		miniaudio: MiniAudio | undefined = undefined;
	}
}

declare var saveFileFromMEMFSToDisk: (memoryFSname: string, localFSname: string) => void;

export {};