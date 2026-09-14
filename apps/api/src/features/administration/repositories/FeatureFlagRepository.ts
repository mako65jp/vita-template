import { FeatureFlag } from '../domain/FeatureFlag';

export interface FeatureFlagRepository {
    findAll(): Promise<FeatureFlag[]>;

    save(feature: FeatureFlag): Promise<void>;
}
