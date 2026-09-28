import { FrontendConfigurationService } from './FrontendConfigurationService';
import { RuntimeConfigurationProvider } from './RuntimeConfigurationProvider';

export class Application {
    private configurationService: FrontendConfigurationService;

    public constructor() {
        const configurationProvider = new RuntimeConfigurationProvider();

        this.configurationService = new FrontendConfigurationService(
            configurationProvider.getConfiguration(),
        );
    }

    public async fetch(input: string, init?: RequestInit): Promise<Response> {
        console.log('Application.fetch:');
        console.log('  input:', input);
        console.log('  method', init?.method);
        console.log('  body', init?.body);

        const url = this.configurationService.getApiBaseUrl() + input;
        console.log('  url:', url);

        return await fetch(url, init);
    }
}
