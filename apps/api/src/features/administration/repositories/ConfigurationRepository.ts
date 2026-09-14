import { SystemConfiguration } from '../domain/SystemConfiguration';

export interface ConfigurationRepository {
    load(): Promise<SystemConfiguration>;

    save(configuration: SystemConfiguration): Promise<void>;
}
