export interface CookieSettings {
    analytics: boolean;
    userAccepted: boolean;
}

export class CookieSettingsManager {
    private static COOKIE_NAME = 'cookie_preferences';

    public static getPreferences(): CookieSettings {
        try {
            const cookieValue = document.cookie.split('; ').find(row => row.startsWith(this.COOKIE_NAME + '='))?.split('=')[1];
            if (cookieValue) {
                const parsedValue = JSON.parse(decodeURIComponent(cookieValue));
                return {
                    userAccepted: parsedValue.userAccepted || false,
                    analytics: parsedValue.analytics || false
                };
            }
        } catch (error) {
            console.error('Error retrieving cookie preferences:', error);
        }

        return {
            userAccepted: false,
            analytics: false
        };
    }

    public static savePreferences(preferences: CookieSettings): void {
        const cookieValue = encodeURIComponent(JSON.stringify(preferences));
        document.cookie = `${this.COOKIE_NAME}=${cookieValue}; path=/; expires=Fri, 31 Dec 9999 23:59:59 GMT`;
    }
}