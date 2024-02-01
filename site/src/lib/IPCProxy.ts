export class IPCProxy {
    private static index: number = 0;
    private static proxies: { [type: number]: any } = {};
    public static Add(f: any): number {
        const currentIndex = this.index;
        this.index += 1;

        this.proxies[currentIndex] = f;

        return currentIndex;
    }
    public static Get = (n: number) => this.proxies[n];
    public static Remove = (n: number) => {
        const temp = this.proxies[n];
        this.proxies[n] = null;
        return temp;
    }
}