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

// https://stackoverflow.com/a/52171480
export const hash = (str: string, seed: number = 0): number => {
    let h1 = 0xdeadbeef ^ seed, h2 = 0x41c6ce57 ^ seed;
    for(let i = 0, ch; i < str.length; i++) {
        ch = str.charCodeAt(i);
        h1 = Math.imul(h1 ^ ch, 2654435761);
        h2 = Math.imul(h2 ^ ch, 1597334677);
    }
    h1  = Math.imul(h1 ^ (h1 >>> 16), 2246822507);
    h1 ^= Math.imul(h2 ^ (h2 >>> 13), 3266489909);
    h2  = Math.imul(h2 ^ (h2 >>> 16), 2246822507);
    h2 ^= Math.imul(h1 ^ (h1 >>> 13), 3266489909);
  
    return 4294967296 * (2097151 & h2) + (h1 >>> 0);
};