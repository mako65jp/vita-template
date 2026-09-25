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
