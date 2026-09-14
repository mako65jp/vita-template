import { FeatureFlagRepository } from '../repositories/FeatureFlagRepository';

export class FeatureFlagService {
    constructor(private readonly repository: FeatureFlagRepository) {}
}
