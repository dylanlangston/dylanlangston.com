export class Environment {
    public static get Dev(): boolean {
        return import.meta.env.MODE == 'development';
    }
}