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
