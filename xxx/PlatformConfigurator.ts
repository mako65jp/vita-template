// PlatformConfigurator.ts

import type { AppConfig } from './AppConfig';

export interface PlatformConfigurator {
    configure(config: AppConfig): void;
}
