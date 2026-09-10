// import { AppConfig } from "./AppConfig";
// import { PlatformConfigurator } from "./PlatformConfigurator";


// export class PlatformRegistry
//     implements PlatformConfigurator {
//     private readonly databaseProviders =
//         new Map<string, () => void>();

//     addDatabaseProvider(
//         name: string,
//         provider: () => void,
//     ) {
//         this.databaseProviders.set(
//             name,
//             provider,
//         );
//     }

//     configure(config: AppConfig) {
//         const provider =
//             this.databaseProviders.get(
//                 config.platform.database,
//             );

//         if (!provider) {
//             throw new Error(
//                 `Unknown database provider: ${config.platform.database}`,
//             );
//         }

//         provider();
//     }
// }

import type { AppConfig } from './AppConfig';
import type { PlatformConfigurator } from './PlatformConfigurator';

export type ProviderRegistration = () => void;
import type { DatabaseProvider } from '@platform/database/DatabaseProvider';

export class PlatformRegistry
    implements PlatformConfigurator {
    private readonly databaseProviders = new Map<string, DatabaseProvider>();
    private readonly authProviders = new Map<string, ProviderRegistration>();
    private readonly authorizationProviders = new Map<string, ProviderRegistration>();
    private readonly frontendProviders = new Map<string, ProviderRegistration>();

    private getRequiredProvider<T>(
        providers: Map<string, T>,
        providerName: string,
        providerType: string,
    ): T {
        const provider = providers.get(providerName);

        if (!provider) {
            throw new Error(
                `Unknown ${providerType} provider: ${providerName}`,
            );
        }

        return provider;
    }

    addDatabaseProvider(name: string, provider: DatabaseProvider): void {
        this.databaseProviders.set(name, provider);
    }

    addAuthProvider(name: string, provider: ProviderRegistration): void {
        this.authProviders.set(name, provider);
    }

    addAuthorizationProvider(name: string, provider: ProviderRegistration,): void {
        this.authorizationProviders.set(name, provider);
    }

    addFrontendProvider(name: string, provider: ProviderRegistration): void {
        this.frontendProviders.set(name, provider);
    }

    configure(config: AppConfig): void {

        this.getRequiredProvider(
            this.databaseProviders,
            config.platform.database,
            'database',
        ).connect();

        this.getRequiredProvider(
            this.authProviders,
            config.platform.auth,
            'auth',
        )();

        this.getRequiredProvider(
            this.authorizationProviders,
            config.platform.authorization,
            'authorization',
        )();

        this.getRequiredProvider(
            this.frontendProviders,
            config.platform.frontend,
            'frontend',
        )();
    }
}

