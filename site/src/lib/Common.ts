import { BrowserDetector } from 'browser-dtector';

export class Environment {
    private constructor() {}

    public static get Dev(): boolean {
        return import.meta.env.MODE == 'development';
    }

    private static detector = new BrowserDetector();
    public static get isMobile(): boolean {
        return this.detector.parseUserAgent().isMobile;
    }
}

export const sanitizeEvent = <T>(e: any, n: number = 0): T => {
    const obj: any = {};

    for (let k in e) {
        if (e[k] == null || e[k] == undefined) continue;

        // Only go 6 levels deep
        if (n > 6) continue;

        if (e[k] instanceof Node) continue;
        if (e[k] instanceof Window) continue;
        if (e[k] instanceof Function) continue;

        switch (typeof e[k]) {
            case 'undefined':
            case 'boolean':
            case 'number':
            case 'bigint':
            case 'string':
                obj[k] = e[k];
                break;
            case 'object':
                obj[k] = sanitizeEvent(e[k], n + 1);
                break;
        }
    }
    return <T>obj;
}