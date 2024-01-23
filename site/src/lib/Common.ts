import { BrowserDetector } from 'browser-dtector';

export class Environment {
    public static get Dev(): boolean {
        return import.meta.env.MODE == 'development';
    }

    private static detector = new BrowserDetector();
    public static get isMobile(): boolean {
        return this.detector.parseUserAgent().isMobile;
    }
}