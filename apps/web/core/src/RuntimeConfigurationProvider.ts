import { ApplicationConfiguration } from './ApplicationConfiguration';

export class RuntimeConfigurationProvider {
    public getConfiguration(): ApplicationConfiguration {
        const element = document.getElementById('application-configuration');

        if (element === null) {
            throw new Error('application-configuration element not found.');
        }

        const json = element.textContent;

        if (json === null) {
            throw new Error('application configuration not found.');
        }

        return JSON.parse(json) as ApplicationConfiguration;
    }
}
