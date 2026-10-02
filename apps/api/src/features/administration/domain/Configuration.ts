export interface Configuration {
    databaseType: 'memory' | 'postgres' | 'sqlserver';
    authenticationType: 'none' | 'local' | 'oidc' | 'ldap';
    frontendType: 'react' | 'vue';
}
