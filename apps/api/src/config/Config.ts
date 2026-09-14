export interface DatabaseConfig {
    type: 'memory' | 'postgres' | 'sqlserver';
    connectionString?: string;
}

export interface AuthenticationConfig {
    type: 'none' | 'jwt' | 'oidc' | 'ldap';
    secret?: string;
}

export interface FrontendConfig {
    type: 'react' | 'vue';
}

export interface Config {
    database: DatabaseConfig;
    authentication: AuthenticationConfig;
    frontend: FrontendConfig;
}
