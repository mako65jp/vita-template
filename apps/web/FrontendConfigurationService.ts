import { ApplicationConfiguration } from './ApplicationConfiguration';

export class FrontendConfigurationService {
    constructor(private readonly configuration: ApplicationConfiguration) {}

    public getApiBaseUrl(): string {
        const backend = this.configuration.backend;

        return (
            `${backend.protocol}://` +
            `${backend.host}:` +
            `${backend.port}` +
            `${backend.applicationRoot}`
        );
    }
}

// import { ApplicationConfiguration } from './ApplicationConfiguration';

// export class FrontendConfigurationService {

//     constructor(
//         private readonly configuration: ApplicationConfiguration,
//     ) { }

//     public getApiBaseUrl(): string {
//         return this.configuration.apiBaseUrl;
//     }
// }

// // import { FrontendConfig } from './FrontendConfig';

// // export class FrontendConfigurationService {
// //     async load(): Promise<FrontendConfig> {
// //         const response = await fetch('/config');

// //         if (!response.ok) {
// //             throw new Error('Failed to load frontend configuration.');
// //         }

// //         return await response.json();
// //     }
// // }
