import { FrontendConfigurationService } from './FrontendConfigurationService';
import { RuntimeConfigurationProvider } from './RuntimeConfigurationProvider';

export class Application {
    public readonly configurationService: FrontendConfigurationService;

    public constructor() {
        const configurationProvider = new RuntimeConfigurationProvider();

        this.configurationService = new FrontendConfigurationService(
            configurationProvider.getConfiguration(),
        );
    }
}

// import { FrontendConfig } from './FrontendConfig';
// import { FrontendConfigurationService } from './FrontendConfigurationService';

// export class Application {
//     private config: FrontendConfig | undefined;

//     constructor(private readonly configurationService: FrontendConfigurationService) {}

//     async initialize(): Promise<void> {
//         this.config = await this.configurationService.load();
//     }

//     getConfig(): FrontendConfig {
//         if (!this.config) {
//             throw new Error('Application is not initialized.');
//         }

//         return this.config;
//     }
// }

// // import { FrontendConfig } from './FrontendConfig';

// // import { FrontendConfigurationService } from './FrontendConfigurationService';

// // export class Application {
// //     constructor(private readonly configurationService: FrontendConfigurationService) {}

// //     async initialize(): Promise<FrontendConfig> {
// //         return await this.configurationService.load();
// //     }
// // }
