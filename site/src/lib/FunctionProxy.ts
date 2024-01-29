export class FunctionProxy {
    private static index: number = 0;
    private static functions: { [type: number]: any } = {};
    public static Add(f: any): number {
        const currentIndex = this.index;
        this.index += 1;

        this.functions[currentIndex] = f;

        return currentIndex;
    }
    public static Get = (n: number) => this.functions[n];
}