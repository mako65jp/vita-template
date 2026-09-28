import { ConfigurationDto } from '@packages/types/administration/ConfigurationDto';
import { Application } from '../../Application';

const application = new Application();

export class ConfigurationApi {
    async getConfiguration(): Promise<ConfigurationDto> {
        const response = await application.fetch(`/configuration`);

        if (!response.ok) {
            throw new Error(`Get configuration failed: ${response.status}`);
        }

        return await response.json();
    }

    async saveConfiguration(configuration: ConfigurationDto): Promise<void> {
        const response = await application.fetch(`/configuration`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(configuration),
        });

        if (!response.ok) {
            throw new Error(`Save configuration failed: ${response.status}`);
        }
    }
}
