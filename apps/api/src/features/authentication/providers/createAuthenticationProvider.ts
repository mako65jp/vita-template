import { AuthenticationConfig } from '@apps/api/config/Config';
import { UserService } from '../../user/services/UserService';
import { AuthenticationProvider } from './AuthenticationProvider';
import { LdapAuthenticationProvider } from './LdapAuthenticationProvider';
import { LocalAuthenticationProvider } from './LocalAuthenticationProvider';
import { NoAuthenticationProvider } from './NoAuthenticationProvider';
import { OidcAuthenticationProvider } from './OidcAuthenticationProvider';

export function createAuthenticationProvider(
    config: AuthenticationConfig,
    services: {
        userService: UserService;
    },
): AuthenticationProvider {
    switch (config.type) {
        case 'local':
            return new LocalAuthenticationProvider(services.userService);

        case 'ldap':
            return new LdapAuthenticationProvider();

        case 'oidc':
            return new OidcAuthenticationProvider();

        case 'none':
            return new NoAuthenticationProvider();

        default:
            throw new Error(`Unsupported authentication type: ${config.type}`);
    }
}
