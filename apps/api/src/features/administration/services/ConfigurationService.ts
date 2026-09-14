import { ConfigurationRepository } from '../repositories/ConfigurationRepository';

export class ConfigurationService {
    constructor(private readonly repository: ConfigurationRepository) {}
}
