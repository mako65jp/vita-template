export interface SystemConfiguration {
    databaseType: 'memory' | 'postgres' | 'sqlserver';

    authenticationType: 'none' | 'jwt' | 'oidc' | 'ldap';

    frontendType: 'react' | 'vue';
}
