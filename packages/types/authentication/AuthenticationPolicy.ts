export interface AuthenticationPolicy {
    session: {
        reloadBehavior: 'keep-session' | 'logout';
        idleTimeoutMinutes: number;
        absoluteTimeoutMinutes: number;
    };

    token: {
        accessTokenLifetimeMinutes: number;
        autoRefreshEnabled: boolean;
        refreshThresholdMinutes: number;
    };

    deepLink: {
        enabled: boolean;
        afterLogin: 'restore' | 'home';
    };

    reAuthentication: {
        enabled: boolean;
        validMinutes: number;
        requireForSystemSettings: boolean;
        requireForUserDelete: boolean;
        requireForRoleChange: boolean;
    };

    navigation: {
        loginPageWhileAuthenticated: 'back' | 'home';
        forbiddenPage: 'back' | 'home' | '403';
        notFoundPage: 'back' | 'home' | '404';
    };

    expiredToken: {
        behavior: 'login' | 're-authenticate' | 'refresh';
        afterRecovery: 'restore' | 'home';
    };
}
