import type { SystemConfig } from '../systemConfig/SystemConfig';
import type { Repositories } from './Repositories';
import { Services } from './Services';

export class DependencyContainer {
    constructor(
        public readonly systemConfig: SystemConfig,
        public readonly repositories: Repositories,
        public readonly services: Services,
    ) {}
}
