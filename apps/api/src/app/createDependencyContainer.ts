import { SystemConfig } from '../systemConfig/SystemConfig';
import { createRepositories } from './createRepositories';
import { createServices } from './createServices';
import { DependencyContainer } from './DependencyContainer';

export async function createDependencyContainer(
    systemConfig: SystemConfig,
): Promise<DependencyContainer> {
    const repositories = await createRepositories(systemConfig.database);

    const services = createServices({
        repositories,
        systemConfig,
    });

    return new DependencyContainer(systemConfig, repositories, services);
}
