import { Configuration } from '../domain/Configuration';

export interface ConfigurationRepository {
    load(): Promise<Configuration>;

    save(configuration: Configuration): Promise<void>;
}
