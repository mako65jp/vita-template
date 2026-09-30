import { AuthenticationPolicy } from '@packages/types/administration/AuthenticationPolicy';

export const defaultAuthenticationPolicy: AuthenticationPolicy = {
    session: {
        reloadBehavior: 'keep-session',
        idleTimeoutMinutes: 30,
        absoluteTimeoutMinutes: 480,
    },

    token: {
        accessTokenLifetimeMinutes: 60,
        autoRefreshEnabled: true,
        refreshThresholdMinutes: 5,
    },

    deepLink: {
        enabled: true,
        afterLogin: 'restore',
    },

    reAuthentication: {
        enabled: true,
        validMinutes: 15,
        requireForSystemSettings: true,
        requireForUserDelete: true,
        requireForRoleChange: true,
    },

    navigation: {
        loginPageWhileAuthenticated: 'back',
        forbiddenPage: 'back',
        notFoundPage: '404',
    },

    expiredToken: {
        behavior: 're-authenticate',
        afterRecovery: 'restore',
    },
};
