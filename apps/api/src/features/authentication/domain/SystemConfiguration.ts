import { AuthenticationPolicy } from '@packages/types/authentication/AuthenticationPolicy';

export interface SystemConfiguration {
    databaseType: 'memory' | 'postgres' | 'sqlserver';
    authenticationType: 'none' | 'local' | 'oidc' | 'ldap';
    frontendType: 'react' | 'vue';
    authenticationPolicy: AuthenticationPolicy;
}
