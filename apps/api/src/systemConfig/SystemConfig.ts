export interface BackendConfig {
    protocol?: string; //"http";
    host?: string; //"localhost";
    port?: string; //3000;
    applicationRoot?: string; //"/api";
}

export interface DatabaseConfig {
    type: 'memory' | 'postgres' | 'sqlserver';
    connectionString?: string;
}

export interface AuthenticationConfig {
    type: 'none' | 'local' | 'oidc' | 'ldap';
    secret?: string;
}

export interface FrontendConfig {
    type: 'react' | 'vue';
    host?: string; //"localhost";
}

export interface SystemConfig {
    backend: BackendConfig;
    database: DatabaseConfig;
    authentication: AuthenticationConfig;
    frontend: FrontendConfig;
}
