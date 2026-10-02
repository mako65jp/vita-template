import { AuthenticationPolicy } from '@packages/types/administration/AuthenticationPolicy';
import { ConfigurationDto } from '@packages/types/administration/ConfigurationDto';
import { Configuration } from '../domain/Configuration';

export class ConfigurationMapper {
    static toDto(configuration: Configuration): ConfigurationDto {
        const authenticationPolicy: AuthenticationPolicy = {
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

        return {
            authenticationPolicy: authenticationPolicy,
        };
    }
}
