import { readFile } from 'node:fs/promises';
import { SystemConfig } from './SystemConfig';

export async function loadSystemConfig(path: string): Promise<SystemConfig> {
    const json = await readFile(path, 'utf8');
    const systemConfig = JSON.parse(json) as SystemConfig;

    if (systemConfig.backend.applicationRoot == undefined) {
        systemConfig.backend.applicationRoot = '/api';
    }
    if (systemConfig.backend.host == undefined) {
        systemConfig.backend.host = 'localhost';
    }
    if (systemConfig.backend.port == undefined) {
        systemConfig.backend.port = '3000';
    }
    if (systemConfig.backend.protocol == undefined) {
        systemConfig.backend.protocol = 'http';
    }

    if (systemConfig.authentication.secret == undefined) {
        systemConfig.authentication.secret = 'change-this-secret';
    }

    if (systemConfig.frontend.host == undefined) {
        systemConfig.frontend.host = 'localhost';
    }

    return systemConfig;
}
