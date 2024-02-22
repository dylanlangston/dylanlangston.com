import { BrowserDetector } from 'browser-dtector';
import { readable, writable, get } from 'svelte/store';


export class Environment {
    private constructor() { }

    public static get Dev(): boolean {
        return import.meta.env.MODE == 'development';
    }

    private static detector = new BrowserDetector();

    public static isMobile = readable(false, (set: (value: boolean) => void) => {
        const listener = (e: Event) => {
            set(this.detector.parseUserAgent(window.navigator.userAgent).isMobile);
        };
        window.addEventListener("resize", listener);
        set(this.detector.parseUserAgent(window.navigator.userAgent).isMobile);
        return () => { window.removeEventListener("resize", listener); };
    });
}

export const sanitizeEvent = <T>(e: any, n: number = 0): T => {
    const obj: any = {};

    for (let k in e) {
        if (e[k] == null || e[k] == undefined) continue;

        // Only go 6 levels deep
        if (n > 6) continue;

        if (e[k] instanceof Node) continue;
        if (e[k] instanceof Window) {
            obj[k] = {
                width: window.innerWidth,
                height: window.innerHeight,
            };
            continue;
        }
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
                try {
                    obj[k] = sanitizeEvent(e[k], n + 1);
                }
                catch {
                    continue;
                }
                break;
        }
    }
    return <T>obj;
}

// https://stackoverflow.com/a/52171480
export const hash = (str: string, seed: number = 0): number => {
    let h1 = 0xdeadbeef ^ seed, h2 = 0x41c6ce57 ^ seed;
    for (let i = 0, ch; i < str.length; i++) {
        ch = str.charCodeAt(i);
        h1 = Math.imul(h1 ^ ch, 2654435761);
        h2 = Math.imul(h2 ^ ch, 1597334677);
    }
    h1 = Math.imul(h1 ^ (h1 >>> 16), 2246822507);
    h1 ^= Math.imul(h2 ^ (h2 >>> 13), 3266489909);
    h2 = Math.imul(h2 ^ (h2 >>> 16), 2246822507);
    h2 ^= Math.imul(h1 ^ (h1 >>> 13), 3266489909);

    return 4294967296 * (2097151 & h2) + (h1 >>> 0);
};

export class RateLimiter {
    allowedRequests = 0;
    timeFrameSize = 0;
    queue: Array<number> = [];
    constructor(allowedRequests: number, timeFrameSize: number) {
        this.allowedRequests = allowedRequests;
        this.timeFrameSize = timeFrameSize;
    }
    shouldAllow(timestamp: number = Date.now()): boolean {
        const diff = timestamp - this.timeFrameSize;
        while (this.queue[this.queue.length - 1] <= diff) {
            this.queue.pop();
        }
        if (this.queue.length < this.allowedRequests) {
            this.queue.unshift(timestamp);
            return true;
        } else {
            return false
        }
    }
}

export interface IHashMap<Type> { [indexer: number]: Type }

export class HashMapQueue<Type> {
    hashFunction: (t: Type) => number;
    internalStore: IHashMap<Type | undefined> = {};
    hashes: Array<number> = [];
    constructor(hashFunction: (t: Type) => number, initial: Array<Type> = []) {
        for (let item of initial) {
            const hash = hashFunction(item);
            this.internalStore[hash] = item;
            this.hashes.push(hash)
        }
        this.hashFunction = hashFunction;
    }
    public get count(): number {
        return this.hashes.length;
    }
    add(item: Type): boolean {
        const hash = this.hashFunction(item);
        if (this.internalStore[hash] === undefined) {
            this.internalStore[hash] = item;
            this.hashes.push(hash);
            return true;
        }
        else {
            // if item with the same hash is already set then we update it 
            this.internalStore[hash] = item;
            return false;
        }

    }
    remove(): Type | undefined {
        const hash = this.hashes.pop();
        if (hash === undefined) return undefined;
        const item = this.internalStore[hash];
        this.internalStore[hash] = undefined;

        return item;
    }
}

export const useMediaQuery = (mediaQueryString: string) => {
    const matches = readable(false, (set: (value: boolean) => void) => {
        const m = window.matchMedia(mediaQueryString);
        set(m.matches);
        const el = (e: MediaQueryListEvent) => set(e.matches);
        m.addEventListener("change", el);
        return () => { m.removeEventListener("change", el) };
    });
    return matches;
}

(<any>globalThis).saveFileFromMEMFSToDisk = (memoryFSname: string, localFSname: string) => {
    const data = FS.readFile(memoryFSname);
    const blob = new Blob([data.buffer], { type: 'application/octet-binary' });

    const blobUrl = URL.createObjectURL(blob);

    const link = document.createElement('a');
    link.href = blobUrl;
    link.target = '_blank';
    link.download = localFSname;
    link.click();
};